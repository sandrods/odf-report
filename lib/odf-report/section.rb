module ODFReport

class Section
  include HashGsub

  attr_accessor :fields, :tables, :data, :name

  def initialize(name)
    @name = name

    @fields = {}
    @data = []
    @tables = []
  end

  def add_field(name, field=nil, &block)
    if field
      @fields[name] = lambda { |item| item.send(field)}
    else
      @fields[name] = block
    end
  end

  def add_table(table_name, collection_field, opts={}, &block)
    opts.merge!(:name => table_name, :collection_field => collection_field, :inside_section => true)
    tab = Table.new(opts)
    yield(tab)
    @tables << tab

  end

  def populate(collection)
    if collection.is_a?(Hash)
      populate_from_hash(collection)
    else
      populate_from_array(collection)
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

      @data << row
    end

  end

  def populate_from_hash(hash)

    hash.each do |hash_key, hash_value|
      row = {}
      @fields.each do |field_name, block1|
        row[field_name] = block1.call(hash_key)
      end

      row[:tables] = {}
      @tables.each do |table|
        if table.collection_field == :hash_value
          row[:tables][table.name] = table.values(hash_value)
        else
          collection = get_collection_from_item(hash_key, table.collection_field)
          row[:tables][table.name] = table.values(collection)
        end
      end

      @data << row
    end

  end

  def replace!(doc)

    sections = doc.xpath("//text:section[@text:name='#{@name}']")

    return if sections.empty?

    section = sections.first

    template = section.dup

    @data.each do |_values|
      new_section = template.dup

      replace_values!(new_section, _values)

      @tables.each do |t|
        t.replace!(new_section, _values[:tables][t.name])
      end

      section.before(new_section)

    end

    section.remove

  end # replace_section

private

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

end

end