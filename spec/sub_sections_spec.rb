RSpec.describe "Sub Sections" do
  before(:context) do
    subs1 = [
      Item.new(nil, "SAWYER").tap { |i|
        i.sid = 1
        i.children = %w[bones break mine]
      },
      Item.new(nil, "HURLEY").tap { |i|
        i.sid = 2
        i.children = %w[cells react virus]
      }
    ]

    subs2 = [
      Item.new(nil, "SLOANE").tap { |i|
        i.sid = 21
        i.children = %w[hendrerit lectus amet]
      },
      Item.new(nil, "JACK").tap { |i|
        i.sid = 22
        i.children = %w[donec dolor laoreet]
      }
    ]

    @items = [
      Item.new(nil, "LOST").tap { |i|
        i.sid = "007"
        i.children = []
        i.subs = subs1
      },
      Item.new(nil, "GREY'S ANATOMY").tap { |i|
        i.sid = "220"
        i.children = nil
      },
      Item.new(nil, "ALIAS").tap { |i|
        i.sid = "302"
        i.children = nil
        i.subs = subs2
      },
      Item.new(nil, "BREAKING BAD").tap { |i|
        i.sid = "556"
        i.children = []
      }
    ]

    report = ODFReport::Report.new("spec/templates/sub_sections.odt") do |r|
      r.add_field("TAG_01", "Sub Section Test")
      r.add_field("TAG_02", "TAG-2 value")

      r.add_section("SECTION_01", @items) do |s|
        s.add_field("NAME") { |i| i.name }
        s.add_field("SID", :sid)

        s.add_section("SUB_01", :subs) do |sub|
          sub.add_field("FIRST_NAME", :name)
          sub.add_table("IPSUM_TABLE", :children, header: true) do |t|
            t.add_column("IPSUM_ITEM") { |i| i }
          end
        end
      end
    end

    report.generate("spec/result/sub_sections.odt")

    @data = Inspector.new("spec/result/sub_sections.odt")
  end

  it "renders top-level section for each item" do
    @items.each do |item|
      expect(@data.text).to include(item.name)
    end
  end

  it "renders sub-section content for items with subs" do
    expect(@data.text).to include("SAWYER")
    expect(@data.text).to include("HURLEY")
    expect(@data.text).to include("SLOANE")
    expect(@data.text).to include("JACK")
  end

  it "renders nested table inside sub-sections" do
    expect(@data.text).to include("bones")
    expect(@data.text).to include("cells")
    expect(@data.text).to include("hendrerit")
    expect(@data.text).to include("donec")
  end

  it "handles items with nil or empty subs" do
    # GREY'S ANATOMY and BREAKING BAD have nil/empty subs
    # They should still render their top-level fields
    expect(@data.text).to include("GREY'S ANATOMY")
    expect(@data.text).to include("BREAKING BAD")
  end
end
