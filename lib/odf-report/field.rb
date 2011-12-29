module ODFReport

class Field

  DELIMITERS = ['[', ']']

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

  def get_value(data_item = nil)
    @value || @block.call(data_item) || ''
  end

  def to_placeholder
    if DELIMITERS.is_a?(Array)
      "#{DELIMITERS[0]}#{@name.to_s.upcase}#{DELIMITERS[1]}"
    else
      "#{DELIMITERS}#{@name.to_s.upcase}#{DELIMITERS}"
    end
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

end

end