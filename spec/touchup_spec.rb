RSpec.describe "Touchup" do

  before(:context) do

    module ODFReport
      class Report
        alias_method :old_touchup, :touchup
        def touchup(doc)
          doc.xpath("//text:p/text()").each do |p|
            if p.text =~ /\[STYLE=(.+?)\]/
              match=$1
              text = p.text.to_s.sub(/\[STYLE=(.+?)\]/, '')
              p.content = text
              p.parent.attributes['style-name'].value=match
            end
          end
        end
      end
    end

    report = ODFReport::Report.new("spec/specs.odt") do |r|

      r.add_field(:field_01, "[STYLE=teststyle]Testing!")
    end

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end


  it "should change the style of the paragraph" do

    expect(@data.text).not_to match(/\[STYLE=/)
    expect(@data.text).to match(/Testing!/)

    # The XML will look like this:
    # <text:p text:style-name="teststyle">Field_01: Testing!</text:p>
    expect(@data.xml.xpath("//text:p[@text:style-name='teststyle']/text()").first).to match(/Testing!/)

  end

end
