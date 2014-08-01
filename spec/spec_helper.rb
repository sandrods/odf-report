require './lib/odf-report'
require 'faker'

I18n.enforce_available_locales = false

class Item
  attr_accessor :id, :name, :subs
  def initialize(_id, _name, _subs=[])
    @name = _name
    @id   = _id
    @subs = _subs
  end

  def self.get_list(quant = 3)
    r = []
    (1..quant).each do |i|
      r << Item.new(Faker::Number.number(10), Faker::Name.name)
    end
    r
  end

end

class Inspector

  def initialize(file)
    @content = nil
    Zip::File.open(file) do |f|
      @content = f.get_entry('content.xml').get_input_stream.read
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
