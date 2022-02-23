RSpec.describe "Images" do

  context('Adding Images') do

    before(:context) do

      @list = []
      @list << OpenStruct.new({ name: "IMG - [1, 1]", path: 'spec/images/image_1.jpg', path2: 'spec/images/image_1.jpg' })
      @list << OpenStruct.new({ name: "IMG - [2, 1]", path: 'spec/images/image_2.jpg', path2: 'spec/images/image_1.jpg' })
      @list << OpenStruct.new({ name: "IMG - [3, 2]", path: 'spec/images/image_3.jpg', path2: 'spec/images/image_2.jpg' })
      @list << OpenStruct.new({ name: "IMG - [1, 3]", path: 'spec/images/image_1.jpg', path2: 'spec/images/image_3.jpg' })
      @list << OpenStruct.new({ name: "IMG - [2, 2]", path: 'spec/images/image_2.jpg', path2: 'spec/images/image_2.jpg' })


      report = ODFReport::Report.new("spec/templates/images.odt") do |r|

        r.add_image("IMAGE_01", 'spec/images/rails.png')
        r.add_image("IMAGE_02", 'spec/images/piriapolis.jpg')

        r.add_table('IMAGE_TABLE', @list) do |t|
          t.add_column(:image_name, :name)
          t.add_image('IMAGE_IN_TABLE_01', :path)
          t.add_image('IMAGE_IN_TABLE_02', :path2)
        end

        r.add_section('SECTION', @list) do |t|
          t.add_field(:image_name, :name)
          t.add_image('IMAGE_IN_SECTION_01', :path2)
          t.add_image('IMAGE_IN_SECTION_02', :path)
        end

      end

      report.generate("spec/result/images.odt")

      @data = Inspector.new("spec/result/images.odt")

    end


    it "simple image replacement" do

      images = @data.xml.xpath("//draw:image")

      expect(images[0].attribute('href').value).to eq "Pictures/rails.png"
      expect(images[1].attribute('href').value).to eq "Pictures/piriapolis.jpg"

    end

    it "table columns replacement" do

      table = @data.xml.at_xpath(".//table:table[@table:name='IMAGE_TABLE']")

      @list.each_with_index do |item, idx|

        row = table.xpath(".//table:table-row[#{idx+1}]")

        images = row.xpath(".//draw:image")

        expect(File.basename(images[0].attribute('href').value)).to eq File.basename(item.path)
        expect(File.basename(images[1].attribute('href').value)).to eq File.basename(item.path2)

      end

    end

    it "section fields replacement" do

      @list.each_with_index do |item, idx|

        section = @data.xml.at_xpath(".//text:section[#{idx+1}]")

        images = section.xpath(".//draw:image")

        expect(File.basename(images[0].attribute('href').value)).to eq File.basename(item.path)
        expect(File.basename(images[1].attribute('href').value)).to eq File.basename(item.path2)

      end

    end
  end

  context "Removing Images" do

    before(:context) do

      @list = []
      @list << OpenStruct.new({ name: "IMG - both ok",   path: 'spec/images/image_1.jpg', path2: 'spec/images/image_1.jpg' })
      @list << OpenStruct.new({ name: "IMG - 1 ok",      path: 'spec/images/image_2.jpg', path2: nil })
      @list << OpenStruct.new({ name: "IMG - 2 ok",      path: nil, path2: 'spec/images/image_3.jpg' })
      # @list << OpenStruct.new({ name: "IMG - 2 invalid", path: nil, path2: 'spec/images/invalid.jpg' })

      report = ODFReport::Report.new("spec/templates/images.odt") do |r|

        # r.add_image("IMAGE_01")
        r.add_image("IMAGE_02", nil)

        r.add_table('IMAGE_TABLE', @list) do |t|
          t.add_column(:image_name, :name)
          t.add_image('IMAGE_IN_TABLE_01', :path)
          t.add_image('IMAGE_IN_TABLE_02', :path2)
        end

        r.add_section('SECTION', @list) do |t|
          t.add_field(:image_name, :name)
          t.add_image('IMAGE_IN_SECTION_01', :path2)
          t.add_image('IMAGE_IN_SECTION_02', :path)
        end

      end

      report.generate("spec/result/images.odt")

      @data = Inspector.new("spec/result/images.odt")

    end

    it "removes nil images in report" do
      expect(@data.xml.at_xpath(".//draw:frame[@draw:name='IMAGE_01']")).to be
      expect(@data.xml.at_xpath(".//draw:frame[@draw:name='IMAGE_02']")).to be_nil
    end

    it "removes nil images in tables" do

      table = @data.xml.at_xpath(".//table:table[@table:name='IMAGE_TABLE']")

      images = table.xpath(".//table:table-row[1]//draw:image")
      expect(File.basename(images[0].attribute('href').value)).to eq File.basename(@list[0].path)
      expect(File.basename(images[1].attribute('href').value)).to eq File.basename(@list[0].path2)

      images = table.xpath(".//table:table-row[2]//draw:image")
      expect(File.basename(images[0].attribute('href').value)).to eq File.basename(@list[1].path)
      expect(images[1]).to be_nil

      images = table.xpath(".//table:table-row[3]//draw:image")
      expect(File.basename(images[0].attribute('href').value)).to eq File.basename(@list[2].path2)
      expect(images[1]).to be_nil

    end

    it "removes nil images in sections " do

      images = @data.xml.xpath(".//text:section[1]//draw:image")
      expect(File.basename(images[0].attribute('href').value)).to eq File.basename(@list[0].path)
      expect(File.basename(images[1].attribute('href').value)).to eq File.basename(@list[0].path2)

      images = @data.xml.xpath(".//text:section[2]//draw:image")
      expect(File.basename(images[0].attribute('href').value)).to eq File.basename(@list[1].path)
      expect(images[1]).to be_nil

      images = @data.xml.xpath(".//text:section[3]//draw:image")
      expect(File.basename(images[0].attribute('href').value)).to eq File.basename(@list[2].path2)
      expect(images[1]).to be_nil

    end

  end

end
