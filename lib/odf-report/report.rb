module ODFReport

class Report
  include HashGsub, FileOps, Images

  attr_accessor :values, :tables, :images, :sections

  def initialize(template_name, &block)
    @template = template_name

    @values = {}
    @tables = []
    @images = {}
    @image_names_replacements = {}
    @sections = []

    @tmp_dir = File.join(Dir.tmpdir, random_filename(:prefix=>'odt_'))
    Dir.mkdir(@tmp_dir) unless File.exists? @tmp_dir

    yield(self)

  end

  def add_field(field_tag, value='')
    @values[field_tag] = value
  end

  def add_table(table_name, collection, opts={}, &block)
    opts.merge!(:name => table_name, :collection => collection)
    tab = Table.new(opts)
    @tables << tab

    yield(tab)
  end

  def add_section(section_name, collection, opts={}, &block)
    opts.merge!(:name => section_name, :collection => collection)
    sec = Section.new(opts)
    @sections << sec

    yield(sec)
  end

  def add_image(name, path)
    @images[name] = path
  end

  def generate(dest = nil)

    new_file = create_new_file(dest)

    %w(content.xml styles.xml).each do |content_file|

      update_file_from_zip(new_file, content_file) do |txt|

        parse_document(txt) do |doc|

          replace_fields!(doc)
          replace_sections!(doc)
          replace_tables!(doc)

        end

        #TO_DO: make image use Nokogiri
        find_image_name_matches(txt)
      end

    end

    replace_images(new_file)

    new_file

  end

private

  def parse_document(txt)
    doc = Nokogiri::XML(txt)
    yield doc
    txt.replace(doc.to_s)
  end

  def replace_fields!(content)
    node_hash_gsub!(content, @values)
  end

  def replace_tables!(content)
    @tables.each do |table|
      table.replace!(content)
    end
  end

  def replace_sections!(content)
    @sections.each do |section|
      section.replace!(content)
    end
  end

end

end
