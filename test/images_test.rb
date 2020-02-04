require './lib/odf-report'
require 'ostruct'
require 'launchy'


@table = []
@table << OpenStruct.new({ name: "IMG - [1, 1]", path: 'test/templates/images/image_1.jpg', path2: 'test/templates/images/image_1.jpg' })
@table << OpenStruct.new({ name: "IMG - [2, 1]", path: 'test/templates/images/image_2.jpg', path2: 'test/templates/images/image_1.jpg' })
@table << OpenStruct.new({ name: "IMG - [3, 2]", path: 'test/templates/images/image_3.jpg', path2: 'test/templates/images/image_2.jpg' })
@table << OpenStruct.new({ name: "IMG - [1, 3]", path: 'test/templates/images/image_1.jpg', path2: 'test/templates/images/image_3.jpg' })
@table << OpenStruct.new({ name: "IMG - [2, 2]", path: 'test/templates/images/image_2.jpg', path2: 'test/templates/images/image_2.jpg' })

report = ODFReport::Report.new("test/templates/test_images.odt") do |r|

  r.add_image("graphics2", 'test/templates/rails.png')
  r.add_image("graphics3", 'test/templates/piriapolis.jpg')

  r.add_table('IMAGE_TABLE', @table) do |t|
    t.add_column(:image_name, :name)
    t.add_image('IMAGE_IN_TABLE', :path)
    t.add_image('IMAGE_2', :path2)
  end

end

report.generate("test/result/test_images.odt")
