RSpec.describe "Nested Tables" do
  before(:context) do
    @items = [
      Item.new(nil, "LOST").tap { |i|
        i.sid = "007"
        i.children = %w[sawyer juliet hurley]
      },
      Item.new(nil, "ALIAS").tap { |i|
        i.sid = "302"
        i.children = %w[sidney sloane jack]
      },
      Item.new(nil, "BREAKING BAD").tap { |i|
        i.sid = "556"
        i.children = %w[gus mike heisenberg]
      }
    ]

    report = ODFReport::Report.new("spec/templates/tables/nested_tables.odt") do |r|
      r.add_field("TAG_01", "Test Tag 1")
      r.add_field("TAG_02", "Test Tag 2")

      r.add_table("TABLE_MAIN", @items) do |s|
        s.add_column("NAME") { |i| i.name }
        s.add_column("SID", :sid)

        s.add_table("TABLE_S1", :children, header: true) do |t|
          t.add_column("NAME1") { |item| "-> #{item}" }
          t.add_column("INV") { |item| item.to_s.reverse.upcase }
        end
      end
    end

    report.generate("spec/result/tables/nested_tables.odt")

    @data = Inspector.new("spec/result/tables/nested_tables.odt")
  end

  it "renders outer table rows" do
    table = @data.xml.at_xpath(".//table:table[@table:name='TABLE_MAIN']").to_s

    @items.each do |item|
      expect(table).to include(item.name)
      expect(table).to include(item.sid)
    end
  end

  it "renders nested table content" do
    xml = @data.xml.to_s

    @items.each do |item|
      item.children.each do |child|
        expect(xml).to include("-&gt; #{child}")
        expect(xml).to include(child.reverse.upcase)
      end
    end
  end

  it "replaces report-level fields" do
    expect(@data.text).to include("Test Tag 1")
    expect(@data.text).to include("Test Tag 2")
  end
end
