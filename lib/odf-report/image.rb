module ODFReport
  class Image < Field
    IMAGE_DIR_NAME = "Pictures"

    attr_reader :files

    def initialize(opts, &block)
      @files = []
      super
    end

    def replace!(doc, data_item = nil)
      frame = doc.xpath("//draw:frame[@draw:name='#{@name}']").first
      return unless frame

      image = frame.at_xpath("draw:image")
      return unless image

      file = @data_source.value

      if file
        image.attribute("href").content = self.class.image_href(file)
        frame.attribute("name").content = SecureRandom.uuid

        @files << file
      else
        frame.remove
      end
    end

    def self.include_image_file(zip_file, image_file)
      return unless image_file

      zip_file.update_file(image_href(image_file), File.read(image_file))
    end

    def self.include_manifest_entry(content, image_file)
      return unless image_file

      return unless (root_node = content.at("//manifest:manifest"))

      href = image_href(image_file)

      entry = content.create_element("manifest:file-entry")
      entry["manifest:full-path"] = href
      entry["manifest:media-type"] = MIME::Types.type_for(href)[0].content_type

      root_node.add_child entry
    end

    def self.image_href(file)
      File.join(IMAGE_DIR_NAME, File.basename(file))
    end
  end
end
