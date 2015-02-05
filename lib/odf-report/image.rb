module ODFReport
  class Image

    INTERNAL_IMAGE_DIR = "Pictures"

    def initialize(opts, &block)
      @name = opts[:name].upcase
      @data_field = opts[:data_field]
      @dpi = opts[:dpi] || 300
      @scale = opts[:scale] || 1

      unless @path = opts[:path]
        @block = block if block_given?
      end
    end

    def replace!(content, data_item = nil)
      raise 'File invalid' unless $file
      extract_path(data_item)
      if node = content.xpath(".//draw:frame[@draw:name='#{@name}']/draw:image").first
          # generate uuid
        uuid = SecureRandom.uuid.delete('-').upcase
          # change path
        internal_image_path = ::File.join(INTERNAL_IMAGE_DIR, ::File.basename("#{uuid}.png"))
        node.attribute('href').value = internal_image_path
          # set size
        img_size = get_size
        node.parent.attribute('width').value = img_size.first
        node.parent.attribute('height').value = img_size.last
          # change name
        node.parent.attribute('name').value = "p_#{uuid}"
          # upload image
        $file.output_stream.put_next_entry(internal_image_path)
        $file.output_stream.write ::File.read(@path)
          # images that will be written to manifest file
        img_type = ::FastImage.type(@path)
        $images << { path: internal_image_path, type: "image/#{img_type}" }
      end
    end

    private

    def extract_path(data_item)
      if @block
        @path = @block.call(data_item)
      else
        @path = data_item
      end
      raise 'Cannot find path to the image in data_item !' unless @path
    end

    def get_size
      img_size = ::FastImage.size(@path)
      img_size.map { |px| "#{(px / @dpi) * 2.54 * @scale}cm" }
    end

  end
end
