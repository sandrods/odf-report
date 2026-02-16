# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased

### Breaking Changes

- None

### Added

- None

### Fixed

- None

## 0.9.0

### Refactored

- Extracted shared DSL (`add_field`, `add_text`, `add_image`, `add_table`, `add_section`) into `Composable` module, included by both `Report` and `Nestable`
- Unified `DataSource` to use lazy evaluation — `set_source` stores the record, `value` decides extraction strategy at read time
- Broke up `Report#generate` into focused private methods (`replace_placeholders!`, `include_images`)
- Simplified `Table` internals: renamed methods (`get_next_row` → `next_row`), removed redundant code
- Cleaned up `Image`: single XPath lookup, `image_href` helper, removed unused parameters
- Cleaned up `Template`: cached ZIP entries, renamed methods for clarity
- Cleaned up `Text`: removed `attr_accessor`, simplified `find_text_node`
- Cleaned up `Field`: removed dead code in `to_placeholder`
- Cleaned up `Parser::Default`: tightened visibility, simplified `check_style`
- Lazy-initialized all replacer arrays (no more `init_replacers`)

### Testing

- Added RSpec specs for nested tables, sub-sections, table headers, fields inside text, and rich text in sections/tables (19 → 38 examples)
- Organized specs and templates into grouped subfolders (`tables/`, `sections/`, `texts/`, `images/`)
- Decoupled spec templates from legacy test directory

## 0.8.1

### Fixed
- \<br\> replacement in default text parser #130

## 0.8.0

### Fixed
- Use Nokogiri HTML5 parser for text nodes parsing #129

### Dependencies
- nokogiri >= 1.12.0 (was >= 1.10.0)

## 0.7.3

### Fixed
- newer versions (> 1.13.0) of Nokogiri where presenting "Nokogiri::CSS::SyntaxError: unexpected '|'" #120
- prevent unnecessary memory expensive operations with missing placeholders #117

## 0.7.2

### Fixed

- files being recognized as "broken file" in Microsoft Word


## 0.7.1

### Added

- remove image if path is null
- remove section if collection is empty/null


## 0.7.0

### Added

- allow nested images inside tables and sections
- allow sections inside tables

### Dependencies

- rubyzip >= 1.3.0 (was ~> 1.2.0)


## 0.6.0

### Breaking Changes

- `ODFReport::File` renamed to `ODFReport::Template`
- `ODFReport::Report` constructor signature changed

### Dependencies

- rubyzip ~> 1.2.0 (was ~> 1.1.0)


## Earlier Versions

- No docs yet. Contributions welcome!
