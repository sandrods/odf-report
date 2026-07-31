module ODFReport
  module Parser
    # Default HTML parser
    #
    # Converts an HTML fragment into ODF nodes. Supported:
    #   - <p>, <h1>..<h6>                -> paragraphs (headings use "title")
    #   - <blockquote>                   -> paragraphs use the "quote" style
    #   - <ul>, <ol>, <li>               -> ODF lists (text:list / text:list-item),
    #                                       including nested lists
    #   - <strong>/<b>, <em>/<i>, <u>    -> styled text:span
    #   - <br>                           -> text:line-break
    #
    # Any other element is unwrapped: its tags are dropped and its text kept.
    # This guarantees only ODF elements end up in content.xml — foreign HTML
    # tags (e.g. <a>, <span>, <div>) embedded verbatim would otherwise make
    # LibreOffice reject the document with a "Format error".
    #
    class Default
      attr_reader :paragraphs

      LIST_TAGS = %w[ul ol].freeze

      STYLE_TAGS = {
        "strong" => "bold",  "b" => "bold",
        "em"     => "italic", "i" => "italic",
        "u"      => "underline", "ins" => "underline"
      }.freeze

      XML_ESCAPE = { "&" => "&amp;", "<" => "&lt;", ">" => "&gt;" }.freeze

      def initialize(text, template_node)
        @text = text
        @paragraphs = []
        @template_node = template_node

        parse
      end

      private

      def parse
        html = Nokogiri::HTML5.fragment(@text)
        process(html.children)
      end

      # Walk top-level nodes in document order so lists interleave correctly
      # with paragraphs. Unknown container elements (e.g. <div>) are descended
      # into, preserving the behaviour where nested paragraphs were picked up.
      def process(nodes)
        nodes.each do |node|
          case node.name
          when "p"
            add_paragraph(inline_content(node), check_style(node))
          when "h1", "h2", "h3", "h4", "h5", "h6"
            add_paragraph(inline_content(node), "title")
          when "ul", "ol"
            @paragraphs << build_list(node)
          when "text"
            add_paragraph(escape(node.content), nil) unless node.text.strip.empty?
          else
            process(node.children) if node.element?
          end
        end
      end

      def add_paragraph(text, style)
        node = @template_node.dup

        node["text:style-name"] = style if style
        node.children = text

        @paragraphs << node
      end

      # Build an ODF list as an in-context XML string (text: prefixes resolve
      # against the document namespaces when inserted before the placeholder).
      def build_list(node)
        items = node.children.select { |c| c.name == "li" }.map { |li| build_list_item(li) }.join
        %(<text:list>#{items}</text:list>)
      end

      def build_list_item(li)
        inner  = ""
        nested = []

        li.children.each do |child|
          if LIST_TAGS.include?(child.name)
            nested << child
          else
            inner << inline_node(child)
          end
        end

        body = %(<text:p>#{inner}</text:p>) + nested.map { |n| build_list(n) }.join
        %(<text:list-item>#{body}</text:list-item>)
      end

      # Convert the inline children of an element into an ODF inline XML string.
      def inline_content(node)
        node.children.map { |child| inline_node(child) }.join
      end

      def inline_node(node)
        if node.text?
          escape(node.content)
        elsif node.name == "br"
          "<text:line-break/>"
        elsif (style = STYLE_TAGS[node.name])
          %(<text:span text:style-name="#{style}">#{inline_content(node)}</text:span>)
        elsif node.element?
          inline_content(node) # unwrap unknown/foreign tags, keep their text
        else
          "" # comments, processing instructions, etc.
        end
      end

      # Decoded text -> well-formed, ODF-safe XML text. HTML entities have
      # already been decoded to real characters by the HTML5 parser; we only
      # need to escape the XML metacharacters and drop stray newlines.
      def escape(text)
        text.delete("\n").gsub(/[&<>]/, XML_ESCAPE)
      end

      def check_style(node)
        return "quote" if node.parent&.name == "blockquote"

        "quote" if /margin/.match?(node["style"])
      end
    end
  end
end
