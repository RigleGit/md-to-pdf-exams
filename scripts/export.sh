#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage:
  export.sh [--answers] [--lang es|en]

Options:
  --answers   Generate a version with solutions (shaded blocks).
  --lang      Language of the exam (default: es).
  -h, --help  Show this help message.

Environment variables:
  PDF_ENGINE  LaTeX engine used by Pandoc (default: lualatex).
EOF
}

TARGET_LANG="es"
ANSWERS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --answers)
      ANSWERS=true
      shift
      ;;
    --lang)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --lang requires a value (es/en)." >&2
        exit 1
      fi
      TARGET_LANG="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="${ROOT_DIR}/templates/exam-template"

case "${TARGET_LANG}" in
  es)
    INPUT="${ROOT_DIR}/exam/questions_es.md"
    BASENAME="exam"
    ;;
  en)
    INPUT="${ROOT_DIR}/exam/questions_en.md"
    BASENAME="exam_en"
    ;;
  *)
    echo "Unsupported language: ${TARGET_LANG}. Use es or en." >&2
    exit 1
    ;;
esac

OUTPUT_DIR="${ROOT_DIR}/export"
PDF_ENGINE="${PDF_ENGINE:-lualatex}"
TEX_CACHE_DIR="${TEXMFVAR:-${ROOT_DIR}/.texmf-var}"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc is not available in PATH. Please install it first." >&2
  exit 1
fi

if ! command -v "${PDF_ENGINE}" >/dev/null 2>&1; then
  echo "Error: the LaTeX engine '${PDF_ENGINE}' is not available in PATH." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
if ! mkdir -p "${TEX_CACHE_DIR}"; then
  echo "Error: failed to create LaTeX cache directory at '${TEX_CACHE_DIR}'." >&2
  echo "       Set TEXMFVAR to a writable directory." >&2
  exit 1
fi
export TEXMFVAR="${TEX_CACHE_DIR}"

OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}.pdf"
INPUT_USE="${INPUT}"

if "${ANSWERS}"; then
  OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}_answers.pdf"
fi

args=(
  "${INPUT_USE}"
  --pdf-engine "${PDF_ENGINE}"
  --lua-filter "${ROOT_DIR}/filters/solution_injector.lua"
  --lua-filter "${TEMPLATE_DIR}/exam-filter.lua"
  --template "${TEMPLATE_DIR}/exam-template.tex"
  --resource-path "${ROOT_DIR}"
  --metadata=exam-lang:"${TARGET_LANG}"
  --from markdown+tex_math_dollars+tex_math_single_backslash+fenced_divs
  --output "${OUTPUT_FILE}"
)

if "${ANSWERS}"; then
  args+=(--metadata=answers:true)
else
  args+=(--metadata=answers:false)
fi

pandoc "${args[@]}"

echo "PDF generated at ${OUTPUT_FILE}"
