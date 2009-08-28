require 'rubygems'
require 'zip/zipfilesystem'
require 'fileutils'

class ODFReport
  
  def initialize(template_name, &block)
    @template = template_name
    @data={:values=>{}, :tables=>{}}

    @tmp_dir = Dir.tmpdir + "/" + random_filename(:prefix=>'odt_')
    Dir.mkdir(@tmp_dir) unless File.exists? @tmp_dir

    yield self
  end

  def add_field(field_tag, value)
    @data[:values][field_tag] = value
  end

  def add_table(table_tag, collection, &block)

    @data[:tables][table_tag] = []

    collection.each do |item|
      row = {}
      yield(row, item)
      @data[:tables][table_tag] << row
    end
    
  end

  def generate(dest = nil)
    
    if dest

      FileUtils.cp(@template, dest)
      new_file = dest

    else

      FileUtils.cp(@template, @tmp_dir)
      new_file = "#{@tmp_dir}/#{File.basename(@template)}"

    end

    %w(content.xml styles.xml).each do |content_file|
    
      update_file_from_zip(new_file, content_file) do |txt|

        replace_fields!(txt) 
        replace_tables!(txt)      

      end
    
    end

    new_file

  end

private

  def update_file_from_zip(zip_file, content_file, &block)

    Zip::ZipFile.open(zip_file) do |z|            
      cont = "#{@tmp_dir}/#{content_file}"
      
      z.extract(content_file, cont)
    
      txt = ''

      File.open(cont, "r") do |f|
        txt = f.read
      end

      yield(txt)

      File.open(cont, "w") do |f|
         f.write(txt)
      end

      z.replace(content_file, cont)
    end

  end


  def replace_fields!(content)
    hash_gsub!(content, @data[:values])
  end


  def replace_tables!(content)

    @data[:tables].each do |table_name, records|

      # search for the table inside the content
      table_rgx = Regexp.new("(<table:table table:name=\"#{table_name}.*?>.*?<\/table:table>)", "m")
      table_match = content.match(table_rgx)

      if table_match
        table = table_match[0]

        # extract the table from the content
        content.gsub!(table, "[TABLE_#{table_name}]")

        # search for the table:row's
        row_rgx = Regexp.new("(<table:table-row.*?<\/table:table-row>)", "m")

        # use scan (instead of match) as the table can have more than one table-row (header and data)
        # and scan returns all matches
        row_match = table.scan(row_rgx)

        unless row_match.empty?

          # If there more than one line in the table, takes the second entry (row_match[1]) 
          # since the first one represents the column header. 
          # If there just one line, takes the first line. Besides, since the entry is an Array itself,
          # takes the entry's first element ( entry[0] )
          model_row = (row_match[1] || row_match[0])[0]

          # extract the row from the table
          table.gsub!(model_row, "[ROW_#{table_name}]")

          new_rows = ""

          # for each record
          records.each do |_values|

            # generates one new row (table-row), based in the model extracted
            # from the original table
            tmp_row = model_row.dup

            # replace values in the model_row and stores in new_rows
            hash_gsub!(tmp_row, _values)

            new_rows << tmp_row
          end 

          # replace back the lines into the table
          table.gsub!("[ROW_#{table_name}]", new_rows)

        end # unless row_match.empty?

        # replace back the table into content
        content.gsub!("[TABLE_#{table_name}]", table)

      end # if table match

    end # tables each

  end # replace_tables

  def hash_gsub!(_text, hash_of_values)
    hash_of_values.each do |key, val|
      _text.gsub!("[#{key.to_s.upcase}]", html_escape(val)) unless val.nil?
    end
  end

  def random_filename(opts={})
    opts = {:chars => ('0'..'9').to_a + ('A'..'F').to_a + ('a'..'f').to_a,
            :length => 24, :prefix => '', :suffix => '',
            :verify => true, :attempts => 10}.merge(opts)
    opts[:attempts].times do
      filename = ''
      opts[:length].times { filename << opts[:chars][rand(opts[:chars].size)] }
      filename = opts[:prefix] + filename + opts[:suffix]
      return filename unless opts[:verify] && File.exists?(filename)
    end
    nil
  end

  HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }

  def html_escape(s)
    return "" unless s
    s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
  end

end