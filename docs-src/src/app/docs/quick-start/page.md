---
title: Quick start
---

Create your first document in two steps: prepare a template, then write Ruby code to fill it. {% .lead %}

---

## Step 1: Create a template

Open LibreOffice Writer (or OpenOffice) and create a new document. Type placeholders using uppercase names surrounded by brackets:

```
Dear [CLIENT_NAME],

Thank you for your order on [ORDER_DATE].

Best regards,
[COMPANY_NAME]
```

Save the file as `letter_template.odt`.

{% callout title="Golden rule" %}
Never edit a placeholder after typing it. If you need to change `[USER]` to `[USERNAME]`, delete the entire `[USER]` placeholder and type `[USERNAME]` from scratch. LibreOffice may insert hidden XML markup when you edit text, which prevents the placeholder from being found.
{% /callout %}

---

## Step 2: Write the Ruby code

```ruby
require 'odf-report'

report = ODFReport::Report.new("letter_template.odt") do |r|
  r.add_field :client_name, "Jane Smith"
  r.add_field :order_date, "February 15, 2026"
  r.add_field :company_name, "Acme Corp"
end

report.generate("letter_output.odt")
```

This reads the template, replaces all `[CLIENT_NAME]`, `[ORDER_DATE]`, and `[COMPANY_NAME]` placeholders with the provided values, and writes the result to `letter_output.odt`.

---

## Two ways to generate

### Save to a file

Pass a file path to `generate` to write the output directly:

```ruby
report.generate("output.odt")
```

### Get binary data

Call `generate` without arguments to get the document as a binary string. This is useful in web applications where you want to send the file as a download:

```ruby
binary_data = report.generate
```

---

## A more complete example

Here's a template with fields, a table, and an image:

```ruby
report = ODFReport::Report.new("invoice_template.odt") do |r|
  # Simple field replacements
  r.add_field :invoice_number, "INV-2026-001"
  r.add_field :client_name, @client.name
  r.add_field :date, Date.today.strftime("%B %d, %Y")

  # Table: repeats rows for each item
  r.add_table("ITEMS", @line_items, header: true) do |t|
    t.add_column(:description)
    t.add_column(:quantity)
    t.add_column(:price) { |item| format("$%.2f", item.price) }
  end

  # Image replacement
  r.add_image :company_logo, "assets/logo.png"
end

report.generate("invoice.odt")
```

---

## Next steps

- [Fields](/docs/fields) — learn all the ways to replace placeholders
- [Tables](/docs/tables) — generate rows from collections
- [Sections](/docs/sections) — repeat complex document structures
- [Using with Rails](/docs/rails-integration) — serve documents from a Rails app
