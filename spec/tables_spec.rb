RSpec.describe "Tables" do

  before(:context) do

    report = ODFReport::Report.new("spec/specs.odt") do |r|

      r.add_table('TABLE_02', []) do |t|
        t.add_column(:column_01, :id)
        t.add_column(:column_02, :name)
      end

      r.add_table('TABLE_03', [], skip_if_empty: true) do |t|
        t.add_column(:column_01, :id)
        t.add_column(:column_02, :name)
      end

    end

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end

  context "with Empty collection" do

    it "should not remove table" do
      table2 = @data.xml.xpath(".//table:table[@table:name='TABLE_02']")
      expect(table2).not_to be_empty
    end

    it "should remove table if required" do
      table3 = @data.xml.xpath(".//table:table[@table:name='TABLE_03']")
      expect(table3).to be_empty
    end

  end

end
