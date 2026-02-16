RSpec.describe "Table Headers" do
  before(:context) do
    @items = (1..10).map do
      Item.new(Faker::Number.number(digits: 5), Faker::Name.name)
    end

    report = ODFReport::Report.new("spec/templates/tables/table_headers.odt") do |r|
      r.add_table("TABLE_01", @items, header: true) do |s|
        s.add_column(:name)
        s.add_column(:id) { |i| i.id }
      end

      r.add_table("TABLE_02", @items, header: true) do |s|
        s.add_column(:name)
        s.add_column(:id) { |i| i.id }
      end

      r.add_table("TABLE_03", @items) do |s|
        s.add_column(:name)
        s.add_column(:id) { |i| i.id }
      end
    end

    report.generate("spec/result/tables/table_headers.odt")

    @data = Inspector.new("spec/result/tables/table_headers.odt")
  end

  it "renders all rows in table with header" do
    table = @data.xml.at_xpath(".//table:table[@table:name='TABLE_01']").to_s

    @items.each do |item|
      expect(table).to include(item.name)
    end
  end

  it "renders all rows in table without header flag" do
    table = @data.xml.at_xpath(".//table:table[@table:name='TABLE_03']").to_s

    @items.each do |item|
      expect(table).to include(item.name)
    end
  end

  it "renders multiple tables with same data" do
    table1 = @data.xml.at_xpath(".//table:table[@table:name='TABLE_01']").to_s
    table2 = @data.xml.at_xpath(".//table:table[@table:name='TABLE_02']").to_s

    @items.each do |item|
      expect(table1).to include(item.name)
      expect(table2).to include(item.name)
    end
  end
end
