require '../lib/odf-report'
require 'ostruct'

col1 = []
(1..6).each do |i|
  col1 << OpenStruct.new({:name=>"name #{i}",  :idx=>i,  :address=>"this is address #{i}"})
end


col2 = []
col2 << OpenStruct.new({:name=>"josh harnet",   :idx=>"02", :address=>"testing <&> ",                 :phone=>99025668, :zip=>"90420-002"})
col2 << OpenStruct.new({:name=>"sandro duarte", :idx=>"45", :address=>"address with &",               :phone=>88774451, :zip=>"90490-002"})
col2 << OpenStruct.new({:name=>"ellen bicca",   :idx=>"77", :address=>"<address with escaped html>",  :phone=>77025668, :zip=>"94420-002"})
col2 << OpenStruct.new({:name=>"luiz garcia",   :idx=>"88", :address=>"address with\nlinebreak",      :phone=>27025668, :zip=>"94520-025"})

report = ODFReport::Report.new("test.odt") do |r|

  r.add_field("HEADER_FIELD", "This field was in the HEADER")

  r.add_field("TAG_01", "New tag")
  r.add_field("TAG_02", "TAG-2 -> New tag")

  r.add_table("TABLE_01", col1, :header=>true) do |t|
    t.add_column(:field_01, :idx)
    t.add_column(:field_02, :name)
    t.add_column(:field_03, :address)
  end

  r.add_table("TABLE_02", col2) do |t|
    t.add_column(:field_04, :idx)
    t.add_column(:field_05, :name)
    t.add_column(:field_06, :address)
    t.add_column(:field_07, :phone)
    t.add_column(:field_08, :zip)
  end

  image = File.join(Dir.pwd, 'piriapolis.jpg')
  r.add_image("graphics1", image)

end

report.generate("result.odt")

# class Item
#   attr_accessor :name, :sid, :children
#   def initialize(_name, _sid, _children=[])
#     @name=_name
#     @sid=_sid
#     @children=_children
#   end
# end
# 
# items = []
# items << Item.new("Dexter Morgan",  '007', %w(sawyer juliet hurley locke jack freckles))
# items << Item.new("Danny Crane",   '302', %w(sidney sloane jack michael marshal))
# items << Item.new("Coach Taylor",  '220', %w(meredith christina izzie alex george))
# 
# report = ODFReport::Report.new("sections.odt") do |r|
# 
#   r.add_field("TAG_01", "New tag")
#   r.add_field("TAG_02", "TAG-2 -> New tag")
# 
#   r.add_section("SECTION_01", items) do |s|
# 
#     s.add_field('NAME') do |i|
#       i.name
#     end
# 
#     s.add_field('SID', :sid)
# 
#     s.add_table('TABLE_S1', :children, :header=>true) do |t|
#       t.add_column('NAME1') { |item| "-> #{item}" }
#       t.add_column('INV')   { |item| item.to_s.reverse.upcase }
#     end
#   end
# 
# end
# 
# report.generate("section_result.odt")