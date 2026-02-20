---
title: Troubleshooting
---

Solutions to common issues when working with ODF-Report. {% .lead %}

---

## Placeholder not replaced

**Symptom:** Your `[PLACEHOLDER]` appears in the output document unchanged.

**Cause:** LibreOffice/OpenOffice sometimes inserts hidden XML markup when you edit a placeholder. Instead of a clean `[USER_NAME]` text node, the XML might contain something like `[USER_<span>NAME</span>]`, which the gem can't match.

**Solution:** Delete the entire placeholder and retype it from scratch, including the square brackets.

{% callout type="warning" title="Golden rule" %}
Never edit placeholders. If you need to change `[USER]` to `[USERNAME]`, don't select and modify the text. Instead, delete `[USER]` completely and type `[USERNAME]` fresh.
{% /callout %}

**Additional checks:**

- Verify the field name matches (names are auto-uppercased, so `add_field :user_name` matches `[USER_NAME]`)
- For `add_text` placeholders, ensure the placeholder is in its own paragraph — not inline with other content
- Try opening the `.odt` file as a ZIP and inspecting `content.xml` to see how LibreOffice encoded the placeholder text

---

## Word found unreadable content

**Symptom:** You create your template in LibreOffice, but when you open the generated document in Microsoft Word, it reports "Word found unreadable content."

**Solution:**

1. Open your template in LibreOffice
2. Save as `.docx` format
3. Close LibreOffice
4. Open the `.docx` file in LibreOffice
5. Save as `.odt` format
6. Use this new `.odt` as your template

**Why this works:** Word doesn't support all ODF features. The round-trip through `.docx` removes document features that Word can't handle.

---

## Formatting not applied to texts

**Symptom:** `add_text` content appears as plain text without bold, italic, or underline formatting.

**Cause:** The required character styles are not defined in your template.

**Solution:** Open your template in LibreOffice and create character styles named exactly `bold`, `italic`, and `underline`. See [Texts — Template setup](/docs/texts#template-setup) for step-by-step instructions.

---

## Table not found

**Symptom:** Table rows are not generated, or the table is left unchanged.

**Cause:** The table name in your code doesn't match the table name in the template.

**Solution:**

1. In LibreOffice, right-click the table and select **Table Properties...**
2. Check the **Name** field
3. Make sure it matches exactly what you pass to `add_table`

---

## Section not found

**Symptom:** Section content is not repeated.

**Cause:** The section name doesn't match, or the section wasn't created properly.

**Solution:**

1. In LibreOffice, click inside the section
2. Go to **Format > Sections...**
3. Verify the section name matches what you pass to `add_section`

---

## Image not replaced

**Symptom:** The placeholder image remains in the output.

**Cause:** The image frame name doesn't match.

**Solution:**

1. In LibreOffice, right-click the image
2. Select **Properties** and go to the **Options** tab
3. Check the **Name** field
4. Make sure it matches what you pass to `add_image`

---

## Corrupted files with rubyzip 3 / Rails 8

**Symptom:** Generated `.odt` files are corrupt and cannot be opened or recovered by LibreOffice. This typically happens after upgrading to Rails 8 or rubyzip 3.

**Cause:** rubyzip 3 [enables Zip64 by default](https://github.com/rubyzip/rubyzip/wiki/Updating-to-version-3.x). The Zip64 format is not supported by `.odt` readers.

**Solution:** Disable Zip64 support by adding an initializer:

```ruby
# config/initializers/rubyzip.rb
Zip.write_zip64_support = false
```

---

## Common mistakes

- **Passing an array inside a section instead of a symbol:** Inside sections, use `:items` (symbol) not `@items` (array). The symbol tells ODF-Report to call that method on each section record.

- **Forgetting `header: true`:** If your table has a header row and you don't pass `header: true`, the header row will be treated as a template row and duplicated for each item.

- **Editing template placeholders:** Always delete and retype. Never edit in place.
