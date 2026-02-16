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
