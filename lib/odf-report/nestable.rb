module ODFReport
  class Nestable
    include Composable

    def initialize(opts)
      @name = opts[:name]

      @data_source = DataSource.new(opts)

      init_replacers
    end

    alias_method :add_column, :add_field

    def set_source(data_item)
      @data_source.set_source(data_item)
      self
    end

    def wrap_with_ns(node)
      <<-XML
       <root xmlns:draw="a" xmlns:xlink="b" xmlns:text="c" xmlns:table="d">#{node.to_xml}</root>
      XML
    end

    private

    def value_key = :data_field

    def collection_key = :collection_field
  end
end
