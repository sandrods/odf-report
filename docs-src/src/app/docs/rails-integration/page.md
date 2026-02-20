---
title: Using with Rails
---

Serve generated `.odt` documents as downloads from a Rails application. {% .lead %}

---

## Controller example

Use `send_data` to stream the generated document as a download:

```ruby
class ReportsController < ApplicationController
  def show
    @ticket = Ticket.find(params[:id])

    report = ODFReport::Report.new(
      Rails.root.join("app/reports/ticket.odt")
    ) do |r|
      r.add_field(:id, @ticket.id.to_s)
      r.add_field(:created_by, @ticket.created_by)
      r.add_field(:created_at, @ticket.created_at.strftime("%d/%m/%Y - %H:%M"))
      r.add_field(:type, @ticket.type.name)
      r.add_field(:status, @ticket.status_text)
      r.add_field(:date, Time.now.strftime("%d/%m/%Y - %H:%M"))
      r.add_field(:solution, @ticket.solution || '')

      r.add_table("OPERATORS", @ticket.operators) do |t|
        t.add_column(:name) { |op| "#{op.name} (#{op.department.short_name})" }
      end

      r.add_table("FIELDS", @ticket.fields) do |t|
        t.add_column(:field_name, :name)
        t.add_column(:field_value) { |field| field.text_value || "Empty" }
      end
    end

    send_data report.generate,
              type: 'application/vnd.oasis.opendocument.text',
              disposition: 'attachment',
              filename: "ticket_#{@ticket.id}.odt"
  end
end
```

---

## Content type

The correct MIME type for `.odt` files is:

```
application/vnd.oasis.opendocument.text
```

---

## Template location

Store your templates somewhere accessible in your Rails app. Common locations:

```
app/reports/ticket.odt
app/templates/invoice.odt
lib/templates/letter.odt
```

Use `Rails.root.join` to build the full path:

```ruby
ODFReport::Report.new(Rails.root.join("app/reports/ticket.odt"))
```

---

## Templates from database or S3

If your template is stored in a database, S3, or any other non-filesystem source, use the `io:` parameter:

```ruby
# From Active Storage
template_data = @template_record.file.download

report = ODFReport::Report.new(io: template_data) do |r|
  r.add_field :name, "Jane"
end

send_data report.generate,
          type: 'application/vnd.oasis.opendocument.text',
          disposition: 'attachment',
          filename: 'report.odt'
```

The `io:` parameter accepts a string containing the raw binary content of the `.odt` file.

---

## Filename with dynamic data

Generate meaningful filenames for downloads:

```ruby
filename = "invoice_#{@invoice.number}_#{Date.today.strftime('%Y%m%d')}.odt"

send_data report.generate,
          type: 'application/vnd.oasis.opendocument.text',
          disposition: 'attachment',
          filename: filename
```
