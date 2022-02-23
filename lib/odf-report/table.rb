module ODFReport
  class Table < Nestable

    def initialize(opts)
      super(opts)

      @template_rows = []
      @header           = opts[:header] || false
      @skip_if_empty    = opts[:skip_if_empty] || false
    end

    def replace!(doc)
      return unless table = find_table_node(doc)

      @template_rows = table.xpath("table:table-row")

      @header = table.xpath("table:table-header-rows").empty? ? @header : false

      if @skip_if_empty && @data_source.empty?
        table.remove
        return
      end

      @data_source.each do |record|

        new_node = get_next_row

        @tables.each    { |n| n.set_source(record).replace!(new_node) }
        @sections.each  { |n| n.set_source(record).replace!(new_node) }
        @texts.each     { |n| n.set_source(record).replace!(new_node) }
        @fields.each    { |n| n.set_source(record).replace!(new_node) }
        @images.each    { |n| n.set_source(record).replace!(new_node) }

        table.add_child(new_node.to_xml)

      end

      @template_rows.each_with_index do |r, i|
        r.remove if (get_start_node..template_length) === i
      end

    end # replace

  private

    def get_next_row
      if @template_rows.size == 1

        ret = @template_rows.first

      else
        @row_cursor = get_start_node unless defined?(@row_cursor)

        ret = @template_rows[@row_cursor]
        if @template_rows.size == @row_cursor + 1
          @row_cursor = get_start_node
        else
          @row_cursor += 1
        end
      end

      return deep_clone(ret)
    end

    def get_start_node
      @header ? 1 : 0
    end

    def template_length
      @tl ||= @template_rows.size
    end

    def find_table_node(doc)
      doc.at_xpath("//table:table[@table:name='#{@name}']")
    end

    def deep_clone(node)
      Nokogiri::XML(wrap_with_ns(node)).at_xpath("//table:table-row")
    end

  end
end
