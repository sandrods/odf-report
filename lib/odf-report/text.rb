module ODFReport

  class Text

    DELIMITERS = ['[', ']']

    attr_accessor :name, :parser

    def initialize(opts)
      @name       = opts[:name]
      @value      = opts[:value]
      @parser     = Parser::Default.new(@value)
    end

    def replace!(doc)

      return unless text = find_text_node(doc)

      @parser.parse(text)

      @parser.paragraphs.each do |p|
        node = text.dup
        node['text:style-name'] = p[:style] if p[:style]
        node.children = p[:text]
        text.before(node)
      end

      text.remove

    end

    private

    def to_placeholder
      if DELIMITERS.is_a?(Array)
        "#{DELIMITERS[0]}#{@name.to_s.upcase}#{DELIMITERS[1]}"
      else
        "#{DELIMITERS}#{@name.to_s.upcase}#{DELIMITERS}"
      end
    end

    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{to_placeholder}']")
      texts.empty? ? nil : texts.first
    end

  end

end