# Guía De Exportación Del Examen

> Documentation in English is available in [README.md](README.md).

## Requisitos previos
1. Sistema Linux con acceso a Internet para instalar dependencias.
2. Paquetes básicos de LaTeX (`lualatex`) y Pandoc.
3. Fuentes Liberation (se instalan junto a la mayoría de distribuciones o con `sudo apt install fonts-liberation`).

## Instalación de dependencias
- **Ubuntu / Debian**
  ```bash
  sudo apt update
  sudo apt install pandoc texlive-full fonts-liberation
  ```
  Si `texlive-full` resulta demasiado pesado, instala `texlive`, `texlive-luatex` y `texlive-latex-extra`.

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
  Tras instalar MacTeX ejecuta `/Library/TeX/texbin/texhash` o abre una nueva terminal para que `lualatex` quede disponible.

- **Windows**
  1. Instala [Pandoc](https://github.com/jgm/pandoc/releases/latest) con el MSI.
  2. Instala [MiKTeX](https://miktex.org/download) incluyendo los paquetes `luatex`.
  3. Instala las [fuentes Liberation](https://github.com/liberationfonts/liberation-fonts/releases) (ejecuta los instaladores `.ttf`).
  4. Añade los binarios de Pandoc y MiKTeX a la variable `PATH` si los instaladores no lo hacen automáticamente.

Comprueba después que Pandoc y el motor LaTeX funcionan:
```bash
pandoc --version
lualatex --version
```

## Exportar el examen
1. Lanza el script preparado desde la raíz del repositorio:
   ```bash
   ./scripts/export.sh
   ```
   - El PDF se genera en `export/exam.pdf`.
   - El script crea automáticamente un directorio de caché en `.texmf-var` y exporta `TEXMFVAR` para evitar errores de `luaotfload` en instalaciones empaquetadas (por ejemplo, Fedora).
2. Para incluir las soluciones en el PDF (con bloques sombreados mediante la plantilla) utiliza:
   ```bash
   ./scripts/export.sh --answers
   ```
   - Se crea `export/exam_answers.pdf`.
3. Para exportar en inglés añade `--lang en` (puedes combinarlo con `--answers`).
   - La versión inglesa se guarda como `export/exam_en.pdf` o `export/exam_en_answers.pdf` si añades soluciones.
4. Cambia el motor LaTeX exportando la variable antes del script (por ejemplo, `PDF_ENGINE=xelatex ./scripts/export.sh`).

Los PDF contienen un ejemplo muy sencillo de operaciones matemáticas que puedes sustituir por tus propias preguntas y soluciones.

## Personalización
1. Las tipografías por defecto son Liberation y se definen en `exam/questions_es.md`. Ajusta los valores `mainfont`, `sansfont`, `monofont` y `mathfont` si deseas otras fuentes instaladas en el sistema.
2. El encabezado admite metadatos opcionales: `department` y `logo` (ruta relativa al repositorio). El primero aparece alineado a la izquierda en mayúsculas pequeñas y el segundo a la derecha.
3. Para modificar cabeceras, pie de página o estilos de pregunta edita `templates/exam-template/exam-template.tex`.
4. Las soluciones se guardan en `exam/solutions_es.md` (y en inglés en `exam/solutions_en.md`). como bloques `::: {#id .solution}` y se inyectan sobre los marcadores `::: {#id .solution-placeholder}` del enunciado.
5. Los filtros Lua aplicados son `filters/solution_injector.lua` (inyecta soluciones) y `templates/exam-template/exam-filter.lua` (convierte `@q`).

## Verificación y resolución de problemas
1. Si el comando falla por fuentes no encontradas, confirma su instalación con `fc-list | grep "NombreDeLaFuente"`.
2. Ante errores de LaTeX, añade `-V log=exam.log` a la invocación de Pandoc para obtener un registro detallado:
   ```bash
   pandoc exam/questions_es.md \
     --pdf-engine lualatex \
     --template templates/exam-template/exam-template.tex \
     --lua-filter templates/exam-template/exam-filter.lua \
     --lua-filter filters/solution_injector.lua \
     --from markdown+tex_math_dollars+tex_math_single_backslash+fenced_divs \
     -V log=exam.log -o export/exam_debug.pdf
   ```
3. Ejecuta `npx markdownlint "**/*.md"` para revisar el formato Markdown antes de generar el PDF.

## Estructura del repositorio
- `exam/`: ejemplos mínimos (`questions_es.md` / `questions_en.md`) y sus soluciones (`solutions_es.md` / `solutions_en.md`).
- `templates/exam-template/`: plantilla LaTeX, filtro Lua y recursos.
- `filters/`: filtros Lua propios (`solution_injector.lua`).
- `scripts/`: utilidades para compilar (`export.sh`).
- `export/`: PDFs generados (limpia esta carpeta antes de subir a GitHub).

## Historial reciente
- Simplificación a dos muestras básicas (es/en) en la carpeta `exam/`.
- Inserción automática de soluciones mediante bloques `solution-placeholder`.
- Normalización de la notación LaTeX en todas las respuestas.

## Créditos
- Plantilla base de examen por [Driss Drissi](https://idrissi.eu/post/exam-template/), adaptada y traducida para este proyecto.
