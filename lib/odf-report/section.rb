module ODFReport

class Section
  include HashGsub

  attr_accessor :fields, :tables, :data, :name, :collection_field, :parent

  def initialize(opts)

    @name             = opts[:name]
    @collection_field = opts[:collection_field]
    @collection       = opts[:collection]
    @parent           = opts[:parent]

    @fields = {}
    @data = []
    @tables = []
    @sections = []
  end

  def add_field(name, field=nil, &block)
    if field
      @fields[name] = lambda { |item| item.send(field)}
    else
      @fields[name] = block
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
    if row
      @data = get_collection_from_item(row, @collection_field)
    else
      @data = @collection
    end
  end

  def populate_from_array(collection)

    collection.each do |item|
      row = {}
      @fields.each do |field_name, block1|
        row[field_name] = block1.call(item)
      end

      row[:tables] = {}
      @tables.each do |table|
        collection = get_collection_from_item(item, table.collection_field)
        row[:tables][table.name] = table.values(collection)
      end

      row[:sections] = {}
      @sections.each do |section|
        collection = get_collection_from_item(item, section.collection_field)
        row[:sections][section.name] = section.get_data(collection)
      end

      @data << row

    end

  end


  def replace!(doc, row = nil)

    return unless section = find_section_node(doc)

    template = section.dup

    populate!(row)

    @data.each do |data_item|
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

  def replace_values!(new_section, data_item)
    node_hash_gsub!(new_section, get_fields_with_values(data_item))
  end

  def get_fields_with_values(data_item)

    fields_with_values = {}
    @fields.each do |field_name, block1|
      fields_with_values[field_name] = block1.call(data_item) || ''
    end

    fields_with_values
  end

  def get_collection_from_item(item, collection_field)

    if collection_field.is_a?(Array)
      tmp = item.dup
      collection_field.each do |f|
        if f.is_a?(Hash)
          tmp = tmp.send(f.keys[0], f.values[0])
        else
          tmp = tmp.send(f)
        end
      end
      collection = tmp
    elsif collection_field.is_a?(Hash)
      collection = item.send(collection_field.keys[0], collection_field.values[0])
    else
      collection = item.send(collection_field)
    end

    return collection
  end

  def find_section_node(doc)

    prefix = @parent ? "" : "//"

    sections = doc.xpath("#{prefix}text:section[@text:name='#{@name}']")

    sections.empty? ? nil : sections.first

  end

end

end