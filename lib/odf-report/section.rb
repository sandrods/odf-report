module ODFReport

  class Section
    include Fields, Nested

    attr_accessor :fields, :tables, :data, :name, :collection_field, :parent

    def initialize(opts)
      @name             = opts[:name]
      @collection_field = opts[:collection_field]
      @collection       = opts[:collection]
      @parent           = opts[:parent]

      @fields = []
      @texts = []

      @tables = []
      @sections = []
    end

    def add_field(name, data_field=nil, &block)
      opts = {:name => name, :data_field => data_field}
      field = Field.new(opts, &block)
      @fields << field

    end

    def add_text(name, data_field=nil, &block)
      opts = {:name => name, :data_field => data_field}
      field = Text.new(opts, &block)
      @texts << field

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

        @texts.each do |t|
          t.replace!(new_section, data_item)
        end

        @tables.each do |t|
          t.replace!(new_section, data_item)
        end

        @sections.each do |s|
          s.replace!(new_section, data_item)
        end

        replace_fields!(new_section, data_item)

        section.before(new_section)

      end

      section.remove

    end # replace_section

  private

    def find_section_node(doc)

      sections = doc.xpath(".//text:section[@text:name='#{@name}']")

      sections.empty? ? nil : sections.first

    end

  end

end


