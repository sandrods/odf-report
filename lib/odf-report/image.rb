module ODFReport
  class Image < Field

    IMAGE_DIR_NAME = "Pictures"

    attr_reader :href, :new_file

    def replace!(doc, data_item = nil)
      frame = doc.at("//draw:frame[@draw:name='#{@name}']")
      image = doc.at("//draw:frame[@draw:name='#{@name}']/draw:image")

      return unless image

      @new_file = get_value(data_item)
      @href     = File.join(IMAGE_DIR_NAME, File.basename(@new_file))

      image.attribute('href').content = @href
      frame.attribute('name').content = SecureRandom.hex
    end

    def self.include_image_file(file, i)
      return if i[:href].nil?

      file.update_file(i[:href], File.read(i[:file]))
    end

    def self.include_manifest_entry(content, i)
      return if i[:href].nil?

      return unless root_node = content.at("//manifest:manifest")

      entry = content.create_element('manifest:file-entry')
      entry['manifest:full-path']  = i[:href]
      entry['manifest:media-type'] = MIME::Types.type_for(i[:href])[0].content_type

      root_node.add_child entry

    end

  end
end
