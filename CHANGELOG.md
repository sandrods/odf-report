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
