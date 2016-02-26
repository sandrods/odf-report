module ODFReport

  class Image

    DELIMITERS = %w([ ])
    IMAGE_DIR_NAME = "Pictures"

    def initialize(opts, &block)
      @name = opts[:name]
      @data_image = opts[:data_image]

      unless @value = opts[:value]

        if block_given?
          @block = block

        else
          @block = lambda { |item| self.extract_value(item) }
        end

      end

    end

    def replace!(content, data_item = nil)
      old_file = ''
      path = get_value(data_item)
      
      if path.empty?
        return
      end
      
      content.xpath(".//draw:frame[svg:title='#{to_placeholder}']/draw:image").each do |node|
        placeholder_path = node.attribute('href').value
        node.attribute('href').value = ::File.join(IMAGE_DIR_NAME, ::File.basename(path))
        old_file = ::File.join(IMAGE_DIR_NAME, ::File.basename(placeholder_path))
      end
      content.xpath(".//draw:frame[svg:title='#{to_placeholder}']/svg:title").each do |node|
        node.content = ''
      end
      {path=>old_file}
    end

    def get_value(data_item = nil)
      @value || @block.call(data_item) || ''
    end

    def extract_value(data_item)
      return unless data_item
      key = @data_image || @name
      if data_item.is_a?(Hash)
        data_item[key] || data_item[key.to_s.downcase] || data_item[key.to_s.upcase] || data_item[key.to_s.downcase.to_sym]

      elsif data_item.respond_to?(key.to_s.downcase.to_sym)
        data_item.send(key.to_s.downcase.to_sym)

      else
        raise "Can't find image [#{key}] in this #{data_item.class}"

      end

    end

    private

    def to_placeholder
      if DELIMITERS.is_a?(Array)
        "#{DELIMITERS[0]}#{@name.to_s.upcase}#{DELIMITERS[1]}"
      else
        "#{DELIMITERS}#{@name.to_s.upcase}#{DELIMITERS}"
      end
    end

    def sanitize(txt)
      txt = html_escape(txt)
      txt = odf_linebreak(txt)
      txt
    end

    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }

    def html_escape(s)
      return "" unless s
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end

    def odf_linebreak(s)
      return "" unless s
      s.to_s.gsub("\n", "<text:line-break/>")
    end



  end
end