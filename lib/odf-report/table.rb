module ODFReport
  class Table < Nestable
    def initialize(opts)
      super

      @template_rows = []
      @header = opts[:header] || false
      @skip_if_empty = opts[:skip_if_empty] || false
    end

    def replace!(doc)
      return unless (table = find_table_node(doc))

      @template_rows = table.xpath("table:table-row")

      @header = table.xpath("table:table-header-rows").empty? ? @header : false

      if @skip_if_empty && @data_source.empty?
        table.remove
        return
      end

      @data_source.each do |record|
        new_node = next_row

        replace_with!(record, new_node)

        table.add_child(new_node.to_xml)
      end

      @template_rows.each_with_index do |r, i|
        r.remove if (start_index..template_length) === i
      end
    end # replace

    private

    def next_row
      @row_cursor = start_index unless defined?(@row_cursor)

      row = @template_rows[@row_cursor]
      @row_cursor = (@row_cursor + 1 < @template_rows.size) ? @row_cursor + 1 : start_index

      deep_clone(row)
    end

    def start_index
      @header ? 1 : 0
    end

    def template_length
      @template_length ||= @template_rows.size
    end

    def find_table_node(doc)
      doc.at_xpath("//table:table[@table:name='#{@name}']")
    end

    def deep_clone(node)
      Nokogiri::XML(wrap_with_ns(node)).at_xpath("//table:table-row")
    end
  end
end
