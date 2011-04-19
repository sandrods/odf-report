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

    doc = Nokogiri::XML(content)

    tables = doc.search("//table:table[@table:name='#{@name}']")

    unless tables.empty?
      table = tables.first

      @rows = table.search("//table:table[@table:name='#{@name}']//table:table-row")

      @row_cursor = get_start_node

      @data.each do |_values|

        # generates one new row (table-row), based in the model extracted
        # from the original table
        tmp_row = get_next_row

        # replace values in the model_row and stores in new_rows
        node_hash_gsub!(tmp_row, _values)

        table.add_child(tmp_row)

      end

      @rows.each_with_index do |r, i|
        r.remove unless (@header && i==0)
      end

      content.replace(doc.to_s)

    end

  end # replace

private

  def get_next_row
    ret = @rows[@row_cursor]
    if @rows.size == @row_cursor + 1
      @row_cursor = get_start_node
    else
      @row_cursor += 1
    end
    return ret.dup
  end

  def get_start_node
    @header ? 1 : 0
  end

end

end