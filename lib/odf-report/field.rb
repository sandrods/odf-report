module ODFReport

class Field

  DELIMITERS = ['[', ']']

  def initialize(opts, &block)
    @name = opts[:name]

    unless @value = opts[:value]

      if data_field = opts[:data_field]
        @block = lambda { |item| item.send(data_field)}
      elsif block_given?
        @block = block
      else
        @block = lambda { |item| item.send(@name)}
      end

    end

  end

  def get_value(data_item = nil)

    raise "Unable to retrieve value" unless @value || data_item

    @value || @block.call(data_item) || ''
  end

  def to_placeholder
    if DELIMITERS.is_a?(Array)
      "#{DELIMITERS[0]}#{@name.to_s.upcase}#{DELIMITERS[1]}"
    else
      "#{DELIMITERS}#{@name.to_s.upcase}#{DELIMITERS}"
    end
  end

end

end