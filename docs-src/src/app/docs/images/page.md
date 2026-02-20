---
title: Images
---

Replace placeholder images in your template with actual image files. {% .lead %}

---

## How it works

Put a mock image (any image) in your `.odt` template and give it a name. ODF-Report will replace that mock image with the actual image file you specify, preserving the size and properties from the template.

---

## Naming an image in LibreOffice

1. Insert an image into your template (any placeholder image will do)
2. Right-click the image and select **Properties** (or double-click the image frame)
3. In the **Options** tab, set the **Name** field (e.g., `company_logo`)
4. Adjust the size and position as desired — these properties are preserved

---

## Basic usage

```ruby
report = ODFReport::Report.new("template.odt") do |r|
  r.add_image :company_logo, "/path/to/logo.png"
end
```

The image named `company_logo` in the template will be replaced with `logo.png`.

---

## Images inside tables

```ruby
r.add_table("PRODUCTS", @products) do |t|
  t.add_column(:name)
  t.add_column(:price)
  t.add_image('product_image') { |item| item.image_path }
end
```

Each row gets its own image, resolved from the collection item.

---

## Images inside sections

```ruby
r.add_section("SC_TEAM", @team_members) do |s|
  s.add_field(:name)
  s.add_field(:role)
  s.add_image(:photo) { |member| member.photo_path }
end
```

---

## Nil images

If the image path is `nil`, the image frame is removed from the document entirely:

```ruby
r.add_image(:optional_photo) { |item| item.photo_path }  # nil → frame removed
```

---

## Properties preserved

The following properties from the template image are kept:

- Width and height
- Position and anchoring
- Borders and margins
- Any other frame properties set in the template

Only the image content (the actual picture data) is replaced. This means you can carefully design your layout using a placeholder image and the final document will maintain the same appearance.
