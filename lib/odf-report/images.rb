module ODFReport

  module Images

    IMAGE_DIR_NAME = "Pictures"

    def find_image_name_matches(content)

      @images.each_pair do |image_name, path|
        if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
          placeholder_path = node.attribute('href').value
          @image_names_replacements[path] = ::File.join(IMAGE_DIR_NAME, ::File.basename(placeholder_path))
        end
      end

    end

    def replace_images(file)

      before_replace_iamges(file)

      return if @images.empty?

      FileUtils.mkdir(::File.join(file.tmp_dir, IMAGE_DIR_NAME))

      @image_names_replacements.each_pair do |path, template_image|

        file.update(template_image) do |content|
          content.replace ::File.read(path)
        end

      end

    end # replace_images


    def before_replace_iamges(file)
      Zip::File.open(file.path) { |zipfile|
        doc = manifest_xml_doc(zipfile)
        need_add_nodes = []
        need_add_files(zipfile).each do |image_path|
          tmp_path = ::File.join('Pictures',::File.basename(image_path))
          zipfile.add(tmp_path, image_path) { true }

          need_add_nodes << generate_xml_node(doc, tmp_path)
        end

        need_add_nodes.each{|n| doc.root.add_child(n) }

        update_manifest(doc, zipfile)
      }
    end

    def generate_xml_node(doc, tmp_path)
      node = Nokogiri::XML::Node.new('manifest:file-entry', doc)
      node.set_attribute('manifest:full-path', tmp_path)
      mime_type = case ::File.extname(tmp_path)
                  when "png"
                    "image/png"
                  when "gif"
                    "image/gif"
                  when "jpeg", "jpg"
                    "image/jpeg"
                  end
      node.set_attribute("manifest:medit-type",  mime_type)
      return node
    end

    def manifest_xml_doc(zipfile)
      entry = zipfile.read(manifest_path)
      Nokogiri::XML.parse(entry)
    end

    def update_manifest(doc, zipfile)
      tmp_mainfest_path = ::File.join(file.tmp_dir, 'mainfest.xml')
      ::File.open(tmp_mainfest_path, 'w') do |f|
        f.puts doc.to_xml
      end

      zipfile.replace(manifest_path, tmp_mainfest_path)
    end

    def manifest_path
      ::File.join('META-INF', 'manifest.xml')
    end

    def need_add_files(zipfile)
      need_add_files = []
      content = zipfile.read('content.xml')
      content_doc = Nokogiri::XML(content)
      content_doc.xpath("//draw:frame/draw:image").each do |node|
        path = node.attribute('href').value
        if path !~ /^Pictures\//
          need_add_files << path
        end
      end
      return need_add_files
    end
  end

end
