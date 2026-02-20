---
title: Tables
---

Generate table rows automatically from a collection of data. {% .lead %}

---

## How it works

Create a table in your `.odt` template with placeholder cells. ODF-Report clones the template row for each item in your collection, replacing the placeholders in each clone.

---

## Naming a table

To use a table with ODF-Report, it needs a name:

1. In LibreOffice Writer, right-click on the table
2. Select **Table Properties...**
3. Type a name in the **Name** field (e.g., `EMPLOYEES`)

---

## Basic usage

Given a template table named `EMPLOYEES` with cells containing `[NAME]` and `[EMAIL]`:

```ruby
report = ODFReport::Report.new("template.odt") do |r|
  r.add_table("EMPLOYEES", @employees) do |t|
    t.add_column(:name)
    t.add_column(:email)
  end
end
```

This creates one row for each employee in `@employees`, with the placeholders replaced by the corresponding values.

{% callout title="add_column is an alias" %}
`add_column` is just an alias for `add_field`. They work exactly the same way — use whichever reads better in context.
{% /callout %}

---

## Column values

Columns support the same value resolution as fields:

```ruby
r.add_table("ITEMS", @items) do |t|
  # Method name matches placeholder name
  t.add_column(:description)

  # Different method name
  t.add_column(:item_id, :id)

  # Block transform
  t.add_column(:price) { |item| format("$%.2f", item.price) }
end
```

---

## Header rows

If your table has a header row, pass `header: true` to preserve it. The first row will be left untouched and only subsequent rows are used as templates:

```ruby
r.add_table("ITEMS", @items, header: true) do |t|
  t.add_column(:description)
  t.add_column(:quantity)
  t.add_column(:price)
end
```

| Description | Qty | Price |
|-------------|-----|-------|
| [DESCRIPTION] | [QUANTITY] | [PRICE] |

The header row ("Description", "Qty", "Price") stays as-is. The second row is the template.

{% callout title="Auto-detected headers" %}
If your table uses the ODF `table:table-header-rows` element (set via **Table Properties > Text Flow > Repeat heading**), the header option is automatically detected and the `header: true` parameter is not needed.
{% /callout %}

---

## Removing empty tables

Use `skip_if_empty: true` to remove the entire table when the collection is empty or nil:

```ruby
r.add_table("OPTIONAL_DATA", @items, skip_if_empty: true) do |t|
  t.add_column(:name)
end
```

Without this option, an empty collection would leave the template row (with unresolved placeholders) in the document.

---

## Zebra rows (alternating styles)

If your template table has multiple rows below the header, they are cycled for each data item. This is useful for alternating row styles (e.g., different background colors):

```
| Header 1    | Header 2    |
|-------------|-------------|
| [COL1]      | [COL2]      |  ← row style A
| [COL1]      | [COL2]      |  ← row style B
```

ODF-Report alternates between the two template rows as it generates output, producing a zebra-striped table.

---

## Formatting

Any formatting applied to the placeholder cells in the template is preserved. Font, size, color, alignment, cell borders, and background colors all carry over to the generated rows.
