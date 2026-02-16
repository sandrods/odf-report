module ODFReport
  module Composable
    def add_field(name, value = nil, &block)
      fields << Field.new({name: name, value: value}, &block)
    end

    def add_text(name, value = nil, &block)
      texts << Text.new({name: name, value: value}, &block)
    end

    def add_image(name, value = nil, &block)
      images << Image.new({name: name, value: value}, &block)
    end

    def add_table(table_name, collection, opts = {})
      opts[:name] = table_name
      opts[:value] = collection

      tab = Table.new(opts)
      tables << tab

      yield(tab)
    end

    def add_section(section_name, collection, opts = {})
      opts[:name] = section_name
      opts[:value] = collection

      sec = Section.new(opts)
      sections << sec

      yield(sec)
    end

    def all_images
      (images.map(&:files) + sections.map(&:all_images) + tables.map(&:all_images)).flatten
    end

    private

    def fields = @fields ||= []

    def texts = @texts ||= []

    def tables = @tables ||= []

    def sections = @sections ||= []

    def images = @images ||= []
  end
end
