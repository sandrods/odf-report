module ODFReport

  # Configurable placeholder delimiters.
  #
  # By default field names are wrapped in square brackets ([NAME]). You can
  # switch to double curly braces, or supply your own pair:
  #
  #   ODFReport.delimiters = :square       # [NAME]   (default)
  #   ODFReport.delimiters = :curly        # {{NAME}}
  #   ODFReport.delimiters = ["((", "))"]  # ((NAME))
  #
  # Or scope a choice to a single block, restoring the previous value after:
  #
  #   ODFReport.with_delimiters(:curly) do
  #     ODFReport::Report.new("template.odt") { |r| r.add_field(:name, "Acme") }.generate("out.odt")
  #   end
  #
  # Note: placeholder names are still upper-cased, so with :curly the template
  # token for add_field(:name) is {{NAME}}, not {{name}}.
  module Configuration

    SQUARE = ["[", "]"].freeze
    CURLY  = ["{{", "}}"].freeze

    PRESETS = { square: SQUARE, curly: CURLY }.freeze

    def delimiters
      @delimiters ||= SQUARE.dup
    end

    def delimiters=(value)
      @delimiters = coerce_delimiters(value)
    end

    # Temporarily use a delimiter set for the duration of the block, then
    # restore the previous value (handy in tests and for one-off reports).
    # Note: this mutates process-global state and is not thread-safe; for
    # concurrent reports needing different delimiters, set one consistent value.
    def with_delimiters(value)
      previous = @delimiters
      self.delimiters = value
      yield
    ensure
      @delimiters = previous
    end

    private

    def coerce_delimiters(value)
      case value
      when Symbol, String
        PRESETS[value.to_sym] ||
          raise(ArgumentError, "Unknown delimiter preset #{value.inspect}; " \
                               "use :square, :curly, or a two-element array of strings")
      when Array
        unless value.size == 2 && value.all? { |v| v.is_a?(String) && !v.empty? }
          raise ArgumentError, "delimiters must be a two-element array of non-empty strings, got #{value.inspect}"
        end
        if value.any? { |v| v.match?(/[<>&'"]/) }
          raise ArgumentError, %(delimiters must not contain any of < > & ' "; the ) +
                               "first three are escaped in the document (so they would " \
                               "never match), and the quotes break the XPath lookup used " \
                               "for text placeholders"
        end
        value.map(&:dup).freeze
      else
        raise ArgumentError, "delimiters must be a Symbol preset or a two-element array, got #{value.class}"
      end
    end

  end

  extend Configuration

end
