module ODFReport
  module Actions
    class RemoveSection
      def initialize(section_name)
        @section_name = section_name
      end

      def process!(doc)
        section_node = section_node(doc)

        section_node.remove if section_node
      end

      private

      def section_node(doc)
        sections = doc.xpath(".//text:section[@text:name='#{@section_name}']")
        sections.empty? ? nil : sections.first
      end
    end
  end
end
