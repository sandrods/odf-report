require './test/helper'

class FullTest < Minitest::Test

  def setup

    @field_01 = Faker::Company.name
    @field_02 = Faker::Name.name

    @itens_01 = Item.get_list(3)

    report = ODFReport::Report.new("test/templates/test_full.odt") do |r|

      r.add_field(:field_01, @field_01)
      r.add_field(:field_02, @field_02)

      r.add_table('TABLE_01', @itens_01) do |t|
        t.add_column(:column_01, :id)
        t.add_column(:column_02, :name)
      end

      r.add_section('SECTION_01', @itens_01) do |t|
        t.add_field(:s01_field_01, :id)
        t.add_field(:s01_field_02, :name)
      end

    end

    report.generate("test/result/test_full.odt")

    @data = Inspector.new("test/result/test_full.odt")

  end

  def test_simple_fields

    refute_match "[FIELD_01]", @data.text
    refute_match "[FIELD_02]", @data.text

    assert_match @field_01, @data.text
    assert_match @field_02, @data.text

  end

  def test_simple_table

    table = @data.xml.xpath(".//table:table[@table:name='TABLE_01']").to_s

    @itens_01.each do |i|

      refute_match "[COLUMN_01]", table
      refute_match "[COLUMN_02]", table

      assert_match "[COLUMN_03]", table

      assert_match i.id.to_s, table
      assert_match i.name,    table
    end

  end

  def test_simple_section

    refute_match "[S01_FIELD_01]", @data.text
    refute_match "[S01_FIELD_02]", @data.text

    @itens_01.each_with_index do |item, idx|

      section = @data.xml.xpath(".//text:section[@text:name='SECTION_01_#{idx+1}']").to_s

      assert_match item.id.to_s, section
      assert_match item.name,    section
    end

  end


end
