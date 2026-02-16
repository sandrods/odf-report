module ODFReport
  module Composable
    def add_field(name, value = nil, &block)
      opts = {name: name}
      opts[value_key] = value
      fields << Field.new(opts, &block)
    end

    def add_text(name, value = nil, &block)
      opts = {name: name}
      opts[value_key] = value
      texts << Text.new(opts, &block)
    end

    def add_image(name, value = nil, &block)
      opts = {name: name}
      opts[value_key] = value
      images << Image.new(opts, &block)
    end

    def add_table(table_name, collection, opts = {})
      opts[:name] = table_name
      opts[collection_key] = collection

      tab = Table.new(opts)
      tables << tab

      yield(tab)
    end

    def add_section(section_name, collection, opts = {})
      opts[:name] = section_name
      opts[collection_key] = collection

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
