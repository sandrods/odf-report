module ODFReport

class Table
  include Nested

  def initialize(opts)
    @name             = opts[:name]
    @collection_field = opts[:collection_field]
    @collection       = opts[:collection]

    @fields = []
    @texts = []
    @tables = []
    @sections = []

    @template_rows = []
    @header           = opts[:header] || false
    @skip_if_empty    = opts[:skip_if_empty] || false
  end

  def replace!(doc, row = nil)

    return unless table = find_table_node(doc)

    @template_rows = table.xpath("table:table-row")

    @header = table.xpath("table:table-header-rows").empty? ? @header : false

    @collection = get_collection_from_item(row, @collection_field) if row

    if @skip_if_empty && @collection.empty?
      table.remove
      return
    end

    @collection.each do |data_item|

      new_node = get_next_row

      @sections.each { |s| s.replace!(new_node, data_item) }

      @tables.each    { |t| t.replace!(new_node, data_item) }

      @texts.each     { |t| t.replace!(new_node, data_item) }

      @fields.each    { |f| f.replace!(new_node, data_item) }

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

  def template_length
    @tl ||= @template_rows.size
  end

  def find_table_node(doc)

    tables = doc.xpath(".//table:table[@table:name='#{@name}']")

    tables.empty? ? nil : tables.first

  end

end

end
