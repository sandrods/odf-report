module ODFReport
  class DataSource
    attr_reader :value

    def initialize(opts, &block)
      @value = opts[:value] || opts[:collection]
      @data_field = opts[:data_field] || opts[:collection_field] || opts[:name]
      @block = block
    end

    def set_source(record)
      @value = extract_value_from_item(record)
    end

    def each(&block)
      return unless @value
      @value.each(&block)
    end

    def empty?
      @value.nil? || @value.empty?
    end

    private

    def extract_value_from_item(record)
      if @block
        @block.call(record)

      elsif record.is_a?(Hash)
        key = @data_field
        record[key] || record[key.to_s.downcase] || record[key.to_s.upcase] || record[key.to_s.downcase.to_sym]

      elsif @data_field.is_a?(Array)
        execute_methods_on_item(record)

      elsif @data_field.is_a?(Hash) && record.respond_to?(@data_field.keys[0])
        record.send(@data_field.keys[0], @data_field.values[0])

      elsif record.respond_to?(@data_field)
        record.send(@data_field)

      else
        raise "Can't find [#{@data_field}] in this #{record.class}"

      end
    end

    def execute_methods_on_item(record)
      tmp = record.dup
      @data_field.each do |f|
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
