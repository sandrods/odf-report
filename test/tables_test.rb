require './lib/odf-report'
require 'ostruct'
require 'faker'
require 'launchy'


    hash = {}

    hash[:header_field] = "This field was in the HEADER"
    hash[:tag_01] = "New tag"
    hash[:tag_02] = "TAG-2 -> New tag"

    hash[:table_01] = []

    (1..40).each do |i|
      hash[:table_01] << {field_02: "name #{i}",  field_01: i,  address: "this is address #{i}"}
    end

    hash[:table_02] = []

    hash[:table_02] << {field_05: "josh harnet",   field_04: "02", field_06: "testing &>",              field_07: 99025668, field_08: "90420-002"}
    hash[:table_02] << {field_05: "sandro duarte", field_04: "45", field_06: "address with &",          field_07: 88774451, field_08: "90420-002"}
    hash[:table_02] << {field_05: "ellen bicca",   field_04: "77", field_06: "address with not",        field_07: 77025668, field_08: "90420-002"}
    hash[:table_02] << {field_05: "luiz garcia",   field_04: "88", field_06: "address with\nlinebreak", field_07: 27025668, field_08: "94520-025"}


    report = ODFReport::Report.new("test/templates/test_tables.odt")

    report.populate!(hash)

    report.save("test/result/new_test_tables.odt")
