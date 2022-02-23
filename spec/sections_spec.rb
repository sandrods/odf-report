RSpec.describe "Sections" do

  before(:context) do
    @itens = Item.get_list(3)

    report = ODFReport::Report.new("spec/templates/specs.odt") do |r|

      r.add_section('SECTION_01', @itens) do |t|
        t.add_field(:s01_field_01, :id)
        t.add_field(:s01_field_02, :name)
      end

      r.add_section('SECTION_02', []) do |t|
        t.add_field(:s02_field_01, :id)
        t.add_field(:s02_field_02, :name)
      end

      r.add_section('SECTION_03', nil) do |t|
        t.add_field(:s03_field_01, :id)
        t.add_field(:s03_field_02, :name)
      end

    end

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end

  it "should render section with collection" do
    @itens.each_with_index do |item, idx|
      section = @data.xml.at_xpath(".//text:section[#{idx+1}]").to_s

      expect(section).to match(item.id.to_s)
      expect(section).to match(item.name)
    end
  end

  it "should remove section with empty collection" do
    section = @data.xml.at_xpath("//text:section[@text:name='SECTION_02']")
    expect(section).to be_nil
  end

  it "should remove section with nil collection" do
    section = @data.xml.at_xpath("//text:section[@text:name='SECTION_03']")
    expect(section).to be_nil
  end


end
