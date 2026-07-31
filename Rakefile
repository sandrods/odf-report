require "bundler/gem_tasks"
require "launchy"
require "fileutils"
task :test do
  FileUtils.mkdir_p("./test/result")
  Dir.glob("./test/*_test.rb").each { |file| require file }
end

task :open do
  Dir.glob("./test/result/*.odt").each { |file| Launchy.open(file) }
end
