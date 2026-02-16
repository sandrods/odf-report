module ODFReport
  class DataSource
    def initialize(opts, &block)
      @value = opts[:value]
      @field = opts[:value] || opts[:name]
      @block = block
    end

    def value
      if @record
        extract_value_from(@record)
      else
        @value
      end
    end

    def set_source(record)
      @record = record
    end

    def each(&block)
      return unless value
      value.each(&block)
    end

    def empty?
      value.nil? || value.empty?
    end

    private

    def extract_value_from(record)
      if @block
        @block.call(record)

      elsif record.is_a?(Hash)
        record[@field] || record[@field.to_s.downcase] || record[@field.to_s.upcase] || record[@field.to_s.downcase.to_sym]

      elsif @field.is_a?(Array)
        execute_methods_on(record)

      elsif @field.is_a?(Hash) && record.respond_to?(@field.keys[0])
        record.send(@field.keys[0], @field.values[0])

      elsif record.respond_to?(@field)
        record.send(@field)

      else
        raise "Can't find [#{@field}] in this #{record.class}"

      end
    end

    def execute_methods_on(record)
      tmp = record.dup
      @field.each do |f|
        tmp = if f.is_a?(Hash)
          tmp.send(f.keys[0], f.values[0])
        else
          tmp.send(f)
        end
      end
      tmp
    end
  end
end
