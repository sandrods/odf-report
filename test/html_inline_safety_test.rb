require "./lib/odf-report"
require "tmpdir"

NS = %(xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ) +
     %(xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0")
ODF_NS = "urn:oasis:names:tc:opendocument".freeze

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

# Every element under office:text must live in an ODF namespace (no foreign
# HTML tags), which is what LibreOffice's "Format error" rejects.
def only_odf_elements?(xml)
  doc = Nokogiri::XML(xml)
  return false unless doc.errors.empty?
  doc.xpath("//office:text//*").all? { |e| e.namespace && e.namespace.href.start_with?(ODF_NS) }
end

failures = 0
check = lambda { |cond, msg| puts(cond ? "PASS: #{msg}" : "FAIL: #{msg}"); failures += 1 unless cond }

samples = {
  "anchor"      => %(<p>see <a href="http://x">the link</a> here</p>),
  "b and i"     => "<p><b>bold</b> and <i>italic</i></p>",
  "span class"  => %(<p><span class="hl">highlighted</span> text</p>),
  "div wrapper" => "<div><p>wrapped</p></div>",
  "entities"    => "<p>caf&eacute; &mdash; 50&nbsp;cents &amp; more</p>",
  "list w/ a"   => %(<ul><li>plain</li><li><a href="x">linked</a> item</li></ul>),
}

samples.each do |name, html|
  out = render(html)
  check.(only_odf_elements?(out), "no foreign elements for: #{name}")
  check.(!out.match?(/<(a|b|i|span|div)[ >\/]/), "no raw HTML tag leaks for: #{name}")
end

# <b>/<i> are honored as bold/italic (not just stripped)
out = render("<p><b>x</b> <i>y</i></p>")
spans = Nokogiri::XML(out).xpath("//text:span")
styles = spans.map { |s| s["text:style-name"] }.sort
check.(styles == %w[bold italic], "<b>->bold and <i>->italic spans")

# anchor text is preserved even though the tag is dropped
out = render(%(<p>go <a href="http://x">somewhere</a></p>))
check.(Nokogiri::XML(out).at_xpath("//text:p").text.include?("somewhere"), "anchor text preserved")

# &nbsp; becomes a real character, not a literal entity
out = render("<p>a&nbsp;b</p>")
check.(!out.include?("&nbsp;") && Nokogiri::XML(out).at_xpath("//text:p").text.include?("\u00A0"),
       "&nbsp; decoded to a non-breaking space character")

abort("\n#{failures} failure(s)") unless failures.zero?
puts "\nOK (#{failures} failures)"
