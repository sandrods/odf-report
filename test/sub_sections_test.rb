require './lib/odf-report'
require 'ostruct'
require 'faker'
require 'launchy'


    hash = {}

    subs1 = []
    subs1 <<  { first_name: "SAWYER", ipsum_table: %w(Your bones don't break).map { |n| { ipsum_item: n } } }
    subs1 <<  { first_name: "HURLEY", ipsum_table: %w(Your cells react to bacteria and viruses).map { |n| { ipsum_item: n } } }
    subs1 <<  { first_name: "LOCKE",  ipsum_table: %W(Do you see any Teletubbies in here).map { |n| { ipsum_item: n } } }

    subs2 = []
    subs2 <<  { first_name: "SLOANE",  ipsum_table: %w(Praesent hendrerit lectus sit amet).map { |n| { ipsum_item: n } } }
    subs2 <<  { first_name: "JACK",    ipsum_table: %w(Donec nec est eget dolor laoreet).map { |n| { ipsum_item: n } } }
    subs2 <<  { first_name: "MICHAEL", ipsum_table: %W(Integer elementum massa at nulla placerat varius).map { |n| { ipsum_item: n } } }


    hash[:tag_01] = Time.now
    hash[:tag_02] = "TAG-2 -> New tag"

    hash[:section_01] = []
    hash[:section_01] << { name: "LOST",           sid: '007', sub_01: subs1 }
    hash[:section_01] << { name: "ALIAS",          sid: '302', sub_01: [] }
    hash[:section_01] << { name: "GREY'S ANATOMY", sid: '220', sub_01: subs2 }
    hash[:section_01] << { name: "BREAKING BAD",   sid: '556', sub_01: [] }

    report = ODFReport::Report.new("test/templates/test_sub_sections.odt")

    report.populate!(hash).save("test/result/new_test_sub_sections.odt")
