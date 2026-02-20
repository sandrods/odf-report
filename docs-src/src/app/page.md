---
title: Getting started
---

Generate .odt documents from templates using simple Ruby code. {% .lead %}

ODF-Report is a Ruby gem that generates `.odt` (OpenDocument Text) files by taking a template and replacing placeholders with data. ODF files are ZIP archives containing XML — the gem uses `rubyzip` for ZIP manipulation and `nokogiri` for XML parsing.

The workflow is simple: create a `.odt` template in LibreOffice or OpenOffice with `[PLACEHOLDERS]`, then use the Ruby DSL to define replacements and generate documents.

---

## How it works

There are **five** kinds of substitutions available:

- **Fields** — replace `[PLACEHOLDER]` text with static or dynamic values
- **Texts** — replace placeholders with rich HTML-formatted content
- **Tables** — repeat table rows for each item in a collection
- **Sections** — repeat entire document sections with nested content
- **Images** — swap placeholder images with actual image files

---

## Quick example

```ruby
report = ODFReport::Report.new("template.odt") do |r|
  r.add_field :company_name, "Acme Corp"
  r.add_field :date, Date.today.to_s

  r.add_table("EMPLOYEES", @employees) do |t|
    t.add_column(:name)
    t.add_column(:email)
    t.add_column(:department, :dept_name)
  end
end

report.generate("output.odt")
```

This takes a template containing `[COMPANY_NAME]`, `[DATE]`, and a table named `EMPLOYEES` with `[NAME]`, `[EMAIL]`, and `[DEPARTMENT]` placeholders — and produces a finished document with all values filled in.

---

## Next steps

- [Installation](/docs/installation) — add the gem to your project
- [Quick start](/docs/quick-start) — build your first document in minutes
- [API reference](/docs/api-reference) — complete method reference
