---
title: Sections
---

Sections let you repeat entire chunks of a document — including tables, images, and nested sections — for each item in a collection. {% .lead %}

---

## When to use sections

Use sections when you need to repeat a structure more complex than a simple table row. A section can contain paragraphs, tables, images, fields, and even other sections.

---

## Creating a section in LibreOffice

1. Select the content you want to repeat (or place your cursor where you want the section)
2. Go to **Insert > Section...**
3. Give the section a name (e.g., `SC_INVOICE`)
4. Click **Insert**

The section will appear with a subtle border in LibreOffice.

---

## Basic usage

```ruby
@invoices = Invoice.all

report = ODFReport::Report.new("template.odt") do |r|
  r.add_section("SC_INVOICE", @invoices) do |s|
    s.add_field(:number) { |invoice| invoice.number.to_s.rjust(5, '0') }
    s.add_field(:customer_name)
    s.add_field(:customer_address)
    s.add_field(:total) { |invoice| format("$%.2f", invoice.total) }
  end
end
```

For each invoice in `@invoices`, the section is cloned and its placeholders are replaced with that invoice's data.

---

## Adding tables inside sections

Sections can contain tables. When adding a table to a section, pass a **symbol** for the collection instead of the array itself — this symbol refers to a method on each section item:

```ruby
r.add_section("SC_INVOICE", @invoices) do |s|
  s.add_field(:number)
  s.add_field(:customer_name)

  s.add_table("TB_ITEMS", :items, header: true) do |t|
    t.add_column(:product) { |item| item.product.name }
    t.add_column(:quantity)
    t.add_column(:price, :product_value)
  end
end
```

Here, `:items` refers to `invoice.items` — the collection for that particular invoice's table. Each cloned section gets its own table populated with that invoice's line items.

---

## Nesting sections

Sections can contain other sections:

```ruby
r.add_section("SC_INVOICE", @invoices) do |s|
  s.add_field(:number)

  s.add_section("SUB_NOTES", :notes) do |s1|
    s1.add_field(:note_title) { |note| note.title }
    s1.add_field(:note_body) { |note| note.body }
  end
end
```

The inner section `SUB_NOTES` is repeated for each note belonging to each invoice.

---

## Images inside sections

```ruby
r.add_section("SC_PRODUCTS", @products) do |s|
  s.add_field(:product_name)
  s.add_image(:product_photo) { |product| product.photo_path }
end
```

---

## Empty collections

When the collection is `nil` or empty, the section is removed from the document entirely. This is the default behavior — no extra option needed.

---

## How data sources work in sections

Inside a section block, the data source for nested elements works differently than at the report level:

- At the **report level**, `add_field(:name, "value")` uses the literal string
- Inside a **section**, `add_field(:name)` calls `record.name` on each collection item
- For nested **tables**, pass a symbol (`:items`) instead of an array — it calls `record.items`

See [Data sources](/docs/data-sources) for the full explanation.
