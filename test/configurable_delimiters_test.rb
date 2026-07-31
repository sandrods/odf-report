require "./lib/odf-report"
require "tmpdir"

NS = %(xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ) +
     %(xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0")

def content_xml(body)
  %(<?xml version="1.0"?><office:document-content #{NS}>) +
    %(<office:body><office:text>#{body}</office:text></office:body></office:document-content>)
end

def build_template(dir, body)
  path = File.join(dir, "tpl.odt")
  Zip::OutputStream.open(path) do |z|
    z.put_next_entry("mimetype"); z.write("application/vnd.oasis.opendocument.text")
    z.put_next_entry("content.xml"); z.write(content_xml(body))
    z.put_next_entry("META-INF/manifest.xml")
    z.write(%(<?xml version="1.0"?><manifest:manifest ) +
            %(xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">) +
            %(<manifest:file-entry manifest:full-path="/" ) +
            %(manifest:media-type="application/vnd.oasis.opendocument.text"/></manifest:manifest>))
  end
  path
end

def render(template_body, &block)
  Dir.mktmpdir do |dir|
    src = build_template(dir, template_body)
    out = File.join(dir, "out.odt")
    ODFReport::Report.new(src, &block).generate(out)
    Zip::File.open(out) { |z| return z.read("content.xml") }
  end
end

failures = 0
check = lambda do |cond, msg|
  puts(cond ? "PASS: #{msg}" : "FAIL: #{msg}")
  failures += 1 unless cond
end

# default is square brackets
check.call(ODFReport.delimiters == ["[", "]"], "default delimiters are square brackets")
out = render("<text:p>[NAME]</text:p>") { |r| r.add_field(:name, "Acme") }
check.call(out.include?("Acme") && !out.include?("[NAME]"), "[NAME] replaced by default")

# curly preset, end to end
ODFReport.delimiters = :curly
check.call(ODFReport.delimiters == ["{{", "}}"], ":curly preset sets {{ }}")
out = render("<text:p>{{NAME}}</text:p>") { |r| r.add_field(:name, "Acme") }
check.call(out.include?("Acme") && !out.include?("{{NAME}}"), "{{NAME}} replaced when :curly")
# square no longer matches while curly active
out = render("<text:p>[NAME]</text:p>") { |r| r.add_field(:name, "Acme") }
check.call(out.include?("[NAME]"), "[NAME] left intact while curly active")
ODFReport.delimiters = :square # reset

# custom pair (must be XML-safe)
ODFReport.delimiters = ["((", "))"]
out = render("<text:p>((NAME))</text:p>") { |r| r.add_field(:name, "Acme") }
check.call(out.include?("Acme"), "custom ((NAME)) pair works")
ODFReport.delimiters = :square

# block scoping restores previous value
ODFReport.with_delimiters(:curly) do
  check.call(ODFReport.delimiters == ["{{", "}}"], "with_delimiters switches inside block")
end
check.call(ODFReport.delimiters == ["[", "]"], "with_delimiters restores after block")

# validation
invalid = [:nope, "x", ["only-one"], 42, ["a", ""], ["<<", ">>"], ["'", "'"], ['"', '"']]
bad = 0
invalid.each do |v|
  begin; ODFReport.delimiters = v; rescue ArgumentError; bad += 1; end
end
check.call(bad == invalid.size, "invalid delimiter values (incl. XML/XPath-unsafe) raise ArgumentError")
ODFReport.delimiters = :square

abort("\n#{failures} failure(s)") unless failures.zero?
puts "\nOK (#{failures} failures)"
