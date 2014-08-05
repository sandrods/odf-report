module ODFReport

class Report
  include Images

  def initialize(template_name)

    @file = ODFReport::File.new(template_name)
    @images = {}
    @image_names_replacements = {}

  end

  def populate!(hash)

    @file.update_content do |file|

      file.update_files('content.xml', 'styles.xml') do |txt|

        parse_document(txt) do |doc|

          hash.each do |key, value|
            Component.for(key, value, doc).replace!(doc)
          end

          #find_image_name_matches(doc)
          #avoid_duplicate_image_names(doc)

        end

      end

      #replace_images(file)

    end

    self

  end

  def add_image(name, path)
    @images[name] = path
  end

  def save(dest)
    ::File.open(dest, "wb") {|f| f.write(@file.data) }
  end

  def data
    @file.data
  end

private

  def parse_document(txt)
    doc = Nokogiri::XML(txt)
    yield doc
    txt.replace(doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML))
  end

end

end
