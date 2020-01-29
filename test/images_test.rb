require './lib/odf-report'
require 'launchy'


report = ODFReport::Report.new("test/templates/test_images.odt") do |r|

  r.add_image("image_1", 'test/templates/images/image_1.jpg')
  r.add_image("image_2", 'test/templates/images/image_3.jpg')
  r.add_image("image_3", 'test/templates/images/image_3.jpg')

end

report.generate("test/result/test_images.odt")
