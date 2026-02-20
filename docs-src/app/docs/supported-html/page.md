---
title: Supported HTML tags
---

Complete reference of HTML tags supported by `add_text`. {% .lead %}

---

## Block-level elements

These tags generate separate ODF paragraphs:

| HTML tag | ODF style applied | Template style required? | Notes |
|----------|-------------------|--------------------------|-------|
| `<p>` | Inherits from placeholder | No | Standard paragraph |
| `<h1>` | `title` | Yes | Heading — uses the `title` paragraph style |
| `<h2>` | `title` | Yes | Same as `<h1>` |
| `<blockquote><p>...</p></blockquote>` | `quote` | Yes | Quoted paragraph |
| `<p style="margin: ...">` | `quote` | Yes | Indented paragraph treated as quote |

---

## Inline elements

These tags apply formatting within a paragraph:

| HTML tag | ODF style applied | Template style required? | Notes |
|----------|-------------------|--------------------------|-------|
| `<strong>` | `bold` | Yes | Bold text — uses `bold` character style |
| `<em>` | `italic` | Yes | Italic text — uses `italic` character style |
| `<u>` | `underline` | Yes | Underlined text — uses `underline` character style |
| `<br>` | line break | No | Inserts a line break within the current paragraph |

---

## HTML entities

HTML entities are supported and converted to their corresponding characters:

```ruby
r.add_text(:content, '<p>caf&eacute; na&iuml;vet&eacute;</p>')
# renders: café naïveté
```

---

## Unsupported tags

Tags not listed above are stripped — their content is preserved as plain text, but the tag itself has no effect:

```ruby
r.add_text(:content, '<p>This has a <span>span</span> and a <div>div</div>.</p>')
# renders: "This has a span and a div."
```

---

## Style naming

Style names must match exactly in lowercase. The parser looks for these specific names:

| Style type | Name | Must be defined as |
|------------|------|--------------------|
| Character | `bold` | Character style in template |
| Character | `italic` | Character style in template |
| Character | `underline` | Character style in template |
| Paragraph | `title` | Paragraph style in template |
| Paragraph | `quote` | Paragraph style in template |

### Creating character styles in LibreOffice

1. Open your template in LibreOffice Writer
2. Go to **View > Styles** (or press F11)
3. Click the **Character Styles** icon (the "A" icon)
4. Right-click in the styles list and select **New Style...**
5. Name it exactly (e.g., `bold`) and configure the formatting
6. Repeat for `italic` and `underline`

### Creating paragraph styles in LibreOffice

1. In the Styles panel, click the **Paragraph Styles** icon
2. Right-click and select **New Style...**
3. Name it exactly (e.g., `title`) and configure the formatting
4. Repeat for `quote`

---

## Example with all supported tags

```ruby
r.add_text(:full_example, <<~HTML)
  <h1>Document Title</h1>
  <p>A regular paragraph with <strong>bold</strong>, <em>italic</em>, and <u>underlined</u> text.</p>
  <p>A paragraph with a<br>line break in the middle.</p>
  <blockquote>
    <p>A quoted paragraph with <em>emphasis</em>.</p>
  </blockquote>
  <p>Final paragraph with special characters: caf&eacute;.</p>
HTML
```
