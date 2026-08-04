module ODFReport

  # Renders a checklist into a text placeholder.
  #
  #   report.add_checklist(:tasks, [
  #     { text: "Design approved", checked: true },
  #     { text: "Code reviewed",   checked: false },
  #     "Untested item"                       # bare string -> unchecked
  #   ])
  #
  # Each item becomes its own paragraph prefixed with a checkbox glyph
  # (☑ when checked, ☐ otherwise). Items are rendered as paragraphs rather
  # than an ODF list on purpose: a text:list would also draw the default list
  # bullet next to the glyph. The checkbox glyph is the marker here.
  #
  # Items may be:
  #   - a Hash with :text / :checked (string keys also accepted)
  #   - a two-element Array [text, checked]
  #   - any object responding to #text and #checked
  #   - a plain String (rendered unchecked)
  #
  # The glyphs can be overridden per checklist:
  #   add_checklist(:tasks, items, checked_symbol: "[x]", unchecked_symbol: "[ ]")
  #
  class Checklist < Text

    DEFAULT_CHECKED   = "\u2611".freeze # ☑ BALLOT BOX WITH CHECK
    DEFAULT_UNCHECKED = "\u2610".freeze # ☐ BALLOT BOX

    def initialize(opts, &block)
      @checked_symbol   = opts[:checked_symbol]   || DEFAULT_CHECKED
      @unchecked_symbol = opts[:unchecked_symbol] || DEFAULT_UNCHECKED
      super
    end

    def replace!(doc)
      return unless (node = find_text_node(doc))

      Array(@data_source.value).each do |item|
        paragraph = node.dup
        paragraph.children = entry_markup(item)
        node.before(paragraph)
      end

      node.remove
    end

    private

    # One paragraph's inner markup: "<glyph> <escaped text>". Reusing the
    # placeholder paragraph (node.dup) keeps the surrounding paragraph style.
    def entry_markup(item)
      checked, text = normalize(item)
      symbol = checked ? @checked_symbol : @unchecked_symbol

      "#{html_escape(symbol)} #{sanitize(text)}"
    end

    def normalize(item)
      case item
      when Hash
        h = item.transform_keys(&:to_sym)
        [truthy?(h[:checked]), h[:text].to_s]
      when Array
        [truthy?(item[1]), item[0].to_s]
      else
        if item.respond_to?(:text) && item.respond_to?(:checked)
          [truthy?(item.checked), item.text.to_s]
        else
          [false, item.to_s]
        end
      end
    end

    def truthy?(value)
      return false if value.nil? || value == false
      return false if %w[false 0 no n].include?(value.to_s.strip.downcase)

      true
    end

  end
end
