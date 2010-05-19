module ODFReport

  module FileOps

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

    def add_files_to_dir(files, dir)
      FileUtils.mkdir(dir)
      files.each do |path|
        FileUtils.cp(path, File.join(dir, File.basename(path)))
      end
    end

    def add_dir_to_zip(zip_file, dir, entry)
      Zip::ZipFile.open(zip_file, true) do |z|
        Dir["#{dir}/**/*"].each { |f| z.add("#{entry}/#{File.basename(f)}", f) }
      end
    end

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

  end

end