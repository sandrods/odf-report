module ODFReport

class Report
  include HashGsub, FileOps

  attr_accessor :values, :tables, :images, :sections, :settings

  def initialize(template_name, &block)
    @template = template_name

    @values = {}
    @tables = []
    @images = {}
    @image_names_replacements = {}
    @sections = []
    @settings = {}

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

  def change_setting(name, value)
    @settings[name] = [value[0], value[1]]
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
        find_image_name_matches(txt)
        replace_sections!(txt)

      end

    end

    update_file_from_zip(new_file, 'settings.xml') do |txt|
      replace_settings!(txt)
    end

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

    new_file

  end

private

  def replace_settings!(content)
    puts "Changed settings: #{@settings}"
    @settings.each do |key, value|
      setting_rgx = Regexp.new(/(<config:config-item config:name="#{key}" config:type="[a-z]*">[A-Za-z0-9]*<\/config:config-item>)/)
      old_setting = content.scan(setting_rgx)[0][0]
      new_setting = "<config:config-item config:name=\"#{key}\" config:type=\"#{value[1]}\">#{value[0]}</config:config-item>"
      content.gsub!(old_setting, new_setting)
    end
  end

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

  def find_image_name_matches(content)
    @images.each_pair do |image_name, path|
      #Search for the image placeholder path
      image_rgx = Regexp.new("draw:name=\"#{image_name}\".*?><draw:image.*?xlink:href=\"([^\s]*)\" .*?/></draw:frame>")
      content_match = content.match(image_rgx)
      if content_match
        placeholder_path = content_match[1]
        @image_names_replacements[path] = File.basename(placeholder_path)
      end
    end
  end
end

end
