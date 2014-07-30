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

    attr_accessor :paragraphs

    def initialize(text, template_node)
      @text = text
      @paragraphs = []
      @template_node = template_node

      parse
    end

    def parse

      xml = @template_node.parse(@text)

      xml.css("p", "h1", "h2").each do |p|

        style = check_style(p)
        text = parse_formatting(p.inner_html)

        add_paragraph(text, style)
      end
    end

    def add_paragraph(text, style)

      node = @template_node.dup

      node['text:style-name'] = style if style
      node.children = text

      @paragraphs << node
    end

    private

    def parse_formatting(text)
      text.strip!
      text.gsub!(/<strong>(.+?)<\/strong>/)  { "<text:span text:style-name=\"bold\">#{$1}<\/text:span>" }
      text.gsub!(/<em>(.+?)<\/em>/)          { "<text:span text:style-name=\"italic\">#{$1}<\/text:span>" }
      text.gsub!(/<u>(.+?)<\/u>/)            { "<text:span text:style-name=\"underline\">#{$1}<\/text:span>" }
      text.gsub!("\n", "")
      text
    end

    def check_style(node)
      style = nil

      if node.name =~ /h\d/i
        style = "title"

      elsif node.parent && node.parent.name == "blockquote"
        style = "quote"

      elsif node['style'] =~ /margin/
        style = "quote"

      end

      style
    end

  end

end

end
