module ODFReport

  class Text < Field

    attr_accessor :parser

    def replace!(doc, data_item = nil)

      return unless node = find_text_node(doc)

      @parser = Parser::Default.new(get_value(data_item), node)

      @parser.paragraphs.each do |p|
        node.before(p)
      end

      node.remove

    end

    private

    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{to_placeholder}']")
      texts.empty? ? nil : texts.first
    end

  end

end