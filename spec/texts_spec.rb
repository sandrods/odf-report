RSpec.describe "Texts" do
  before(:context) do
    @text1 = <<-HTML
      <p>This is some text in a paragraph</p>
    HTML

    @text2 = <<-HTML
      <p>Text before line break <br> text after line break</p>
    HTML

    @text3 = <<-HTML
      <p>Text before entities
         Maur&iacute;cio
         Text after entities</p>
    HTML

    report = ODFReport::Report.new("spec/templates/specs.odt") do |r|
      r.add_text(:text1, @text1)
      r.add_text(:text2, @text2)
      r.add_text(:text3, @text3)
    end

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")
  end

  it "simple text replacement" do
    expect(@data.text).to include "This is some text in a paragraph"
  end

  it "text replacement with <br>" do
    expect(@data.text).to include "Text before line break"
    expect(@data.text).to include "text after line break"
  end

  it "text replacement with html entities" do
    expect(@data.text).to include "Text before entities"
    expect(@data.text).to include "Maurício"
    expect(@data.text).to include "Text after entities"
  end
end

RSpec.describe "Texts in sections and tables" do
  before(:context) do
    @section_html = "<p>Section text with <strong>bold</strong> and <em>italic</em></p>"
    @table_html = "<p>Table text with <strong>bold</strong> content</p>"
    @main_html = <<-HTML
      <p>Main text paragraph</p>
      <blockquote><p>Quoted paragraph</p></blockquote>
      <p style="margin: 100px">Styled paragraph</p>
    HTML

    @items = Item.get_list(2)

    report = ODFReport::Report.new("test/templates/test_text.odt") do |r|
      r.add_field("TAG_01", "Tag One")
      r.add_field("TAG_02", "Tag Two")

      r.add_text(:main_text, @main_html)

      r.add_section("SECTION_01", @items) do |s|
        s.add_field(:name)
        s.add_text(:inner_text) { |_i| @section_html }
      end

      r.add_table("TABLE", @items) do |s|
        s.add_field(:field, :name)
        s.add_text(:text) { |_i| @table_html }
      end
    end

    report.generate("spec/result/texts_rich.odt")

    @data = Inspector.new("spec/result/texts_rich.odt")
  end

  it "renders text at report level" do
    expect(@data.text).to include("Main text paragraph")
  end

  it "renders bold formatting as ODF spans" do
    expect(@data.xml.to_s).to include('text:style-name="bold"')
  end

  it "renders italic formatting as ODF spans" do
    expect(@data.xml.to_s).to include('text:style-name="italic"')
  end

  it "renders blockquote as quote style" do
    expect(@data.xml.to_s).to include('text:style-name="quote"')
  end

  it "renders text inside sections" do
    expect(@data.text).to include("Section text with")
  end

  it "renders text inside tables" do
    expect(@data.text).to include("Table text with")
  end
end
