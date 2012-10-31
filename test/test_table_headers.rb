require '../lib/odf-report'
require 'ostruct'
require 'faker'

class Item
  attr_accessor :name, :mail
  def initialize(_name,  _mail)
    @name=_name
    @mail=_mail
  end
end

items = []
50.times do

  items << Item.new(Faker::Name.name, Faker::Internet.email)

end

report = ODFReport::Report.new("test_table_headers.odt") do |r|

  r.add_table("TABLE_01", items, :header => true) do |s|
    s.add_column(:name)
    s.add_column(:mail)
  end

  r.add_table("TABLE_02", items, :header => true) do |s|
    s.add_column(:name)
    s.add_column(:mail)
  end

  r.add_table("TABLE_03", items) do |s|
    s.add_column(:name)
    s.add_column(:mail)
  end

end

report.generate("./result/")