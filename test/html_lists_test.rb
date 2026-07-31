require "./lib/odf-report"
require "tmpdir"

NS = %(xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ) +
     %(xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0")

def render(html)
  Dir.mktmpdir do |dir|
    src = File.join(dir, "tpl.odt")
    Zip::OutputStream.open(src) do |z|
      z.put_next_entry("mimetype"); z.write("application/vnd.oasis.opendocument.text")
      z.put_next_entry("content.xml")
      z.write(%(<?xml version="1.0"?><office:document-content #{NS}>) +
              %(<office:body><office:text><text:p>[BODY]</text:p></office:text></office:body></office:document-content>))
      z.put_next_entry("META-INF/manifest.xml")
      z.write(%(<?xml version="1.0"?><manifest:manifest ) +
              %(xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">) +
              %(<manifest:file-entry manifest:full-path="/" ) +
              %(manifest:media-type="application/vnd.oasis.opendocument.text"/></manifest:manifest>))
    end
    out = File.join(dir, "out.odt")
    ODFReport::Report.new(src) { |r| r.add_text(:body, html) }.generate(out)
    Zip::File.open(out) { |z| return z.read("content.xml") }
  end
end

def doc_of(content)
  Nokogiri::XML(content)
end

failures = 0
check = lambda { |cond, msg| puts(cond ? "PASS: #{msg}" : "FAIL: #{msg}"); failures += 1 unless cond }

# flat unordered list
out = render("<ul><li>first</li><li>second</li></ul>")
d = doc_of(out)
check.(d.errors.empty?, "output is well-formed XML")
check.(d.xpath("//text:list").size == 1, "one text:list created")
check.(d.xpath("//text:list/text:list-item").size == 2, "two list items")
check.(d.xpath("//text:list/text:list-item/text:p").map(&:text) == %w[first second],
       "items carry their text in text:p")
check.(!out.include?("<li>") && !out.include?("<ul>"), "no raw HTML list tags remain")

# inline formatting inside an item
out = render("<ul><li>plain <strong>bold</strong> end</li></ul>")
d = doc_of(out)
span = d.at_xpath("//text:list-item//text:span")
check.(span && span["text:style-name"] == "bold" && span.text == "bold",
       "inline <strong> inside <li> becomes bold text:span")

# nested list
out = render("<ul><li>parent<ul><li>child a</li><li>child b</li></ul></li></ul>")
d = doc_of(out)
outer_item = d.at_xpath("//text:list/text:list-item")
check.(outer_item.xpath("./text:list").size == 1, "nested text:list lives inside the parent list-item")
check.(d.xpath("//text:list//text:list//text:list-item").size == 2, "nested list has its two items")

# ordered list also produces a text:list
out = render("<ol><li>one</li><li>two</li></ol>")
check.(doc_of(out).xpath("//text:list/text:list-item").size == 2, "<ol> also yields a text:list")

# ordering: paragraph, list, paragraph preserved
out = render("<p>intro</p><ul><li>x</li></ul><p>after</p>")
body = doc_of(out).at_xpath("//office:text")
names = body.children.map(&:name).reject { |n| n.strip.empty? rescue false }
check.(names == %w[p list p], "block order preserved: p, list, p (got #{names.inspect})")

# regression: a plain paragraph with inline formatting still works
out = render("<p>hello <strong>there</strong></p>")
d = doc_of(out)
check.(d.xpath("//text:list").empty? && d.at_xpath("//text:p/text:span")&.text == "there",
       "plain paragraph + inline formatting still works (no list)")

abort("\n#{failures} failure(s)") unless failures.zero?
puts "\nOK (#{failures} failures)"
