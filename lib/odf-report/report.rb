module ODFReport
  class Report
    include Composable

    def initialize(template_name = nil, io: nil)
      @template = ODFReport::Template.new(template_name, io: io)

      yield(self) if block_given?
    end

    def generate(dest = nil)
      @template.update_content do |file|
        file.update_files { |doc| replace_placeholders!(doc) }

        include_images(file)
      end

      if dest
        File.binwrite(dest, @template.data)
      else
        @template.data
      end
    end

    def all_images
      @all_images ||= super.uniq
    end

    private

    def replace_placeholders!(doc)
      sections.each { |c| c.replace!(doc) }
      tables.each { |c| c.replace!(doc) }

      texts.each { |c| c.replace!(doc) }
      fields.each { |c| c.replace!(doc) }

      images.each { |c| c.replace!(doc) }
    end

    def include_images(file)
      all_images.each { |i| Image.include_image_file(file, i) }

      file.update_manifest do |content|
        all_images.each { |i| Image.include_manifest_entry(content, i) }
      end
    end
  end
end
