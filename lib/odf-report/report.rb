module ODFReport

class Report
  include HashGsub, FileOps

  attr_accessor :values, :tables, :images, :sections

  def initialize(template_name, &block)
    @template = template_name

    @values = {}
    @tables = []
    @images = {}
    @sections = []

    @tmp_dir = Dir.tmpdir + "/" + random_filename(:prefix=>'odt_')
    Dir.mkdir(@tmp_dir) unless File.exists? @tmp_dir

    yield(self)

  end

  def add_section(section_name, collection, &block)
    sec = Section.new(section_name)
    @sections << sec

    yield(sec)

    sec.populate(collection)

  end

  def add_field(field_tag, value)
    @values[field_tag] = value || ''
  end

  def add_table(table_name, collection, opts={}, &block)
    opts[:name] = table_name
    tab = Table.new(opts)
    yield(tab)
    @tables << tab

    tab.populate(collection)

  end

  def add_image(name, path)
    @images[name] = path
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
        replace_image_refs!(txt)
        replace_sections!(txt)

      end

    end

    unless @images.empty?
      image_dir_name = "Pictures"
      dir = File.join("#{@tmp_dir}", image_dir_name)
      add_files_to_dir(@images.values, dir)
      add_dir_to_zip(new_file, dir, image_dir_name)
    end

    new_file

  end

private

  def replace_fields!(content)
    hash_gsub!(content, @values)
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

  def replace_image_refs!(content)
    @images.each_pair do |image_name, path|
      #Set the new image path
      new_path = File.join("Pictures", File.basename(path))
      #Search for the image
      image_rgx = Regexp.new("draw:name=\"#{image_name}\".*?><draw:image.*?xlink:href=\"([^\s]*)\" .*?/></draw:frame>")
      content_match = content.match(image_rgx)
      if content_match
        replace_path = content_match[1]
        content.gsub!(content_match[0], content_match[0].gsub(replace_path, new_path))
      end
    end
  end

end

end