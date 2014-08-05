module ODFReport
  class Component

    def self.for(key, value, doc)
      Component.new(key, value, doc).component
    end

    def initialize(key, value, doc)
      @key = key.to_s.upcase; @value = value; @doc = doc
    end

    def component

      return Field.new(@key, @value)    if is_field?
      return Text.new(@key, @value)     if is_text?
      return Table.new(@key, @value)    if is_table?
      return Section.new(@key, @value)  if is_section?

      return NullComponent

    end

    def is_field?
      !array? && !is_text?
    end

    def is_text?
      @value =~ /<.+?>/ && !array?
    end

    def is_table?
      array? && !@doc.xpath(".//table:table[@table:name='#{@key}']").empty?
    end

    def is_section?
      array? && !@doc.xpath(".//text:section[@text:name='#{@key}']").empty?
    end

    def array?
      @value.kind_of? Array
    end

    class NullComponent
      def self.replace!(doc)
      end
    end

  end
end
