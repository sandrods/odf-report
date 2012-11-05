require '../lib/odf-report'
require 'ostruct'

class Item
  attr_accessor :name, :sid, :children, :subs
  def initialize(_name, _sid, _children=[], _subs=[])
    @name=_name
    @sid=_sid
    @children=_children
    @subs=_subs
  end
end

subs1 = []
subs1 << Item.new("SAWYER", 1, %w(Your bones don't break))
subs1 << Item.new("HURLEY", 2, %w(Your cells react to bacteria and viruses))
subs1 << Item.new("LOCKE",  3, %W(Do you see any Teletubbies in here))

subs2 = []
subs2 << Item.new("SLOANE",  21, %w(Praesent hendrerit lectus sit amet))
subs2 << Item.new("JACK",    22, %w(Donec nec est eget dolor laoreet))
subs2 << Item.new("MICHAEL", 23, %W(Integer elementum massa at nulla placerat varius))

items = []
items << Item.new("LOST",           '007', %w(sawyer juliet hurley locke jack freckles), subs1)
items << Item.new("ALIAS",          '302', %w(sidney sloane jack michael marshal))
items << Item.new("GREY'S ANATOMY", '220', %w(meredith christina izzie alex george), subs2)
items << Item.new("BREAKING BAD",   '556', %w(pollos gus mike heisenberg))

report = ODFReport::Report.new("test_sub_sections.odt") do |r|

  r.add_field("TAG_01", Time.now)
  r.add_field("TAG_02", "TAG-2 -> New tag")

  r.add_section("SECTION_01", items) do |s|

    s.add_field('NAME') { |i| i.name }

    s.add_field('SID', :sid)

    s.add_table('TABLE_S1', :children, :header=>true) do |t|
      t.add_column('NAME1') { |item| "-> #{item}" }
      t.add_column('INV')   { |item| item.to_s.reverse.upcase }
    end

    s.add_section('SUB_01', :subs) do |r|
      r.add_field("FIRST_NAME", :name)
      r.add_table('IPSUM_TABLE', :children, :header => true) do |t|
        t.add_column('IPSUM_ITEM') { |i| i }
      end
    end

  end

end

report.generate("./result/")