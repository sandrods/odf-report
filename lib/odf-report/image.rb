require 'mime/types'
require 'securerandom'

module ODFReport
  class Image < Field

    IMAGE_DIR_NAME = "Pictures"

    attr_reader :href, :new_file

    def replace!(doc, data_item = nil)

      return unless node = find_image_node(doc)

      @new_file = get_value(data_item)

      @href = File.join(IMAGE_DIR_NAME, "#{SecureRandom.hex}_#{File.basename(new_file)}")

      # @href = File.join(IMAGE_DIR_NAME, "100000000000014000000#{rand(1000..5000)}E5D9155585D8FB7.jpg")
      # @href = @node.attribute('href')


      node.attribute('href').value = @href

    end

    def include_image_file(file)
      return if @href.nil?

      file.update_file(@href, File.read(@new_file))
    end

    def include_manifest_entry(content)
      return if @href.nil?

      return unless root_node = content.xpath("//manifest:manifest").first

      node = content.create_element('manifest:file-entry')
      node['manifest:full-path'] = @href
      node['manifest:media-type'] = MIME::Types.type_for(@href)[0].content_type

      root_node.add_child node

    end

    private

    def find_image_node(doc)
      doc.xpath("//draw:frame[@draw:name='#{@name}']/draw:image").first
    end

  end
end
