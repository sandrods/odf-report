module ODFReport
  module Parser
    # Default HTML parser
    #
    # sample HTML
    #
    # <p> first paragraph </p>
    # <p> second <strong>paragraph</strong> </p>
    # <blockquote>
    #     <p> first <em>quote paragraph</em> </p>
    #     <p> first quote paragraph </p>
    #     <p> first quote paragraph </p>
    # </blockquote>
    # <p> third <strong>paragraph</strong> </p>
    #
    # <p style="margin: 100px"> fourth <em>paragraph</em> </p>
    # <p style="margin: 120px"> fifth paragraph </p>
    # <p> sixth <strong>paragraph</strong> </p>
    #

    class Default
      attr_reader :paragraphs

      def initialize(text, template_node)
        @text = text
        @paragraphs = []
        @template_node = template_node

        parse
      end

      private

      def parse
        html = Nokogiri::HTML5.fragment(@text)

        html.css("p", "h1", "h2").each do |p|
          style = check_style(p)
          text = parse_formatting(p.inner_html)

          add_paragraph(text, style)
        end
      end

      def add_paragraph(text, style)
        node = @template_node.dup

        node["text:style-name"] = style if style
        node.children = text

        @paragraphs << node
      end

      def parse_formatting(text)
        text.strip!
        text.gsub!(/<strong.*?>(.+?)<\/strong>/) { "<text:span text:style-name=\"bold\">#{$1}</text:span>" }
        text.gsub!(/<em.*?>(.+?)<\/em>/) { "<text:span text:style-name=\"italic\">#{$1}</text:span>" }
        text.gsub!(/<u.*?>(.+?)<\/u>/) { "<text:span text:style-name=\"underline\">#{$1}</text:span>" }
        text.gsub!(/<br\/?>/, "<text:line-break/>")
        text.delete!("\n")
        text
      end

      def check_style(node)
        return "title" if /h\d/i.match?(node.name)
        return "quote" if node.parent&.name == "blockquote"
        "quote" if /margin/.match?(node["style"])
      end
    end
  end
end
