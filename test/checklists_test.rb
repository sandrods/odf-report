require "./lib/odf-report"
require "tmpdir"

NS = %(xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ) +
     %(xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0")
CHECKED   = "\u2611"
UNCHECKED = "\u2610"

def render(items, opts = {})
  Dir.mktmpdir do |dir|
    src = File.join(dir, "tpl.odt")
    Zip::OutputStream.open(src) do |z|
      z.put_next_entry("mimetype"); z.write("application/vnd.oasis.opendocument.text")
      z.put_next_entry("content.xml")
      z.write(%(<?xml version="1.0"?><office:document-content #{NS}>) +
              %(<office:body><office:text><text:p>[TASKS]</text:p></office:text></office:body></office:document-content>))
      z.put_next_entry("META-INF/manifest.xml")
      z.write(%(<?xml version="1.0"?><manifest:manifest ) +
              %(xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">) +
              %(<manifest:file-entry manifest:full-path="/" ) +
              %(manifest:media-type="application/vnd.oasis.opendocument.text"/></manifest:manifest>))
    end
    out = File.join(dir, "out.odt")
    ODFReport::Report.new(src) { |r| r.add_checklist(:tasks, items, opts) }.generate(out)
    Zip::File.open(out) { |z| return z.read("content.xml") }
  end
end

failures = 0
check = lambda { |cond, msg| puts(cond ? "PASS: #{msg}" : "FAIL: #{msg}"); failures += 1 unless cond }

out = render([
  { text: "Design approved", checked: true },
  { text: "Code reviewed",   checked: false },
  ["Array item", true],
  "Bare string",
  { "text" => "String keys", "checked" => true },
])
d = Nokogiri::XML(out)
paras = d.xpath("//office:text/text:p")

check.(d.errors.empty?, "well-formed output")
check.(d.xpath("//text:list").empty?, "no text:list emitted (so no bullet dots)")
check.(d.xpath("//office:text//*").all? { |e| e.namespace&.href&.start_with?("urn:oasis:names:tc:opendocument") },
       "only ODF elements produced")
check.(paras.size == 5, "one paragraph per item (got #{paras.size})")
check.(paras[0].text.start_with?("#{CHECKED} ") && paras[0].text.include?("Design approved"), "hash checked -> ☑")
check.(paras[1].text.start_with?("#{UNCHECKED} "), "hash unchecked -> ☐")
check.(paras[2].text.start_with?("#{CHECKED} ") && paras[2].text.include?("Array item"), "array [text, true] -> ☑")
check.(paras[3].text.start_with?("#{UNCHECKED} ") && paras[3].text.include?("Bare string"), "bare string -> ☐")
check.(paras[4].text.start_with?("#{CHECKED} ") && paras[4].text.include?("String keys"), "string keys honored")

# escaping
out = render([{ text: "A & B <tag>", checked: false }])
d = Nokogiri::XML(out)
check.(d.errors.empty? && !out.include?("<tag>") && d.at_xpath("//office:text/text:p").text.include?("A & B <tag>"),
       "item text is XML-escaped")

# falsey variants render unchecked
out = render([["a", "false"], ["b", 0], ["c", "no"], ["d", nil]])
allunchecked = Nokogiri::XML(out).xpath("//office:text/text:p").all? { |p| p.text.start_with?("#{UNCHECKED} ") }
check.(allunchecked, "\"false\"/0/\"no\"/nil treated as unchecked")

# custom symbols (and a metachar-bearing symbol stays well-formed)
out = render([{ text: "x", checked: true }, { text: "y", checked: false }],
             checked_symbol: "[x]", unchecked_symbol: "[ ]")
txts = Nokogiri::XML(out).xpath("//office:text/text:p").map(&:text)
check.(txts[0].start_with?("[x] ") && txts[1].start_with?("[ ] "), "custom symbols honored")

abort("\n#{failures} failure(s)") unless failures.zero?
puts "\nOK (#{failures} failures)"
