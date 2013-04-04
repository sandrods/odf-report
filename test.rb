require './lib/odf-report.rb'

report = ODFReport::Report.new("lesson_plan.odt") do |r|

 #r.add_field :user_name, 'Test'

end

report_file_name = report.generate

puts report_file_name
