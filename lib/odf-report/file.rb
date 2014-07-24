module ODFReport
  class File

    attr_accessor :data, :output_stream

    def initialize(template)
      raise "Template [#{template}] not found." unless ::File.exists? template
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

          unless entry.directory?

            data = entry.get_input_stream.read

            if content_files.include?(entry.name)
              yield data
            end

            @output_stream.put_next_entry(entry.name)
            @output_stream.write data
          end

        end

      end

    end

    def data
      @buffer.string
    end

  end
end
