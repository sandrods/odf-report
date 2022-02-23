module ODFReport
  class Section < Nestable

    def replace!(doc)

      return unless find_section_node(doc)

      @data_source.each do |record|

        new_section = deep_clone(@section_node)

        @tables.each    { |t| t.set_source(record).replace!(new_section) }
        @sections.each  { |s| s.set_source(record).replace!(new_section) }
        @texts.each     { |t| t.set_source(record).replace!(new_section) }
        @fields.each    { |f| f.set_source(record).replace!(new_section) }
        @images.each    { |i| i.set_source(record).replace!(new_section) }

        @section_node.before(new_section.to_xml)

      end

      @section_node.remove

    end # replace_section

  private

    def find_section_node(doc)
      @section_node = doc.at_xpath("//text:section[@text:name='#{@name}']")
    end

    def deep_clone(node)
      Nokogiri::XML(wrap_with_ns(node)).at_xpath("//text:section")
                                       .tap { |n| n.attribute('name').content = SecureRandom.uuid }

    end

  end
end
