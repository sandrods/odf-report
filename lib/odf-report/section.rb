module ODFReport

  class Section < ODFReport::Component
    include Fields, Nested

    attr_accessor :fields, :tables, :data, :name, :collection_field, :parent
    
    def populate!(row)
      @collection = get_collection_from_item(row, @collection_field) if row
    end

    def replace!(doc, row = nil)

      return unless section = find_section_node(doc)

      template = section.dup

      populate!(row)

      @collection.each do |data_item|
        new_section = template.dup

        replace_fields!(new_section, data_item)

        @texts.each do |t|
          t.replace!(new_section, data_item)
        end

        @tables.each do |t|
          t.replace!(new_section, data_item)
        end

        @sections.each do |s|
          s.replace!(new_section, data_item)
        end

        section.before(new_section)

      end

      section.remove

    end # replace_section

  private

    def find_section_node(doc)

      sections = doc.xpath(".//text:section[@text:name='#{@name}']")

      sections.empty? ? nil : sections.first

    end

  end

end
