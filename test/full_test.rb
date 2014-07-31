require './test/helper'

class FullTest < Minitest::Test

  def setup

    report = ODFReport::Report.new("test/templates/test_full.odt") do |r|

      @field_01 = Faker::Company.name
      @field_02 = Faker::Name.name

      r.add_field(:field_01, @field_01)
      r.add_field(:field_02, @field_02)

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

end
