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
    @rows = []
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

  def replace!(content, rows = nil)
    @data = rows if rows

    # search for the table inside the content
    table_rgx = Regexp.new("(<table:table table:name=\"#{@name}.*?>.*?<\/table:table>)", "m")
    table_match = content.match(table_rgx)

    if table_match
      table = table_match[0]

      # extract the table from the content
      content.gsub!(table, "[TABLE_#{@name}]")

      # search for the table:row's
      row_rgx = Regexp.new("(<table:table-row.*?<\/table:table-row>)", "m")

      # use scan (instead of match) as the table can have more than one table-row (header and data)
      # and scan returns all matches
      row_match = table.scan(row_rgx)

      unless row_match.empty?

        replace_rows!(table, row_match)

        new_rows = ""

        # for each record
        @data.each do |_values|

          # generates one new row (table-row), based in the model extracted
          # from the original table
          tmp_row = get_next_row.dup

          # replace values in the model_row and stores in new_rows
          hash_gsub!(tmp_row, _values)

          new_rows << tmp_row
        end

        # replace back the lines into the table
        table.gsub!("[ROW_#{@name}]", new_rows)

      end # unless row_match.empty?

      # replace back the table into content
      if @data.empty?
        content.gsub!("[TABLE_#{@name}]", "")
      else
        content.gsub!("[TABLE_#{@name}]", table)
      end

    end # if table match

  end # replace

private

  def replace_rows!(table, rows)

    rows.delete_at(0) if @header # ignore the header

    @rows = rows.dup
    @row_cursor = 0

    # extract the rows from the table
    first = rows.delete_at(0)[0]
    table.gsub!(first, "[ROW_#{@name}]")

    rows.each do |r|
      table.gsub!(r[0], "")
    end

  end

  def get_next_row
    ret = @rows[@row_cursor]
    if @rows.size == @row_cursor + 1
      @row_cursor = 0
    else
      @row_cursor += 1
    end
    return ret[0]
  end

end

end