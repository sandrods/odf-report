---
title: Fields
---

Fields are the simplest form of substitution — replace `[PLACEHOLDER]` text in your template with dynamic values. {% .lead %}

---

## Placeholders in the template

A field placeholder is an uppercase name surrounded by square brackets:

```
Hello, [USER_NAME]!
Your account balance is [BALANCE].
```

You can place these anywhere in your `.odt` template — in paragraphs, table cells, headers, footers, or inside sections.

---

## Basic usage

Use `add_field` to define a replacement:

```ruby
report = ODFReport::Report.new("template.odt") do |r|
  r.add_field :user_name, "Jane Smith"
  r.add_field :balance, "$1,234.56"
end
```

Every occurrence of `[USER_NAME]` in the document will be replaced with "Jane Smith", and every `[BALANCE]` with "$1,234.56".

---

## Auto-uppercasing

Field names are automatically uppercased. These are all equivalent:

```ruby
r.add_field :user_name, "Jane"    # matches [USER_NAME]
r.add_field "user_name", "Jane"   # matches [USER_NAME]
r.add_field "USER_NAME", "Jane"   # matches [USER_NAME]
```

---

## Using symbols for method calls

When used inside a table or section, you can pass a symbol as the second argument to call a method on each collection item:

```ruby
r.add_table("USERS", @users) do |t|
  t.add_column(:name, :full_name)   # calls item.full_name
  t.add_column(:email)              # calls item.email (name used as method)
end
```

When the name and method are the same (like `:email` above), you only need to pass the name.

---

## Using blocks for transforms

Pass a block when you need to transform the value:

```ruby
r.add_field(:date) { |item| item.created_at.strftime("%B %d, %Y") }
r.add_field(:status) { |item| item.active? ? "Active" : "Inactive" }
r.add_field(:price) { |item| format("$%.2f", item.price) }
```

---

## Formatting is preserved

Any formatting applied to the placeholder text in the template (font, size, color, bold, etc.) is preserved after replacement. The substituted text inherits the formatting of the original placeholder.

---

## Multiline text

Newlines in field values are converted to ODF line breaks:

```ruby
r.add_field :address, "123 Main St\nSuite 400\nSpringfield"
```

This renders as three lines within the same paragraph. For rich HTML formatting, use [Texts](/docs/texts) instead.

{% callout type="warning" title="Don't edit placeholders" %}
If you need to rename a placeholder, delete it entirely and retype it — including the brackets. Editing a placeholder in LibreOffice can insert hidden XML markup that prevents the gem from finding it.
{% /callout %}
