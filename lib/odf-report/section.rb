module ODFReport

  class Section < Nestable

    def initialize(name, value)
      @name = name.to_s.upcase
      @collection = value
    end

    def replace!(doc)

      return unless find_section_node(doc)

      @collection.each do |record|

        new_section = get_section_node

        record.each do |key, value|
          Component.for(key, value, new_section).replace!(new_section)
        end

        @section_node.before(new_section)

      end

      @section_node.remove

    end # replace_section

  private

    def find_section_node(doc)

      sections = doc.xpath(".//text:section[@text:name='#{@name}']")

      @section_node = sections.empty? ? nil : sections.first

    end

    def get_section_node
      node = @section_node.dup

      name = node.get_attribute('text:name').to_s
      @idx ||=0; @idx +=1
      node.set_attribute('text:name', "#{name}_#{@idx}")

      node
    end

  end

end
