require '../lib/odf-report'

col1 = []
col1 << {:nome=>"name 01",  :id=>"01",  :ender=>"this is address 01"}
col1 << {:nome=>"name 03",  :id=>"03",  :ender=>"this is address 03"}
col1 << {:nome=>"name 02",  :id=>"02",  :ender=>"this is address 02"}

col2 = []
col2 << {:nome=>"josh harnet",  :id=>"02",    :ender=>"testing <&> ",                 :fone=>99025668, :cep=>"90420-002"}
col2 << {:nome=>"sandro",       :id=>"45",    :ender=>"address with &",               :fone=>88774451, :cep=>"90490-002"}
col2 << {:nome=>"ellen bicca",  :id=>"77",    :ender=>"<address with escaped html>",  :fone=>77025668, :cep=>"94420-002"}

report = ODFReport.new("test.odt") do |r|

  r.add_field("CAMPO_CAB", "This field was in the HEADER")

  r.add_field("TAG_01", "New tag")
  r.add_field("TAG_02", "TAG-2 -> New tag")

  r.add_table("TABELA_01", col1) do |row, item|
    row["CAMPO_01"] = item[:id]
    row["CAMPO_02"] = item[:nome]
    row["CAMPO_03"] = item[:ender]
  end

  r.add_table("TABELA_02", col2) do |row, item|
    row["CAMPO_04"] = item[:id]
    row["CAMPO_05"] = item[:nome]
    row["CAMPO_06"] = item[:ender]
    row["CAMPO_07"] = item[:fone]
    row["CAMPO_08"] = item[:cep]
  end
  
end

report.generate("result.odt")