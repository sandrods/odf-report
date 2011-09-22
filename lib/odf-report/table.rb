module ODFReport

class Table
  include HashGsub

  attr_accessor :fields, :rows, :name, :collection_field, :data, :header

  def initialize(opts)
    @name             = opts[:name]
    @collection_field = opts[:collection_field]
    @collection       = opts[:collection]
    @header           = opts[:header] || false

    @fields = {}
    @template_rows = []
    @data = []

    @inside_section = opts[:inside_section] || false
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

  def values(collection)
    ret = []
    collection.each do |item|
      row = {}
      @fields.each do |field_name, block1|
        row[field_name] = block1.call(item) || ''
      end
      ret << row
    end
    ret
  end

  def populate(collection)
    @data = values(collection)
  end

  def replace!(doc, rows = nil)
    @data = rows if rows

    if table = find_table_node(doc)

      @template_rows = table.xpath("table:table-row")

      @data.each do |_values|

        tmp_row = get_next_row

        replace_values!(tmp_row, _values)

        table.add_child(tmp_row)

      end

      @template_rows.each_with_index do |r, i|
        r.remove if (get_start_node..template_lenght) === i
      end

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

  def template_lenght
    @tl ||= @template_rows.size
  end

  def find_table_node(doc)

    prefix = @inside_section ? "" : "//"

    tables = doc.xpath("#{prefix}table:table[@table:name='#{@name}']")

    tables.empty? ? nil : tables.first

  end

end

end