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
        # Block transform: add_field(:name) { |item| item.name.upcase }
        @block.call(record)

      elsif record.is_a?(Hash)
        # Hash lookup: tries symbol, lowercase string, uppercase string, lowercase symbol
        record[@field] || record[@field.to_s.downcase] || record[@field.to_s.upcase] || record[@field.to_s.downcase.to_sym]

      elsif @field.is_a?(Array)
        # Method chain: add_field(:name, [:company, :name]) calls record.company.name
        execute_methods_on(record)

      elsif @field.is_a?(Hash) && record.respond_to?(@field.keys[0])
        # Method with argument: add_field(:name, {full_name: :upcase}) calls record.full_name(:upcase)
        record.send(@field.keys[0], @field.values[0])

      elsif record.respond_to?(@field)
        # Simple method call: add_field(:name, :email) calls record.email
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
