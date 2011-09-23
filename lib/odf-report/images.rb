module ODFReport

  module Images

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