# Generador de Exámenes (Pandoc + LaTeX)

<img src="md-to-pdf-exam.png" alt="md-to-pdf-exam logo" width="400">

Este repositorio contiene una plantilla bilingüe (español/inglés) para producir
exámenes digitales en PDF usando Pandoc, filtros Lua y una base LaTeX creada originalmente
por [Driss Drissi](https://idrissi.eu/post/exam-template/). Las preguntas se escriben
en Markdown y las soluciones se pueden almacenar en un documento separado e inyectar
automáticamente.

> Documentation in English is available in [README.md](README.md).

## Características
- Soporte para dos idiomas (`--lang es` o `--lang en`).
- Plantilla LaTeX compartida con bloques de solución sombreados.
- Archivos de soluciones externos (`exam/solutions_es.md` / `exam/solutions_en.md`) vinculados mediante
  los metadatos `solutions-file`.
- Ejemplos matemáticos mínimos en ambos idiomas (`exam/questions_es.md` y `exam/questions_en.md`).

## Inicio rápido
```bash
# Generar examen en español (por defecto)
./scripts/export.sh

# Generar examen en español con respuestas
./scripts/export.sh --answers

# Generar examen en inglés
./scripts/export.sh --lang en

# Generar examen en inglés con respuestas
./scripts/export.sh --lang en --answers
```

El script crea PDFs en `export/`:
- `export/exam.pdf` y `export/exam_answers.pdf` para la muestra en español.
- `export/exam_en.pdf` y `export/exam_en_answers.pdf` para la muestra en inglés.

Limpia el directorio antes de hacer commit si no deseas versionar los archivos generados.

Los PDFs generados contienen un conjunto muy pequeño de ejercicios matemáticos que puedes reemplazar con tu propio contenido.

## Requisitos
- Pandoc (≥ 3.x recomendado).
- Distribución LaTeX con `lualatex`.
- Fuentes Liberation (instala `fonts-liberation` / `fonts-liberation2` dependiendo de tu distribución).

### Instalación de dependencias
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

## Estructura del repositorio
```
filters/          # Filtros Lua (inyector de soluciones)
exam/             # Enunciados de ejemplo (questions_es.md / questions_en.md)
scripts/          # Exportador CLI
templates/        # Plantilla LaTeX y recursos originales
export/           # PDFs de salida (ignorado)
```

## Personalización
1. Edita `exam/questions_es.md` o `exam/questions_en.md` para ajustar los enunciados de ejemplo.
2. Coloca bloques `::: {#id .solution-placeholder}` donde debe aparecer cada respuesta. Usa los mismos IDs en el archivo de soluciones correspondiente
   (`exam/solutions_es.md` o `exam/solutions_en.md`) como
   `::: {#id .solution}` conteniendo la respuesta real en sintaxis compatible con LaTeX.
3. Actualiza los metadatos del encabezado para configurar fuentes, departamento, logo, etc.

### Personalización avanzada
1. Las tipografías por defecto son Liberation y se definen en `exam/questions_es.md`. Ajusta los valores `mainfont`, `sansfont`, `monofont` y `mathfont` si deseas otras fuentes instaladas en el sistema.
2. El encabezado admite metadatos opcionales: `department` y `logo` (ruta relativa al repositorio). El primero aparece alineado a la izquierda en mayúsculas pequeñas y el segundo a la derecha.
3. Para modificar cabeceras, pie de página o estilos de pregunta edita `templates/exam-template/exam-template.tex`.
4. Los filtros Lua aplicados son `filters/solution_injector.lua` (inyecta soluciones) y `templates/exam-template/exam-filter.lua` (convierte `@q`).
5. Cambia el motor LaTeX exportando la variable antes del script (por ejemplo, `PDF_ENGINE=xelatex ./scripts/export.sh`).

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

## Créditos
- Plantilla base de examen por [Driss Drissi](https://idrissi.eu/post/exam-template/), adaptada y traducida para este proyecto.
