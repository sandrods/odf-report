require './lib/odf-report'
require 'faker'
require 'minitest/autorun'

class Item
  attr_accessor :id, :name, :subs
  def initialize(_id, _name, _subs=[])
    @name = _name
    @id   = _id
    @subs = _subs
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
    @text ||= xml.to_xml
  end

end
