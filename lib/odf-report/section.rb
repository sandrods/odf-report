module ODFReport

  class Section < Nestable

    def replace!(doc)

      return unless find_section_node(doc)

      @data_source.each do |record|

        new_section = get_section_node

        @tables.each    { |t| t.set_source(record).replace!(new_section) }

        @sections.each  { |s| s.set_source(record).replace!(new_section) }

        @texts.each     { |t| t.set_source(record).replace!(new_section) }

        @fields.each    { |f| f.set_source(record).replace!(new_section) }

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
