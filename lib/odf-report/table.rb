module ODFReport

class Table
  include HashGsub

  attr_accessor :fields, :rows, :name, :collection_field, :data, :header, :parent

  def initialize(opts)
    @name             = opts[:name]
    @collection_field = opts[:collection_field]
    @collection       = opts[:collection]
    @header           = opts[:header] || false
    @parent           = opts[:parent]

    @fields = {}
    @template_rows = []
    @data = []

  end

  def add_column(name, field=nil, &block)
    if field
      @fields[name] = lambda { |item| item.send(field)}
    elsif block_given?
      @fields[name] = block
    else
      @fields[name] = lambda { |item| item.send(name)}
    end
  end

  def populate!(row)
    if row
      @data = get_collection_from_item(row, @collection_field)
    else
      @data = @collection
    end
  end

  def replace!(doc, row = nil)

    return unless table = find_table_node(doc)

    populate!(row)

    @template_rows = table.xpath("table:table-row")

    @data.each do |data_item|

      new_node = get_next_row

      replace_values!(new_node, data_item)

      table.add_child(new_node)

    end

    @template_rows.each_with_index do |r, i|
      r.remove if (get_start_node..template_lenght) === i
    end

  end # replace

private

  def replace_values!(new_node, data_item)
    node_hash_gsub!(new_node, get_fields_with_values(data_item))
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

  def get_next_row
    @row_cursor = get_start_node unless defined?(@row_cursor)

    ret = @template_rows[@row_cursor]
    if @template_rows.size == @row_cursor + 1
      @row_cursor = get_start_node
    else
      @row_cursor += 1
    end
    return ret.dup
  end

  def get_start_node
    @header ? 1 : 0
  end

  def reset
    @row_cursor = get_start_node
  end

  def template_lenght
    @tl ||= @template_rows.size
  end

  def find_table_node(doc)

    prefix = @parent ? "" : "//"

    tables = doc.xpath("#{prefix}table:table[@table:name='#{@name}']")

    tables.empty? ? nil : tables.first

  end

end

end