module ODFReport

class Report

  def initialize(template_name = nil, io: nil)

    @template = ODFReport::Template.new(template_name, io: io)

    @texts = []
    @fields = []
    @tables = []
    @images = []
    @sections = []

    yield(self) if block_given?

  end

  def add_field(field_tag, value='')
    opts = {:name => field_tag, :value => value}
    field = Field.new(opts)
    @fields << field
  end

  def add_text(field_tag, value='')
    opts = {:name => field_tag, :value => value}
    text = Text.new(opts)
    @texts << text
  end

  def add_table(table_name, collection, opts={})
    opts.merge!(:name => table_name, :collection => collection)
    tab = Table.new(opts)
    @tables << tab

    yield(tab)
  end

  def add_section(section_name, collection, opts={})
    opts.merge!(:name => section_name, :collection => collection)
    sec = Section.new(opts)
    @sections << sec

    yield(sec)
  end

  def add_image(image_name, value='')
    opts = {:name => image_name, :value => value}
    image = Image.new(opts)
    @images << image
  end

  def generate(dest = nil)

    @template.update_content do |file|

      file.update_files do |doc|

        @sections.each { |s| s.replace!(doc) }
        @tables.each   { |t| t.replace!(doc) }

        @texts.each    { |t| t.replace!(doc) }
        @fields.each   { |f| f.replace!(doc) }

        @images.each   { |i| i.replace!(doc) }

      end

      @images.each { |i| i.include_image_file(file) }

      file.update_manifest do |content|
        @images.each { |i| i.include_manifest_entry(content) }
      end

    end



    if dest
      File.open(dest, "wb") { |f| f.write(@template.data) }
    else
      @template.data
    end

  end

end

end
