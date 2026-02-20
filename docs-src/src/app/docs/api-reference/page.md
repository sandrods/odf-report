---
title: API reference
---

Complete reference for all ODF-Report methods. {% .lead %}

---

## Report

### `Report.new(path = nil, io: nil, &block)`

Creates a new report. Provide either a file path or an `io:` string with the template content.

```ruby
# From file
report = ODFReport::Report.new("template.odt") do |r|
  # define replacements
end

# From string/IO
report = ODFReport::Report.new(io: template_string) do |r|
  # define replacements
end
```

### `Report#generate(dest = nil)`

Generates the document. If `dest` is provided, writes to that file path. Otherwise returns the document as a binary string.

```ruby
# Write to file
report.generate("output.odt")

# Get binary data
data = report.generate
```

---

## Fields

### `add_field(name, value = nil, &block)`

Replaces all occurrences of `[NAME]` in the document with the given value.

```ruby
r.add_field :user_name, "Jane Smith"
r.add_field(:date) { |record| record.created_at.strftime("%Y-%m-%d") }
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | Symbol or String | Placeholder name (auto-uppercased) |
| `value` | any | Static value, or a Symbol/Array/Hash for method resolution inside tables/sections |
| `&block` | Block | Optional transform receiving the current record |

---

## Texts

### `add_text(name, value = nil, &block)`

Replaces the placeholder paragraph with HTML-formatted ODF content.

```ruby
r.add_text :description, '<p>A paragraph with <strong>bold</strong> text.</p>'
r.add_text(:notes) { |record| record.html_notes }
```

**Parameters:** Same as `add_field`.

Works like `add_field` but parses the value as HTML and converts it into ODF paragraphs. Requires the template to define matching character/paragraph styles. See [Texts](/docs/texts) and [Supported HTML tags](/docs/supported-html) for details.

---

## Tables

### `add_table(name, collection, opts = {}, &block)`

Repeats table rows for each item in the collection.

```ruby
r.add_table("ITEMS", @items, header: true) do |t|
  t.add_column(:description)
  t.add_column(:price) { |item| format("$%.2f", item.price) }
end
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | String | Table name as set in LibreOffice |
| `collection` | Array or Symbol | Data collection (Array at report level, Symbol inside sections) |
| `opts[:header]` | Boolean | When `true`, preserves the first row as a header (default: `false`) |
| `opts[:skip_if_empty]` | Boolean | When `true`, removes the table if collection is empty (default: `false`) |
| `&block` | Block | Receives the table object for defining columns |

### `add_column(name, value = nil, &block)`

Alias for `add_field`. Used inside table blocks for readability.

```ruby
t.add_column(:product_name)
t.add_column(:price) { |item| format("$%.2f", item.price) }
```

---

## Sections

### `add_section(name, collection, opts = {}, &block)`

Repeats the named section for each item in the collection.

```ruby
r.add_section("SC_INVOICE", @invoices) do |s|
  s.add_field(:number)
  s.add_table("TB_ITEMS", :items) do |t|
    t.add_column(:description)
  end
end
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | String | Section name as set in LibreOffice |
| `collection` | Array or Symbol | Data collection (Array at report level, Symbol inside sections) |
| `opts` | Hash | Options (reserved for future use) |
| `&block` | Block | Receives the section object for defining nested content |

Inside a section block, you can use `add_field`, `add_text`, `add_table`, `add_section`, and `add_image`.

---

## Images

### `add_image(name, value = nil, &block)`

Replaces a named image frame with the specified image file.

```ruby
r.add_image :logo, "/path/to/logo.png"
r.add_image(:photo) { |record| record.photo_path }
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | Symbol or String | Image frame name as set in LibreOffice |
| `value` | String or nil | File path to the replacement image. `nil` removes the frame. |
| `&block` | Block | Optional transform receiving the current record |
