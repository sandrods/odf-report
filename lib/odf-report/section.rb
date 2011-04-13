module ODFReport

class Section
  include HashGsub

  attr_accessor :fields, :tables, :data, :name, :subdocs

  def initialize(name)
    @name = name

    @fields = {}
    @data = []
    @tables = []
    @subdocs = {}
  end

  def add_subdoc(name, &block)
    @subdocs[name] = block
  end

  def add_field(name, field=nil, &block)
    if field
      @fields[name] = lambda { |item| item.send(field)}
    else
      @fields[name] = block
    end
  end

  def add_table(table_name, collection_field, opts={}, &block)
    opts.merge!(:name => table_name, :collection_field => collection_field)
    tab = Table.new(opts)
    yield(tab)
    @tables << tab

  end

  def populate(collection)

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

      #Replace the Subdocument tag with nil in the actual odt file
      @subdocs.each do |subdoc_name, block1|
        row[subdoc_name] = block1.call(item)
      end

      @data << row
    end

  end

  def replace!(content)

    # search for the table inside the content
    section_rgx = Regexp.new("(<text:section.*?text:name=\"#{@name}.*?>(.*?)<\/text:section>)", "m")
    section_match = content.match(section_rgx)

    if section_match
      section_full = section_match[0]
      section_content = section_match[2]

      # extract the section from the content
      content.gsub!(section_full, "[SECTION_#{@name}]")

      new_content = ""

      # for each record
      @data.each do |_values|

        # generates one new row (table-row), based in the model extracted
        # from the original table
        tmp_row = section_content.dup

        # replace values in the section_content and stores in new_content
        hash_gsub!(tmp_row, _values)

        @tables.each do |t|
          t.replace!(tmp_row, _values[:tables][t.name])
        end

        new_content << tmp_row
      end

      # replace back the table into content
      content.gsub!("[SECTION_#{@name}]", new_content)

    end # if table match

    #Replace the subdocuments
    subdoc_matches = content.scan(/(<text:p.*?>SD:[A-Za-z0-9\.\/\-_]*<\/text:p>)/)
    for match in subdoc_matches
      str = match[0].slice(0, match[0].rindex(/<text/))
      filename = match[0].scan(/SD:[A-Za-z0-9\.\/\-_]*/)[0].gsub("SD:","")
      xml = "<text:section text:name=\"#{filename}\" text:protected=\"true\"><text:section-source xlink:href=\"#{filename}\" text:filter-name=\"writer8\"/></text:section>"
      str = str + xml
      orig_tag = match[0].slice(match[0].rindex(/<text/), match[0].length - match[0].rindex(/<text/) )
      content.gsub!(orig_tag, xml)
    end

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
    else
      collection = item.send(collection_field)
    end

    return collection
  end

end

end