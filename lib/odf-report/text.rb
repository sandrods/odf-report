module ODFReport
  class Text < Field
    def replace!(doc)
      return unless (node = find_text_node(doc))

      parser = Parser::Default.new(@data_source.value, node)

      parser.paragraphs.each do |p|
        node.before(p)
      end

      node.remove
    end

    private

    def find_text_node(doc)
      nodes = doc.xpath(".//text:p[text()='#{to_placeholder}']")
      return nodes.first unless nodes.empty?

      span = doc.xpath(".//text:p/text:span[text()='#{to_placeholder}']").first
      span&.parent
    end
  end
end
