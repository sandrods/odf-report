
# ODF-REPORT

Generate .odt documents by filling templates with dynamic content — fields, tables, sections, and images.

For more detailed guides, examples, and API reference, check out the new **[Documentation Site](https://sandrods.github.io/odf-report/)**.

## Install

In your Gemfile
```ruby
gem 'odf-report'
```

## Quick example

Create a `.odt` template in LibreOffice with `[PLACEHOLDERS]`, then use the Ruby DSL to fill them in:

```ruby
report = ODFReport::Report.new("template.odt") do |r|
  r.add_field :company_name, "Acme Corp"
  r.add_field :date, Date.today.to_s

  r.add_table("EMPLOYEES", @employees, header: true) do |t|
    t.add_column(:name)
    t.add_column(:email)
    t.add_column(:department, :dept_name)
  end

  r.add_image :logo, "/path/to/logo.png"
end

report.generate("output.odt")
```

There are five kinds of substitutions available:

- **Fields** — replace `[PLACEHOLDER]` text with values
- **Texts** — replace placeholders with HTML-formatted content
- **Tables** — repeat table rows for each item in a collection
- **Sections** — repeat entire document sections with nested content
- **Images** — swap placeholder images with actual image files

## Documentation

- [Installation](https://sandrods.github.io/odf-report/docs/installation) — setup and requirements
- [Quick start](https://sandrods.github.io/odf-report/docs/quick-start) — build your first document
- [Fields](https://sandrods.github.io/odf-report/docs/fields), [Tables](https://sandrods.github.io/odf-report/docs/tables), [Sections](https://sandrods.github.io/odf-report/docs/sections), [Images](https://sandrods.github.io/odf-report/docs/images) — template guide
- [API reference](https://sandrods.github.io/odf-report/docs/api-reference) — complete method reference
- [Troubleshooting](https://sandrods.github.io/odf-report/docs/troubleshooting) — common issues and solutions
