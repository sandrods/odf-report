# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ruby gem that generates `.odt` (OpenDocument Text) files by taking a template and replacing placeholders with data. ODF files are ZIP archives containing XML; the gem uses `rubyzip` for ZIP manipulation and `nokogiri` for XML parsing.

## Common Commands

```bash
bundle install              # Install dependencies
bundle exec rspec           # Run RSpec test suite
bundle exec rake test       # Run legacy test suite (test/ directory)
bundle exec rspec spec/fields_spec.rb                        # Run single spec file
bundle exec rspec spec/fields_spec.rb -e "some description"  # Run specific example
standardrb                  # Lint check
standardrb --fix            # Auto-fix lint issues
bundle exec rake open       # Open generated test result .odt files
```

## Architecture

**Processing pipeline:** `Report` collects replacement definitions via its block DSL (`add_field`, `add_table`, `add_section`, `add_image`, `add_text`). On `generate`, `Template` extracts `content.xml` and `styles.xml` from the ZIP, then each replacer modifies the Nokogiri XML in-place. Order: sections → tables → texts → fields → images. The result is written back to a new ZIP.

**Key classes (all under `ODFReport` module in `lib/odf-report/`):**

- `Report` — Main entry point and public API. Includes `Composable` for the DSL. `generate` delegates to `replace_placeholders!` (XML substitution) and `include_images` (ZIP + manifest updates).
- `Template` — Handles .odt file I/O (ZIP read/write). Accepts file path or `io:` buffer. Caches the ZIP handle via `template_entries`.
- `Composable` — Module included by both `Report` and `Nestable`. Provides `add_field`, `add_text`, `add_image`, `add_table`, `add_section`, `all_images`, and lazy-initialized arrays (`fields`, `texts`, `tables`, `sections`, `images`).
- `Nestable` — Base class for `Table` and `Section`. Includes `Composable`. Adds `@name`, `@data_source`, `set_source`, `replace_with!`, and `wrap_with_ns`.
- `Table` — Finds a named ODF table, clones its template row for each collection item.
- `Section` — Finds a named ODF section, clones it for each collection item. Supports nesting.
- `Field` — Replaces `[PLACEHOLDER]` text nodes in XML. Names are uppercased automatically.
- `Text` — Extends Field; parses HTML content and inserts ODF paragraphs via `Parser::Default`.
- `Image` — Replaces placeholder images (matched by draw frame name) with actual image files. Uses `image_href` class method for path building. Updates the ZIP manifest.
- `DataSource` — Unified value/extraction model. When `set_source` is not called (Report path), `value` returns the literal. When `set_source` is called (Nestable path), `value` extracts from the record using `@field` as a lookup key. Supports hashes, method calls, method chains, methods with arguments, and block transforms.
- `Parser::Default` — Converts HTML tags (`<br>`, `<p>`, `<strong>`, `<em>`, etc.) to ODF XML elements.

## Testing

Tests use RSpec 3.0. The `Inspector` helper class (defined in `spec/spec_helper.rb`) opens a generated .odt result file and provides:
- `@data.text` — all text content as a string
- `@data.xml` — parsed Nokogiri document for XPath queries

Test pattern: `before(:context)` generates an .odt file into `spec/result/`, then `it` blocks verify content using `Inspector`. Legacy tests in `test/` follow a similar pattern with output to `test/result/`.

## Code Style

Uses **standardrb** (Ruby Standard). No custom rubocop config.

## Documentation Site

The documentation site is hosted on GitHub Pages from the `gh-pages` branch. The source is a Next.js static site based on the Tailwind Plus "Syntax" template.

### Source location

The docs source lives in `docs-src/` on the `gh-pages` branch (not on master). The Next.js `src/` directory is at `docs-src/src/`.

### Deploy procedure

All steps happen on the `gh-pages` branch. Do NOT switch to master during the process.

```bash
git checkout gh-pages
cd docs-src
npm install
npm run build
cd ..
rm -rf _next docs 404.html favicon.ico index.html index.txt .nojekyll
cp -r docs-src/out/* .
touch .nojekyll
git add -A
git commit -m "Rebuild docs site"
git push origin gh-pages
git checkout master
```

### Key details

- `next.config.mjs` uses `output: 'export'` and `basePath: '/odf-report'` for static export
- `prismjs` is a required dependency (for Ruby syntax highlighting) — it's in `package.json`
- Build output goes to `docs-src/out/` and gets copied to the gh-pages root
- `.nojekyll` must exist at the root so GitHub Pages serves `_next/` files correctly
- `docs-src/.gitignore` excludes `node_modules/`, `.next/`, and `out/` from git
- Markdown content pages are in `docs-src/src/app/docs/*/page.md`
- Navigation structure is in `docs-src/src/lib/navigation.js`
- NEVER use `distDir` to output directly to the repo root — Next.js cleans the target directory first, which will delete `.git` and destroy the repo
