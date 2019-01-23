module ODFReport
  class Template

    CONTENT_FILES = ['content.xml', 'styles.xml']

    attr_accessor :output_stream

    def initialize(template = nil, io: nil)
      raise "You must provide either a filename or an io: string" unless template || io
      raise "Template [#{template}] not found." unless template.nil? || ::File.exist?(template)

      @template = template
      @io = io
    end

    def update_content
      @buffer = Zip::OutputStream.write_buffer do |out|
        @output_stream = out
        yield self
      end
    end

    def update_files(&block)

      get_template_entries.each do |entry|

        next if entry.directory?

        entry.get_input_stream do |is|

          data = is.sysread

          if CONTENT_FILES.include?(entry.name)
            process_entry(data, &block)
          end

          @output_stream.put_next_entry(entry.name)
          @output_stream.write data

        end
      end

    end

    def data
      @buffer.string
    end

    private

    def get_template_entries

      if @template
        Zip::File.open(@template)
      else
        Zip::File.open_buffer(@io.force_encoding("ASCII-8BIT"))
      end

    end

    def process_entry(entry)
      doc = Nokogiri::XML(entry)
      yield doc
      entry.replace(doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML))
    end

  end
end
