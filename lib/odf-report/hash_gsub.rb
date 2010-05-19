module ODFReport

  module HashGsub

    def hash_gsub!(_text, hash_of_values)
      hash_of_values.each do |key, val|
        _text.gsub!("[#{key.to_s.upcase}]", html_escape(val))
      end
    end

    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }

    def html_escape(s)
      return "" unless s
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end

  end

end