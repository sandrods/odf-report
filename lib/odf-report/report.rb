module ODFReport
  class Report
    def initialize(template_name = nil, io: nil)
      @template = ODFReport::Template.new(template_name, io: io)

      @texts = []
      @fields = []
      @tables = []
      @sections = []

      @images = []

      yield(self) if block_given?
    end

    def add_field(field_tag, value = "")
      opts = {name: field_tag, value: value}
      field = Field.new(opts)
      @fields << field
    end

    def add_text(field_tag, value = "")
      opts = {name: field_tag, value: value}
      text = Text.new(opts)
      @texts << text
    end

    def add_table(table_name, collection, opts = {})
      opts[:name] = table_name
      opts[:collection] = collection

      tab = Table.new(opts)
      @tables << tab

      yield(tab)
    end

    def add_section(section_name, collection, opts = {})
      opts[:name] = section_name
      opts[:collection] = collection

      sec = Section.new(opts)
      @sections << sec

      yield(sec)
    end

    def add_image(image_name, value = nil)
      opts = {name: image_name, value: value}
      image = Image.new(opts)
      @images << image
    end

    def generate(dest = nil)
      @template.update_content do |file|
        file.update_files do |doc|
          @sections.each { |c| c.replace!(doc) }
          @tables.each { |c| c.replace!(doc) }

          @texts.each { |c| c.replace!(doc) }
          @fields.each { |c| c.replace!(doc) }

          @images.each { |c| c.replace!(doc) }
        end

        all_images.each { |i| Image.include_image_file(file, i) }

        file.update_manifest do |content|
          all_images.each { |i| Image.include_manifest_entry(content, i) }
        end
      end

      if dest
        File.binwrite(dest, @template.data)
      else
        @template.data
      end
    end

    def all_images
      @all_images ||= (@images.map(&:files) + @sections.map(&:all_images) + @tables.map(&:all_images)).flatten.uniq
    end
  end
end
