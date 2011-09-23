module ODFReport

  class Section
    include HashGsub, Nested

    attr_accessor :fields, :tables, :data, :name, :collection_field, :parent

    def initialize(opts)
      @name             = opts[:name]
      @collection_field = opts[:collection_field]
      @collection       = opts[:collection]
      @parent           = opts[:parent]

      @fields = {}

      @tables = []
      @sections = []
    end

    def add_field(name, field=nil, &block)
      if field
        @fields[name] = lambda { |item| item.send(field)}
      elsif block_given?
        @fields[name] = block
      else
        @fields[name] = lambda { |item| item.send(name)}
      end
    end

    def add_table(table_name, collection_field, opts={}, &block)
      opts.merge!(:name => table_name, :collection_field => collection_field, :parent => self)
      tab = Table.new(opts)
      @tables << tab

      yield(tab)
    end

    def add_section(section_name, collection_field, opts={}, &block)
      opts.merge!(:name => section_name, :collection_field => collection_field, :parent => self)
      sec = Section.new(opts)
      @sections << sec

      yield(sec)
    end

    def populate!(row)
      @collection = get_collection_from_item(row, @collection_field) if row
    end

    def replace!(doc, row = nil)

      return unless section = find_section_node(doc)

      template = section.dup

      populate!(row)

      @collection.each do |data_item|
        new_section = template.dup

        replace_values!(new_section, data_item)

        @tables.each do |t|
          t.replace!(new_section, data_item)
        end

        @sections.each do |s|
          s.replace!(new_section, data_item)
        end

        section.before(new_section)

      end

      section.remove

    end # replace_section

  private

    def find_section_node(doc)

      prefix = @parent ? "" : "//"

      sections = doc.xpath("#{prefix}text:section[@text:name='#{@name}']")

      sections.empty? ? nil : sections.first

    end

  end

end