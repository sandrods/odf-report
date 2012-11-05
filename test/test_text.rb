require '../lib/odf-report'
require 'ostruct'
require 'faker'

class Item
  attr_accessor :name, :text
  def initialize(_name,  _text)
    @name=_name
    @text=_text
  end
end

items = []
4.times do

  text = <<-HTML
    <p>#{Faker::Lorem.sentence} <em>#{Faker::Lorem.sentence}</em> #{Faker::Lorem.sentence}</p>
    <p>#{Faker::Lorem.sentence} <strong>#{Faker::Lorem.paragraph}</strong> #{Faker::Lorem.paragraph}</p>
    <p>#{Faker::Lorem.paragraph}</p>
    <blockquote>
      <p>#{Faker::Lorem.paragraph(10)}</p>
      <p>#{Faker::Lorem.paragraph}</p>
    </blockquote>
    <p style="margin: 150px">#{Faker::Lorem.paragraph(15)}</p>
    <p>#{Faker::Lorem.paragraph}</p>
  HTML

  items << Item.new(Faker::Name.name, text)

end

item = items.pop

report = ODFReport::Report.new("test_text.odt") do |r|

  r.add_field("TAG_01", Faker::Company.name)
  r.add_field("TAG_02", Faker::Company.catch_phrase)

  r.add_text(:main_text, item.text)

  r.add_section("SECTION_01", items) do |s|
    s.add_field(:name)
    s.add_text(:text)
  end

end

report.generate("./result/")