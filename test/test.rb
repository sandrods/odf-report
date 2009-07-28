require '../lib/odf-report'

col1 = []
col1 << {:nome=>"Campo zero um", :id=>"Campo dois", :ender=>"tres tres"}
col1 << {:nome=>"zero um", :id=>"dois", :ender=>"tres"}
col1 << {:nome=>"Campo um", :id=>"Campo erthe dois", :ender=>"tres tres  tres"}

col2 = []
col2 << {:nome=>"Campo zero um", :id=>"Campo dois", :ender=>"tres tres", :fone=>99025668, :cep=>"90420-002"}
col2 << {:nome=>"sandro", :id=>"45", :ender=>"minha casa", :fone=>88774451, :cep=>"90490-002"}
col2 << {:nome=>"ellen bicca", :id=>"77", :ender=>"casa dela", :fone=>77025668, :cep=>"94420-002"}

report = ODFReport.new("test.odt") do |r|

  r.add_field("CAMPO_CAB", "Este campo estava no cabecalho")

  r.add_field("TAG_01", "Nova tag")
  r.add_field("TAG_02", "TAG-2 -> Nova tag")

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