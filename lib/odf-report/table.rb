module ODFReport

class Table
  include HashGsub, Nested

  attr_accessor :fields, :rows, :name, :collection_field, :data, :header, :parent

  def initialize(opts)
    @name             = opts[:name]
    @collection_field = opts[:collection_field]
    @collection       = opts[:collection]
    @parent           = opts[:parent]

    @fields = {}

    @template_rows = []
    @header           = opts[:header] || false
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
    @collection = get_collection_from_item(row, @collection_field) if row
  end

  def replace!(doc, row = nil)

    return unless table = find_table_node(doc)

    populate!(row)

    @template_rows = table.xpath("table:table-row")

    @collection.each do |data_item|

      new_node = get_next_row

      replace_values!(new_node, data_item)

      table.add_child(new_node)

    end

    @template_rows.each_with_index do |r, i|
      r.remove if (get_start_node..template_length) === i
    end

  end # replace

private

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

  def template_length
    @tl ||= @template_rows.size
  end

  def find_table_node(doc)

    tables = doc.xpath(".//table:table[@table:name='#{@name}']")

    tables.empty? ? nil : tables.first

  end

end

end
