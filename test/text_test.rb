require './lib/odf-report'
require 'faker'


  class Item
    attr_accessor :name, :inner_text
    def initialize(_name,  _text)
      @name=_name
      @inner_text=_text
    end
  end



    @items = []
    3.times do

      text = <<-HTML
        <p>#{Faker::Lorem.sentence} <em>#{Faker::Lorem.sentence}</em> #{Faker::Lorem.sentence}</p>
        <p>#{Faker::Lorem.sentence} <strong>#{Faker::Lorem.paragraph(sentence_count: 3)}</strong> NO FORMAT <strong>#{Faker::Lorem.paragraph(sentence_count: 2)}</strong> #{Faker::Lorem.sentence}</p>
        <p>#{Faker::Lorem.paragraph}</p>
        <blockquote>
          <p>#{Faker::Lorem.paragraph}</p>
          <p>#{Faker::Lorem.paragraph}</p>
        </blockquote>
        <p style="margin: 150px">#{Faker::Lorem.paragraph}</p>
        <p>#{Faker::Lorem.paragraph}</p>
      HTML

      @items << Item.new(Faker::Name.name, text)

    end


    item = @items.pop

    report = ODFReport::Report.new("test/templates/test_text.odt") do |r|

      r.add_field("TAG_01", Faker::Company.name)
      r.add_field("TAG_02", Faker::Company.catch_phrase)

      r.add_text(:main_text, item.inner_text)

      r.add_section("SECTION_01", @items) do |s|
        s.add_field(:name)
        s.add_text(:inner_text) { |i| i.inner_text }
      end

      r.add_table("TABLE", @items) do |s|
        s.add_field(:field, :name)
        s.add_text(:text, :inner_text)
      end

    end

    report.generate("test/result/test_text.odt")
