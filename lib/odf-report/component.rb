module ODFReport

  class Component

    def initialize(opts)
      @name             = opts[:name]
      @collection_field = opts[:collection_field]
      @collection       = opts[:collection]
      @parent           = opts[:parent]

      @fields = []
      @tables = []
      @texts = []
      @sections = []

      @template_rows = []
      @header           = opts[:header] || false
      @skip_if_empty    = opts[:skip_if_empty] || false  
    end
    
    def add_component(collection_field, klass, component_name, opts={}, &block)
      opts.merge!(:parent => self).merge!(collection_field)
      component = klass.new(opts, &block)
    end

    def add_field(name, data_field=nil, &block)
      @fields << Field.new({ name: name, data_field: data_field }, &block)
    end

    def add_text(name, data_field=nil, &block)
      @texts << Text.new({ name: name, data_field: data_field }, &block)
    end

    def add_table(name, collection_field, opts={}, &block)
      @tables << Table.new({ name: name, collection_field: collection_field, collection: collection_field }.merge(opts), &block)
      yield(Table.new(opts))
    end

    def add_section(name, collection, opts={}, &block)
      @sections << Section.new({ name: name, collection: collection }.merge(opts), &block)    
      yield(Section.new(opts))
    end
    
  end

end
