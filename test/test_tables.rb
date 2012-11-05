require '../lib/odf-report'
require 'ostruct'

col1 = []
(1..40).each do |i|
  col1 << {:name=>"name #{i}",  :idx=>i,  :address=>"this is address #{i}"}
end


col2 = []
col2 << OpenStruct.new({:name=>"josh harnet",   :idx=>"02", :address=>"testing <&> ",                 :phone=>99025668, :zip=>"90420-002"})
col2 << OpenStruct.new({:name=>"sandro duarte", :idx=>"45", :address=>"address with &",               :phone=>88774451, :zip=>"90490-002"})
col2 << OpenStruct.new({:name=>"ellen bicca",   :idx=>"77", :address=>"<address with escaped html>",  :phone=>77025668, :zip=>"94420-002"})
col2 << OpenStruct.new({:name=>"luiz garcia",   'idx'=>"88", :address=>"address with\nlinebreak",      :phone=>27025668, :zip=>"94520-025"})

col3, col4, col5 = [], [], []

report = ODFReport::Report.new("test_tables.odt") do |r|

  r.add_field("HEADER_FIELD", "This field was in the HEADER")

  r.add_field("TAG_01", "New tag")
  r.add_field("TAG_02", "TAG-2 -> New tag")

  r.add_table("TABLE_01", col1, :header=>true) do |t|
    t.add_column(:field_01, :idx)
    t.add_column(:field_02, :name)
    t.add_column(:address)
  end

  r.add_table("TABLE_02", col2) do |t|
    t.add_column(:field_04, :idx)
    t.add_column(:field_05, :name)
    t.add_column(:field_06, 'address')
    t.add_column(:field_07, :phone)
    t.add_column(:field_08, :zip)
  end

  r.add_table("TABLE_03", col3, :header=>true) do |t|
    t.add_column(:field_01, :idx)
    t.add_column(:field_02, :name)
    t.add_column(:field_03, :address)
  end

  r.add_table("TABLE_04", col4, :header=>true, :skip_if_empty => true) do |t|
    t.add_column(:field_01, :idx)
    t.add_column(:field_02, :name)
    t.add_column(:field_03, :address)
  end

  r.add_table("TABLE_05", col5) do |t|
    t.add_column(:field_01, :idx)
    t.add_column(:field_02, :name)
    t.add_column(:field_03, :address)
  end

  r.add_image("graphics1", File.join(Dir.pwd, 'piriapolis.jpg'))
  r.add_image("graphics2", File.join(Dir.pwd, 'rails.png'))

end

report.generate("./result/")