module ODFReport
  class Image < Field

    IMAGE_DIR_NAME = "Pictures"

    attr_reader :files

    def initialize(opts, &block)
      @files = []
      @keep_ratio = opts[:keep_ratio]
      super
    end

    def replace!(doc, data_item = nil)

      frame = doc.xpath("//draw:frame[@draw:name='#{@name}']").first
      image = doc.xpath("//draw:frame[@draw:name='#{@name}']/draw:image").first

      return unless image

      file = @data_source.value

      if file
        image.attribute('href').content = File.join(IMAGE_DIR_NAME, File.basename(file))
        frame.attribute('name').content = SecureRandom.uuid

        update_node_ratio(frame) if @keep_ratio

        @files << file
      else
        frame.remove
      end
      
    end

    def compute_ratio
      width, height = FastImage.size(@data_source.value)
      width.to_f / height.to_f
    end

    def update_node_ratio(node)
      node_width, node_height, unit = get_node_image_dimensions(node)
      return if node_width.nil? || node_height.nil?

      node_ratio = node_width / node_height
      image_ratio = compute_ratio

      if image_ratio < node_ratio # Image is narrower than target
        update_node_size_attribute(node, :width, node_width * image_ratio / node_ratio, unit)
      elsif image_ratio > node_ratio # Image is wider than target
        update_node_size_attribute(node, :height, node_height * node_ratio / image_ratio, unit)
      end
    end

    def update_node_size_attribute(node, attribute, value, unit)
      node.attribute(attribute.to_s).value = "#{value}#{unit}"
    end

    def get_node_image_dimensions(node)
      node_width, unit = extract_size_and_unit node.attribute('width').value
      node_height, _ = extract_size_and_unit node.attribute('height').value

      [node_width, node_height, unit]
    end

    def extract_size_and_unit(value)
      value.match(/\A(\d*\.?\d+)(cm|in)\z/) { |m| [m[1].to_f, m[2].to_s] }
    rescue
      nil
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
