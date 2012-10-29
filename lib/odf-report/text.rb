module ODFReport

  class Text < Field

    attr_accessor :parser

    def replace!(doc, data_item = nil)

      return unless text = find_text_node(doc)

      @parser = Parser::Default.new(get_value(data_item))
      @parser.parse(text)

      @parser.paragraphs.each do |p|
        node = text.dup
        node['text:style-name'] = p[:style] if p[:style]
        node.children = p[:text]
        text.before(node)
      end

      text.remove

    end

    private

    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{to_placeholder}']")
      texts.empty? ? nil : texts.first
    end

  end

end