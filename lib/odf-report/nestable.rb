module ODFReport
  class Nestable

    def initialize(opts)
      @name = opts[:name]

      @data_source = DataSource.new(opts)

      @fields   = []
      @texts    = []
      @tables   = []
      @sections = []
      @images   = []

    end

    def set_source(data_item)
      @data_source.set_source(data_item)
      self
    end

    def add_field(name, data_field=nil, &block)
      opts = { name: name, data_field: data_field }
      @fields << Field.new(opts, &block)
    end
    alias_method :add_column, :add_field

    def add_text(name, data_field=nil, &block)
      opts = {name: name, data_field: data_field}
      @texts << Text.new(opts, &block)
    end

    def add_image(name, data_field=nil, &block)
      opts = {name: name, data_field: data_field}
      @images << Image.new(opts, &block)
    end

    def add_table(table_name, collection_field, opts={})
      opts.merge!(name: table_name, collection_field: collection_field)
      tab = Table.new(opts)
      @tables << tab

      yield(tab)
    end

    def add_section(section_name, collection_field, opts={})
      opts.merge!(name: section_name, collection_field: collection_field)
      sec = Section.new(opts)
      @sections << sec

      yield(sec)
    end

    def all_images
      (@images.map(&:files) + @sections.map(&:all_images) + @tables.map(&:all_images)).flatten
    end

    def wrap_with_ns(node)
      <<-XML
       <root xmlns:draw="a" xmlns:xlink="b" xmlns:text="c" xmlns:table="d">#{node.to_xml}</root>
      XML
    end
    
  end
end
