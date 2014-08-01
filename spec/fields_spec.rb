RSpec.describe "Fields" do

  before(:context) do

    @field_01 = Faker::Company.name
    @field_02 = Faker::Name.name

    @itens_01 = Item.get_list(3)

    report = ODFReport::Report.new("spec/specs.odt") do |r|

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

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end


  it "simple fields replacement" do

    expect(@data.text).not_to match(/\[FIELD_01\]/)
    expect(@data.text).not_to match(/\[FIELD_02\]/)

    expect(@data.text).to match @field_01
    expect(@data.text).to match @field_02

  end

  it "table columns replacement" do

    table = @data.xml.xpath(".//table:table[@table:name='TABLE_01']").to_s

    @itens_01.each do |item|

      expect(table).not_to match(/\[COLUMN_01\]/)
      expect(table).not_to match(/\[COLUMN_02\]/)
      expect(table).to match(/\[COLUMN_03\]/)

      expect(table).to match(item.id)
      expect(table).to match(item.name)

    end

  end

  it "section fields replacement" do

    expect(@data.text).not_to match(/\[S01_FIELD_01\]/)
    expect(@data.text).not_to match(/\[S01_FIELD_02\]/)

    @itens_01.each_with_index do |item, idx|

      section = @data.xml.xpath(".//text:section[@text:name='SECTION_01_#{idx+1}']").to_s

      expect(section).to match(item.id)
      expect(section).to match(item.name)

    end

  end

end
