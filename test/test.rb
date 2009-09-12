require '../lib/odf-report'

col1 = []
col1 << {:name=>"name 01",  :id=>"01",  :address=>"this is address 01"}
col1 << {:name=>"name 03",  :id=>"03",  :address=>"this is address 03"}
col1 << {:name=>"name 02",  :id=>"02",  :address=>"this is address 02"}
col1 << {:name=>"name 04",  :id=>"04",  :address=>"this is address 04"}

col2 = []
col2 << {:name=>"josh harnet",  :id=>"02",    :address=>"testing <&> ",                 :phone=>99025668, :zip=>"90420-002"}
col2 << {:name=>"sandro",       :id=>"45",    :address=>"address with &",               :phone=>88774451, :zip=>"90490-002"}
col2 << {:name=>"ellen bicca",  :id=>"77",    :address=>"<address with escaped html>",  :phone=>77025668, :zip=>"94420-002"}

report = ODFReport.new("test.odt") do |r|

  r.add_field("HEADER_FIELD", "This &field was in the HEADER")

  r.add_field("TAG_01", "New tag")
  r.add_field("TAG_02", "TAG-2 -> New tag")

  r.add_table("TABLE_01", col1) do |row, item|
    row["FIELD_01"] = item[:id]
    row["FIELD_02"] = item[:name]
    row["FIELD_03"] = item[:address]
  end

  r.add_table("TABLE_02", col2) do |row, item|
    row["FIELD_04"] = item[:id]
    row["FIELD_05"] = item[:name]
    row["FIELD_06"] = item[:address]
    row["FIELD_07"] = item[:phone]
    row["FIELD_08"] = item[:zip]
  end

  r.add_image("graphics1", File.join(Dir.pwd, 'piriapolis.jpg'))

end

report.generate("result.odt")
