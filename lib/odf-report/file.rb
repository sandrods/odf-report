module ODFReport

  class File

    attr_accessor :output_stream

    MANIFEST_FILE = "META-INF/manifest.xml"

    def initialize(template)
      raise "Template [#{template}] not found." unless ::File.exist? template
      @template = template
    end

    def update_content
      @buffer = Zip::OutputStream.write_buffer do |out|
        @output_stream = out
        yield self
      end
    end

    def update_files(*content_files, &block)

      Zip::File.open(@template) do |file|

        file.each do |entry|

          next if entry.directory?

          entry.get_input_stream do |is|

            data = is.sysread

            if content_files.include?(entry.name)
              yield data
            end

            if MANIFEST_FILE.eql? entry.name
              @manifest_data = data
            else
              @output_stream.put_next_entry(entry.name)
              @output_stream.write data
            end

          end

        end

      end

    end

    def data
      @buffer.string
    end

    def update_manifest_file(&block)

      yield @manifest_data

      @output_stream.put_next_entry(MANIFEST_FILE)
      @output_stream.write @manifest_data
    end

  end
end

