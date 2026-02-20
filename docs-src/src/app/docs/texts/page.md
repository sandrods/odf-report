---
title: Texts
---

Use `add_text` to replace placeholders with rich HTML-formatted content that gets converted into ODF paragraphs. {% .lead %}

---

## How texts differ from fields

While `add_field` does plain text substitution (replacing the placeholder inline), `add_text` parses HTML content and converts it into proper ODF-formatted paragraphs. This means you can use headings, bold, italic, underline, blockquotes, and line breaks.

---

## Basic usage

```ruby
report = ODFReport::Report.new("template.odt") do |r|
  r.add_text :description, '<p>First paragraph.</p><p>Second paragraph.</p>'
end
```

The placeholder `[DESCRIPTION]` in your template will be replaced with two formatted paragraphs.

---

## Supported HTML tags

### Block-level elements

| HTML tag | ODF style applied | Template style required? |
|----------|-------------------|--------------------------|
| `<p>` | inherits from placeholder | No |
| `<h1>`, `<h2>` | `title` | Yes |
| `<blockquote><p>...</p></blockquote>` | `quote` | Yes |
| `<p style="margin: ...">` | `quote` | Yes |

### Inline elements

| HTML tag | ODF style applied | Template style required? |
|----------|-------------------|--------------------------|
| `<strong>` | `bold` | Yes |
| `<em>` | `italic` | Yes |
| `<u>` | `underline` | Yes |
| `<br>` | line break | No |

For the complete reference, see [Supported HTML tags](/docs/supported-html).

---

## Template setup

For inline formatting and paragraph styles to render correctly, your `.odt` template must define the corresponding styles. The parser generates ODF XML referencing these style names but does not create the style definitions itself.

### Step 1: Create character styles

Open your template in LibreOffice Writer. Go to **View > Styles** (or press F11), then right-click on the character styles list and select **New Style**. Create these styles:

- **bold** — set font weight to Bold
- **italic** — set font style to Italic
- **underline** — set underlining to Single

{% callout title="Style names must be exact" %}
The style names must be lowercase and match exactly: `bold`, `italic`, `underline`. These are the names the parser references in the generated ODF XML.
{% /callout %}

### Step 2: Create paragraph styles (optional)

If you plan to use `<h1>`, `<h2>`, or `<blockquote>`, create these paragraph styles:

- **title** — configure as desired (e.g., larger font, bold)
- **quote** — configure as desired (e.g., indented, italic)

### Step 3: Place your placeholder

Type the placeholder (e.g., `[MY_CONTENT]`) inside a normal text paragraph. This paragraph node is used as the base template for each generated paragraph.

---

## Examples

### Simple paragraphs

```ruby
r.add_text(:description, '<p>This is the first paragraph.</p><p>This is the second.</p>')
```

### Inline formatting

```ruby
r.add_text(:notes, '<p>This has <strong>bold</strong>, <em>italic</em>, and <u>underlined</u> text.</p>')
```

### Headings and quotes

```ruby
r.add_text(:article, <<~HTML)
  <h1>Article Title</h1>
  <p>Some introductory text.</p>
  <blockquote>
    <p>A quoted paragraph with <em>emphasis</em>.</p>
  </blockquote>
  <p>More regular text.</p>
HTML
```

### Line breaks within a paragraph

```ruby
r.add_text(:address, '<p>123 Main St<br>Suite 400<br>Springfield</p>')
```

---

## Using inside sections and tables

`add_text` works inside sections and tables, resolving values per collection item:

```ruby
r.add_section("SC_ITEMS", @items) do |s|
  s.add_text(:item_description) { |item| item.html_description }
end
```

---

## Troubleshooting

**Formatting not applied:** If your text appears but without bold/italic/underline, the most likely cause is that the required character styles are not defined in your template. Open the template in LibreOffice and verify that styles named exactly `bold`, `italic`, and `underline` exist.

**Placeholder not replaced:** Make sure the placeholder text (e.g., `[MY_CONTENT]`) is in a single text node. If you edit a placeholder in LibreOffice, it may split the text across multiple XML nodes. Delete the placeholder entirely and retype it.
