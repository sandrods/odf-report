RSpec.describe "Tables" do

  before(:context) do

    report = ODFReport::Report.new("spec/specs.odt") do |r|

      r.add_table('TABLE_02', [], skip_if_empty: true) do |t|
        t.add_column(:column_01, :id)
        t.add_column(:column_02, :name)
      end

      r.add_section('TABLE_03', []) do |t|
        t.add_field(:s01_field_01, :id)
        t.add_field(:s01_field_02, :name)
      end

    end

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end

  context "with Empty collection" do

    it "should remove table if required" do

      table2 = @data.xml.xpath(".//table:table[@table:name='TABLE_02']")
      table3 = @data.xml.xpath(".//table:table[@table:name='TABLE_03']")

      expect(table2).to be_nil
      expect(table3).not_to be_nil
    end

  end

end
