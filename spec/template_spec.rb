RSpec.describe "Templates Types" do

  before(:each) do

    @field_01 = Faker::Company.name
    @field_02 = Faker::Name.name

    report.add_field(:field_01, @field_01)
    report.add_field(:field_02, @field_02)

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end

  context "template from file" do
    let(:report) { ODFReport::Report.new("spec/templates/specs.odt") }

    it "works" do

      expect(@data.text).not_to match(/\[FIELD_01\]/)
      expect(@data.text).not_to match(/\[FIELD_02\]/)

      expect(@data.text).to match @field_01
      expect(@data.text).to match @field_02

    end
  end

  context "template from a String" do
    let(:report) { ODFReport::Report.new(io: File.open("spec/templates/specs.odt").read) }

    it "works" do

      expect(@data.text).not_to match(/\[FIELD_01\]/)
      expect(@data.text).not_to match(/\[FIELD_02\]/)

      expect(@data.text).to match @field_01
      expect(@data.text).to match @field_02

    end
  end

end
