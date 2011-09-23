module ODFReport

class Report
  include HashGsub, FileOps

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

        doc = Nokogiri::XML(txt)

        replace_fields!(doc)
        replace_sections!(doc)
        replace_tables!(doc)

        txt.replace(doc.to_s)

        #TO_DO: make image use Nokogiri
        find_image_name_matches(txt)
      end

    end

    replace_images(new_file)

    new_file

  end

private

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

  def create_new_file(dest)

    if dest
      FileUtils.cp(@template, dest)
      new_file = dest
    else
      FileUtils.cp(@template, @tmp_dir)
      new_file = "#{@tmp_dir}/#{File.basename(@template)}"
    end

    return new_file
  end

  def find_image_name_matches(content)

    @images.each_pair do |image_name, path|
      #Search for the image placeholder path
      image_rgx = Regexp.new("draw:name=\"#{image_name}\".*?>.*<draw:image.*?xlink:href=\"([^\s]*)\" .*?\/>.*</draw:frame>", Regexp::MULTILINE)
      content_match = content.match(image_rgx)

      if content_match
        placeholder_path = content_match[1]
        @image_names_replacements[path] = File.basename(placeholder_path)
      end
    end

  end

  def replace_images(new_file)

    unless @images.empty?
      image_dir_name = "Pictures"
      FileUtils.mkdir(File.join("#{@tmp_dir}", image_dir_name))
      @image_names_replacements.each_pair do |path, template_image|
        template_image_path = File.join(image_dir_name, template_image)
        update_file_from_zip(new_file, template_image_path) do |content|
          content.replace File.read(path)
        end
      end
    end

  end

end

end
