# coding: UTF-8
require './lib/odf-report'
require 'faker'
require 'launchy'


  hash = {}

  hash[:header_field] = "This field was in the HEADER"
  hash[:tag_01] = Time.now
  hash[:tag_02] = "TAG-2 -> New tag"


  col = []
  col << { name: "LOST",           sid: '007', table_s1: %w(sawyer juliet hurley locke jack freckles).map { |n| { name1: "-> #{n}", inv: n.reverse.upcase}} }
  col << { name: "ALIAS",          sid: '302', table_s1: %w(sidney sloane jack michael marshal).map       { |n| { name1: "-> #{n}", inv: n.reverse.upcase}} }
  col << { name: "GREY'S ANATOMY", sid: '220', table_s1: %w(meredith christina izzie alex george).map     { |n| { name1: "-> #{n}", inv: n.reverse.upcase}} }
  col << { name: "BREAKING BAD",   sid: '556', table_s1: %w(pollos gus mike heisenberg).map               { |n| { name1: "-> #{n}", inv: n.reverse.upcase}} }

  hash[:table_main] = { _type: 'TABLE', collection: col, header: true }

  report = ODFReport::Report.new("test/templates/test_nested_tables.odt")

  report.populate!(hash).save("test/result/new_test_nested_tables.odt")
