module ODFReport
  class Report

    def initialize(template_name, &block)

      @file = ODFReport::File.new(template_name)

      @texts = []
      @fields = []
      @tables = []
      @images = []
      @sections = []

      yield(self)

    end

    def add_field(field_tag, value='')
      opts = {:name => field_tag, :value => value}
      field = Field.new(opts)
      @fields << field
    end

    def add_text(field_tag, value='')
      opts = {:name => field_tag, :value => value}
      text = Text.new(opts)
      @texts << text
    end

    def add_table(table_name, collection, opts={})
      opts.merge!(:name => table_name, :collection => collection)
      tab = Table.new(opts)
      @tables << tab

      yield(tab)
    end

    def add_section(section_name, collection, opts={})
      opts.merge!(:name => section_name, :collection => collection)
      sec = Section.new(opts)
      @sections << sec

      yield(sec)
    end

    def add_image(image_name, image_path, opts = {})
      opts.merge(name: image_name, path: image_path)
      image = Image.new(opts)
      @images << image
    end

    def generate(dest = nil)

      @file.update_content do |file|

        $file = file
        $images = []

        file.update_files('content.xml', 'styles.xml', 'META-INF/manifest.xml') do |txt, file|
          parse_document(txt) do |doc|

            unless file == 'META-INF/manifest.xml'
              @sections.each { |s| s.replace!(doc) }
              @tables.each   { |t| t.replace!(doc) }
              @texts.each    { |t| t.replace!(doc) }
              @fields.each   { |f| f.replace!(doc) }
              @images.each   { |i| i.replace!(doc) }
            else
              insert_new_images_info_manifest(doc, $images)
            end

          end
        end
      end

      if dest
        ::File.open(dest, "wb") {|f| f.write(@file.data) }
      else
        @file.data
      end

    end

    private

    def parse_document(txt)
      doc = Nokogiri::XML(txt)
      yield doc
      txt.replace(doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML))
    end

    def insert_new_images_info_manifest(content, images)
      if manifest_node = content.xpath("//manifest:manifest").first
        images.each do |image|
          picture = Nokogiri::XML::Node.new("file-entry", content)
          picture['manifest:full-path'] = image[:path]
          picture['manifest:media-type'] = image[:type]
          manifest_node.add_child(picture)
        end
      end
    end

  end
end
