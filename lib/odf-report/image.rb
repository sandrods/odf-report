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
      image = doc.xpath("//draw:frame[@draw:name='#{@name}']/draw:image").first

      return unless image

      file = @data_source.value

      image.attribute('href').content = File.join(IMAGE_DIR_NAME, File.basename(file))
      frame.attribute('name').content = SecureRandom.uuid

      @files << file
    end

    def self.include_image_file(zip_file, image_file)
      return unless image_file

      href = File.join(IMAGE_DIR_NAME, File.basename(image_file))

      zip_file.update_file(href, File.read(image_file))
    end

    def self.include_manifest_entry(content, image_file)
      return unless image_file

      return unless root_node = content.at("//manifest:manifest")

      href = File.join(IMAGE_DIR_NAME, File.basename(image_file))

      entry = content.create_element('manifest:file-entry')
      entry['manifest:full-path']  = href
      entry['manifest:media-type'] = MIME::Types.type_for(href)[0].content_type

      root_node.add_child entry

    end

  end
end
