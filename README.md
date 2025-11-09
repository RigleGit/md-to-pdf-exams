# Exam Generator (Pandoc + LaTeX)

<img src="md-to-pdf-exam.png" alt="md-to-pdf-exam logo" width="400">

This repository contains a bilingual template (Spanish/English) to produce
digital exams in PDF using Pandoc, Lua filters, and a LaTeX base originally
created by [Driss Drissi](https://idrissi.eu/post/exam-template/). Questions live
in Markdown and solutions can be stored in a separate document and injected
automatically.

> ¿Prefieres la documentación en español? Consulta [README.es.md](README.es.md).

## Features
- Dual language support (`--lang es` or `--lang en`).
- Shared LaTeX template with shaded solution blocks.
- External solutions files (`exam/solutions_es.md` / `exam/solutions_en.md`) linked via the
  `solutions-file` metadata.
- Minimal maths samples in both languages (`exam/questions_es.md` and `exam/questions_en.md`).

## Quick start
```bash
# Generate Spanish exam (default)
./scripts/export.sh

# Generate Spanish exam with answers
./scripts/export.sh --answers

# Generate English exam
./scripts/export.sh --lang en

# Generate English exam with answers
./scripts/export.sh --lang en --answers
```

The script creates PDFs in `export/`:
- `export/exam.pdf` and `export/exam_answers.pdf` for the Spanish sample.
- `export/exam_en.pdf` and `export/exam_en_answers.pdf` for the English sample.

Clean the directory before committing if you do not want to version the generated files.

The generated PDFs contain a very small set of maths exercises you can replace with your own content.

## Requirements
- Pandoc (≥ 3.x recommended).
- LaTeX distribution with `lualatex`.
- Liberation fonts (install `fonts-liberation` / `fonts-liberation2` depending on your distribution).

### Install dependencies
- **Ubuntu / Debian**
  ```bash
  sudo apt update
  sudo apt install pandoc texlive-full fonts-liberation
  ```
  If `texlive-full` is too large, install `texlive`, `texlive-luatex`, and `texlive-latex-extra` instead.

- **Fedora / RHEL**
  ```bash
  sudo dnf install pandoc texlive-scheme-small texlive-luatex texlive-collection-latexrecommended texlive-booktabs
  sudo dnf install liberation-serif-fonts liberation-sans-fonts liberation-mono-fonts
  ```

- **Arch / Manjaro**
  ```bash
  sudo pacman -Syu pandoc texlive-most ttf-liberation
  ```

- **macOS**
  ```bash
  brew update
  brew install pandoc mactex-no-gui
  brew install --cask font-liberation
  ```
  After installing MacTeX, launch `/Library/TeX/texbin/texhash` or reopen the terminal so `lualatex` is on PATH.

- **Windows**
  1. Install [Pandoc](https://github.com/jgm/pandoc/releases/latest) using the MSI.
  2. Install [MiKTeX](https://miktex.org/download) including the `luatex` packages.
  3. Install [Liberation fonts](https://github.com/liberationfonts/liberation-fonts/releases) (run the `.ttf` installers).
  4. Add the Pandoc and MiKTeX binaries to the `PATH` environment variable if the installers do not do it automatically.

Check that Pandoc and the LaTeX engine work:
```bash
pandoc --version
lualatex --version
```

## Repository layout
```
filters/          # Lua filters (solution injector)
exam/             # Sample statements (questions_es.md / questions_en.md)
scripts/          # CLI exporter
templates/        # LaTeX template and original resources
export/           # Output PDFs (ignored)
```

## Customisation
1. Edit `exam/questions_es.md` or `exam/questions_en.md` to adjust the sample statements.
2. Place blocks `::: {#id .solution-placeholder}` where each answer should
   appear. Use the same IDs in the matching solutions file
   (`exam/solutions_es.md` or `exam/solutions_en.md`) as
   `::: {#id .solution}` containing the actual answer in LaTeX-friendly syntax.
3. Update the header metadata to set fonts, department, logo, etc.

### Advanced customisation
1. Default fonts are Liberation and are defined in `exam/questions_es.md`. Adjust the `mainfont`, `sansfont`, `monofont` and `mathfont` values if you want other fonts installed on the system.
2. The header supports optional metadata: `department` and `logo` (relative path to the repository). The first appears left-aligned in small caps and the second on the right.
3. To modify headers, footers or question styles, edit `templates/exam-template/exam-template.tex`.
4. The Lua filters applied are `filters/solution_injector.lua` (injects solutions) and `templates/exam-template/exam-filter.lua` (converts `@q`).
5. Change the LaTeX engine by exporting the variable before the script (for example, `PDF_ENGINE=xelatex ./scripts/export.sh`).

## Troubleshooting
1. If the command fails due to missing fonts, confirm their installation with `fc-list | grep "FontName"`.
2. For LaTeX errors, add `-V log=exam.log` to the Pandoc invocation to get a detailed log:
   ```bash
   pandoc exam/questions_es.md \
     --pdf-engine lualatex \
     --template templates/exam-template/exam-template.tex \
     --lua-filter templates/exam-template/exam-filter.lua \
     --lua-filter filters/solution_injector.lua \
     --from markdown+tex_math_dollars+tex_math_single_backslash+fenced_divs \
     -V log=exam.log -o export/exam_debug.pdf
   ```
3. Run `npx markdownlint "**/*.md"` to check Markdown formatting before generating the PDF.

## Credits
- Original LaTeX exam template by [Driss Drissi](https://idrissi.eu/post/exam-template/)
  (included in `templates/exam-template/` and translated/adapted).
- Spanish documentation is available in `README.es.md`.
