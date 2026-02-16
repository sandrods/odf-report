require "./lib/odf-report"
require "faker"

I18n.enforce_available_locales = false

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
