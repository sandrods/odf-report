---
title: Nested structures
---

Combine sections, tables, and fields to produce complex, multi-level documents. {% .lead %}

---

## Tables inside sections

The most common nesting pattern — a section that repeats for each parent record, with a table inside for child records:

```ruby
r.add_section("SC_DEPARTMENT", @departments) do |s|
  s.add_field(:department_name)
  s.add_field(:manager)

  s.add_table("TB_EMPLOYEES", :employees, header: true) do |t|
    t.add_column(:name)
    t.add_column(:role)
    t.add_column(:email)
  end
end
```

For each department, the section is cloned. Inside each clone, the `TB_EMPLOYEES` table is populated with `department.employees`.

---

## Sections inside sections

Sections can nest arbitrarily:

```ruby
r.add_section("SC_CHAPTER", @chapters) do |s|
  s.add_field(:chapter_title)

  s.add_section("SC_SECTION", :sections) do |s1|
    s1.add_field(:section_title)
    s1.add_field(:section_body)
  end
end
```

The inner section repeats for each item returned by `chapter.sections`.

---

## Three-level nesting

Here's a real-world example — invoices containing line items, each with notes:

```ruby
r.add_section("SC_INVOICE", @invoices) do |s|
  s.add_field(:number) { |inv| inv.number.to_s.rjust(5, '0') }
  s.add_field(:customer_name)
  s.add_field(:date) { |inv| inv.date.strftime("%B %d, %Y") }

  # Level 2: table of line items
  s.add_table("TB_ITEMS", :items, header: true) do |t|
    t.add_column(:product) { |item| item.product.name }
    t.add_column(:quantity)
    t.add_column(:price) { |item| format("$%.2f", item.price) }
  end

  # Level 2: nested section for notes
  s.add_section("SC_NOTES", :notes) do |s1|
    s1.add_field(:note_title)
    s1.add_field(:note_date) { |note| note.created_at.strftime("%m/%d/%Y") }
    s1.add_field(:note_body)

    # Level 3: table inside the nested section
    s1.add_table("TB_ATTACHMENTS", :attachments) do |t|
      t.add_column(:filename)
      t.add_column(:size) { |att| "#{att.size_kb} KB" }
    end
  end

  s.add_field(:total) { |inv| format("$%.2f", inv.total) }
end
```

---

## How collection references work at each level

At each nesting level, the collection reference changes:

| Level | Collection argument | Resolves to |
|-------|---------------------|-------------|
| Report | `@invoices` (array) | The array itself |
| Section | `:items` (symbol) | `invoice.items` |
| Nested section | `:attachments` (symbol) | `note.attachments` |

The key insight: at the report level you pass the actual array. Inside sections (and tables), you pass a **symbol** that names the method to call on each parent item.

---

## Images at any level

Images can be placed at any nesting level:

```ruby
r.add_section("SC_PRODUCTS", @categories) do |s|
  s.add_field(:category_name)
  s.add_image(:category_icon) { |cat| cat.icon_path }

  s.add_table("TB_PRODUCTS", :products) do |t|
    t.add_column(:name)
    t.add_image(:product_photo) { |p| p.photo_path }
  end
end
```

---

## Texts at any level

Rich HTML text works the same way inside nested structures:

```ruby
r.add_section("SC_ARTICLES", @articles) do |s|
  s.add_field(:title)
  s.add_text(:body) { |article| article.html_content }
end
```
