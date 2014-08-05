module ODFReport
  class Field

    DELIMITERS = %w([ ])

    def initialize(name, value)
      @name = name.to_s.upcase
      @value = value
    end

    def replace!(content)

      txt = content.inner_html

      txt.gsub!(to_placeholder, sanitize(@value))

      content.inner_html = txt

    end

    private

    def to_placeholder
      if DELIMITERS.is_a?(Array)
        "#{DELIMITERS[0]}#{@name}#{DELIMITERS[1]}"
      else
        "#{DELIMITERS}#{@name}#{DELIMITERS}"
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
