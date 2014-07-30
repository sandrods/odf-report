module ODFReport
  class Field

    DELIMITERS = %w([ ])

    def initialize(opts, &block)
      @name = opts[:name]
      @data_field = opts[:data_field]

      unless @value = opts[:value]

        if block_given?
          @block = block

        else
          @block = lambda { |item| self.extract_value(item) }
        end

      end

    end

    def replace!(content, data_item = nil)

      txt = content.inner_html

      val = get_value(data_item)

      txt.gsub!(to_placeholder, sanitize(val))

      content.inner_html = txt

    end

    def get_value(data_item = nil)
      @value || @block.call(data_item) || ''
    end

    def extract_value(data_item)
      return unless data_item

      key = @data_field || @name

      if data_item.is_a?(Hash)
        data_item[key] || data_item[key.to_s.downcase] || data_item[key.to_s.upcase] || data_item[key.to_s.downcase.to_sym]

      elsif data_item.respond_to?(key.to_s.downcase.to_sym)
        data_item.send(key.to_s.downcase.to_sym)

      else
        raise "Can't find field [#{key}] in this #{data_item.class}"

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
