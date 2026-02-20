---
title: Installation
---

Add ODF-Report to your Ruby project. {% .lead %}

---

## Gemfile

Add the gem to your `Gemfile`:

```ruby
gem 'odf-report'
```

Then run:

```shell
bundle install
```

Or install it directly:

```shell
gem install odf-report
```

---

## Dependencies

ODF-Report depends on three gems, which are installed automatically:

- **rubyzip** — manipulates the contents of the `.odt` file (which is a ZIP archive)
- **nokogiri** — parses and manipulates the XML files inside the document
- **mime-types** — identifies image MIME types when replacing images

---

## Ruby version

ODF-Report works with Ruby 2.7 and above.

---

## Verifying the installation

After installing, you can verify everything is working:

```ruby
require 'odf-report'
puts ODFReport::VERSION
```

You're ready to go. Head to the [Quick start](/docs/quick-start) guide to create your first document.
