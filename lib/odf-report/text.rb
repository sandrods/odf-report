module ODFReport

  class Text < Field

    attr_accessor :parser

    def replace!(doc)

      return unless node = find_text_node(doc)

      @parser = Parser::Default.new(@data_source.value, node)

      @parser.paragraphs.each do |p|
        node.before(p)
      end

      node.remove

    end

    private

    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{to_placeholder}']")
      if texts.empty?
        texts = doc.xpath(".//text:p/text:span[text()='#{to_placeholder}']")
        if texts.empty?
          texts = nil
        else
          texts = texts.first.parent
        end
      else
        texts = texts.first
      end

      texts
    end

  end

end
