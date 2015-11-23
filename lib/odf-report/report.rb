module ODFReport

class Report
  include Images

  def initialize(template_name, &block)

    @file = ODFReport::File.new(template_name)

    @texts = []
    @fields = []
    @tables = []
    @images = {}
    @image_names_replacements = {}
    @sections = []

    yield(self)

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

  def add_image(name, path)
    @images[name] = path
  end

  def generate(dest = nil)

    @file.update_content do |file|

      file.update_files('content.xml', 'styles.xml') do |txt|

        parse_document(txt) do |doc|

          @sections.each { |s| s.replace!(doc) }
          @tables.each   { |t| t.replace!(doc) }

          @texts.each    { |t| t.replace!(doc) }
          @fields.each   { |f| f.replace!(doc) }

          find_image_name_matches(doc)
          avoid_duplicate_image_names(doc)

          yield(doc) if block_given?

        end

      end

      replace_images(file)

    end

    if dest
      ::File.open(dest, "wb") {|f| f.write(@file.data) }
    else
      @file.data
    end

  end

private

  def parse_document(txt)
    doc = Nokogiri::XML(txt)
    yield doc
    txt.replace(doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML))
  end

end

end
