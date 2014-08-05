module ODFReport

class Table

  def initialize(name, value)
    @name = name.to_s.upcase
    @collection = value
    @template_rows = []

    # to do
    @skip_if_empty = false
    @header = false
  end

  def replace!(doc)
    return unless table = find_table_node(doc)

    @template_rows = table.xpath("table:table-row")

    @header = table.xpath("table:table-header-rows").empty? ? @header : false

    if @skip_if_empty && @collection.empty?
      table.remove
      return
    end

    @collection.each do |record|

      new_node = get_next_row

      record.each do |key, value|
        Component.for(key, value, new_node).replace!(new_node)
      end

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
