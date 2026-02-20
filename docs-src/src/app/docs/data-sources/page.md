---
title: Data sources
---

A deep dive into how ODF-Report resolves values from your data. {% .lead %}

---

## Two contexts

Values are resolved differently depending on context:

- **Report level** — you provide the value directly (a string, number, etc.)
- **Inside tables/sections** — values are extracted from each collection item

---

## Static values (report level)

At the report level, the second argument to `add_field` is used as-is:

```ruby
report = ODFReport::Report.new("template.odt") do |r|
  r.add_field :title, "Monthly Report"
  r.add_field :date, Date.today.to_s
end
```

---

## Symbol — method call

Pass a symbol to call that method on each collection item:

```ruby
r.add_table("USERS", @users) do |t|
  t.add_column(:name, :full_name)   # calls item.full_name
  t.add_column(:email)              # calls item.email (name used as method)
end
```

When you only pass one argument (like `:email`), the field name is also used as the method name.

---

## Array — method chain

Pass an array of symbols to chain method calls:

```ruby
r.add_table("USERS", @users) do |t|
  t.add_column(:company_name, [:company, :name])
  # calls item.company.name
end
```

You can also include method-with-argument hashes in the chain:

```ruby
t.add_column(:formatted, [:name, { truncate: 20 }])
# calls item.name.truncate(20)
```

---

## Hash — method with argument

Pass a hash to call a method with an argument:

```ruby
t.add_column(:name, { full_name: :upcase })
# calls item.full_name(:upcase)
```

---

## Block — custom transform

Pass a block for full control over the value:

```ruby
r.add_field(:status) { |item| item.active? ? "Active" : "Inactive" }

r.add_table("ITEMS", @items) do |t|
  t.add_column(:price) { |item| format("$%.2f", item.price) }
  t.add_column(:description) { |item| "==> #{item.description}" }
end
```

The block receives the current record and should return the replacement value.

---

## Hash records

When your collection contains hashes instead of objects, values are looked up by key. The lookup tries multiple key formats:

```ruby
@users = [
  { name: "Alice", email: "alice@example.com" },
  { name: "Bob", email: "bob@example.com" },
]

r.add_table("USERS", @users) do |t|
  t.add_column(:name)    # looks up :name, "name", "NAME", or :name
  t.add_column(:email)
end
```

The lookup order is: the original key, lowercase string, uppercase string, then lowercase symbol.

---

## Collection references in sections

Inside a section, when you add a table or nested section, you pass a **symbol** instead of an array. This symbol is called as a method on each section item:

```ruby
r.add_section("SC_INVOICE", @invoices) do |s|
  # :items calls invoice.items to get the table collection
  s.add_table("TB_ITEMS", :items) do |t|
    t.add_column(:product_name)
  end

  # :notes calls invoice.notes to get the nested section collection
  s.add_section("SUB_NOTES", :notes) do |s1|
    s1.add_field(:title)
  end
end
```

This is how ODF-Report connects nested data: each level resolves its collection from the parent item.
