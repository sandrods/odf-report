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

  class Default

    attr_accessor :paragraphs

    def initialize(text)

      @text = text
      @paragraphs = []

    end

    def parse(node)
      xml = node.parse(@text)

      xml.css("p").each do |p|
        style = (p.parent.name == "blockquote") ? "quote" : nil
        add_paragraph(p.inner_html, style)
      end
    end

    def add_paragraph(text, style)
      @paragraphs << {:text => parse_styles(text), :style => style}
    end

    def parse_styles(text)
      text.strip!
      text.gsub!(/<strong>(.+)<\/strong>/)  { "<text:span text:style-name=\"bold\">#{$1}<\/text:span>" }
      text.gsub!(/<em>(.+)<\/em>/)          { "<text:span text:style-name=\"italic\">#{$1}<\/text:span>" }
      text.gsub!("\n", "")
      text
    end

  end

end

end