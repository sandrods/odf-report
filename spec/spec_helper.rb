require "./lib/odf-report"
require "faker"
require "fileutils"

I18n.enforce_available_locales = false

# Specs write generated .odt files under spec/result/, mirroring the spec
# category subdirs (spec/images -> spec/result/images, etc.). This dir is
# gitignored, so recreate it (and its subdirs) on each run.
FileUtils.mkdir_p("./spec/result")
Dir.glob("./spec/*/").each do |dir|
  name = File.basename(dir)
  FileUtils.mkdir_p("./spec/result/#{name}") unless name == "result"
end

class Item
  attr_accessor :id, :name, :sid, :children, :subs
  def initialize(id, name, subs = [])
    @name = name
    @id = id
    @subs = subs
  end

  def self.get_list(quant = 3)
    (1..quant).map do |i|
      Item.new(Faker::Number.number(digits: 10), Faker::Name.name)
    end
  end
end

class Inspector
  def initialize(file)
    @content = nil
    Zip::File.open(file) do |f|
      @content = f.get_entry("content.xml").get_input_stream.read
    end
  end

  def xml
    @xml ||= Nokogiri::XML(@content)
  end

  def text
    @text ||= xml.to_s
  end
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
end
