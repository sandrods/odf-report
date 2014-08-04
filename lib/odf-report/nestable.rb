module ODFReport
  class Nestable

    def initialize(opts)
      @name = opts[:name]

      @data_source = DataSource.new(opts)

      @fields = []
      @texts = []
      @tables = []
      @sections = []

    end

    def set_source(data_item)
      @data_source.set_source(data_item)
      self
    end

    def add_field(name, data_field=nil, &block)
      opts = {:name => name, :data_field => data_field}
      field = Field.new(opts, &block)
      @fields << field

    end
    alias_method :add_column, :add_field

    def add_text(name, data_field=nil, &block)
      opts = {:name => name, :data_field => data_field}
      field = Text.new(opts, &block)
      @texts << field

    end

    def add_table(table_name, collection_field, opts={})
      opts.merge!(:name => table_name, :collection_field => collection_field)
      tab = Table.new(opts)
      @tables << tab

      yield(tab)
    end

    def add_section(section_name, collection_field, opts={})
      opts.merge!(:name => section_name, :collection_field => collection_field)
      sec = Section.new(opts)
      @sections << sec

      yield(sec)
    end

  end
end
