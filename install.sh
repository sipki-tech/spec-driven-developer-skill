#!/usr/bin/env sh
# Spec-Driven Dev — Installer / Updater / Uninstaller
# Usage: sh install.sh [--update] [--uninstall] [--all-ides]
#
# Installs .spec-driven-dev/ core and creates IDE-specific adapters.
# With --update:    refreshes core files, preserves state/ and existing adapters.
# With --uninstall: removes core files and adapters (preserves state/ archive).
# With --all-ides:  install adapters for all supported IDEs regardless of detection.

set -e

VERSION="1.1.0"
REPO_RAW="https://raw.githubusercontent.com/sipki-tech/spec-driven-developer-skill"
REPO_BRANCH="main"

# --- helpers ---

die()   { printf "  \033[31m✗\033[0m %s\n" "$*" >&2; exit 1; }
info()  { printf "  \033[32m✓\033[0m %s\n" "$*"; }
warn()  { printf "  \033[33m⚠\033[0m %s\n" "$*"; }
skip()  { printf "  \033[90m–\033[0m %s (skipped)\n" "$*"; }
header(){ printf "\n\033[1m%s\033[0m\n" "$*"; }

# HTTP fetch helper: tries curl, then wget
fetch_url() {
  local url="$1" dest="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$dest" "$url"
  else
    die "Neither curl nor wget found. Install one and retry."
  fi
}

# --- parse flags ---

PROJECT_ROOT="$(pwd)"
CORE_DIR="$PROJECT_ROOT/.spec-driven-dev"
IS_UPDATE=false
IS_UNINSTALL=false
ALL_IDES=false

for arg in "$@"; do
  case "$arg" in
    --update)    IS_UPDATE=true ;;
    --uninstall) IS_UNINSTALL=true ;;
    --all-ides)  ALL_IDES=true ;;
    *)           die "Unknown flag: $arg. Usage: sh install.sh [--update] [--uninstall] [--all-ides]" ;;
  esac
done

# --- uninstall ---

if [ "$IS_UNINSTALL" = true ]; then
  header "Spec-Driven Dev — Uninstall"

  if [ ! -d "$CORE_DIR" ]; then
    info "Nothing to uninstall — .spec-driven-dev/ not found."
    exit 0
  fi

  warn "This will remove .spec-driven-dev/ and all IDE adapters."
  printf "  Continue? [y/N] "
  read -r answer
  case "$answer" in
    [yY]*) ;;
    *)     printf "  Aborted.\n"; exit 0 ;;
  esac

  # Remove IDE adapter files
  rm -f "$PROJECT_ROOT/.cursor/rules/spec-driven-dev.mdc"
  rm -f "$PROJECT_ROOT/.kiro/specs/spec-driven-dev.md"
  rm -f "$PROJECT_ROOT/.antigravity/agents.yaml"

  # Remove .spec-driven-dev/ (preserve archive if user wants)
  if [ -d "$CORE_DIR/state/archive" ] && [ "$(find "$CORE_DIR/state/archive" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
    warn "Archives found in .spec-driven-dev/state/archive/"
    printf "  Remove archives too? [y/N] "
    read -r answer
    case "$answer" in
      [yY]*) rm -rf "$CORE_DIR" ;;
      *)
        # Remove everything except state/archive
        rm -f "$CORE_DIR/skill.md"
        rm -f "$CORE_DIR/scripts/pipeline.sh"
        rm -f "$CORE_DIR/templates/requirements.md"
        rm -f "$CORE_DIR/templates/design.md"
        rm -f "$CORE_DIR/templates/implementation.md"
        rm -f "$CORE_DIR/state/pipeline.kv"
        rm -f "$CORE_DIR/state/pipeline.json"
        info "Core removed. Archives preserved in .spec-driven-dev/state/archive/"
        ;;
    esac
  else
    rm -rf "$CORE_DIR"
  fi

  info "Uninstall complete."
  warn "Note: sections appended to .windsurfrules, CLAUDE.md, .github/copilot-instructions.md must be removed manually."
  exit 0
fi

# --- install core ---

header "Spec-Driven Dev v${VERSION}"

if [ -d "$CORE_DIR" ] && [ "$IS_UPDATE" = false ]; then
  warn ".spec-driven-dev/ already exists."
  printf "  Reinstall core files? (state/ will be preserved) [y/N] "
  read -r answer
  case "$answer" in
    [yY]*) IS_UPDATE=true ;;
    *)     printf "  Aborted. Use --update to refresh.\n"; exit 0 ;;
  esac
fi

header "Installing core..."

mkdir -p "$CORE_DIR/templates"
mkdir -p "$CORE_DIR/scripts"
mkdir -p "$CORE_DIR/state/archive"

# Detect source: local clone or remote (curl pipe)
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
LOCAL_SOURCE="$SCRIPT_DIR/.spec-driven-dev"
IS_REMOTE=false

if [ -z "$SCRIPT_DIR" ] || [ ! -d "$LOCAL_SOURCE" ]; then
  IS_REMOTE=true
  info "No local source found — downloading from GitHub..."
fi

copy_core_file() {
  local file="$1"
  local dst="$CORE_DIR/$file"

  if [ "$IS_REMOTE" = true ]; then
    local url="${REPO_RAW}/${REPO_BRANCH}/.spec-driven-dev/${file}"
    fetch_url "$url" "$dst" || die "$file — download failed from $url"
    info "$file (downloaded)"
  else
    local src="$LOCAL_SOURCE/$file"
    if [ ! -f "$src" ]; then
      die "$file — source not found at $src"
    fi
    # Skip if source and destination are the same file
    if [ "$src" = "$dst" ]; then
      info "$file (already in place)"
    else
      cp "$src" "$dst"
      info "$file"
    fi
  fi
}

copy_core_file "skill.md"
copy_core_file "scripts/pipeline.sh"
copy_core_file "templates/requirements.md"
copy_core_file "templates/design.md"
copy_core_file "templates/implementation.md"

chmod +x "$CORE_DIR/scripts/pipeline.sh"

# --- detect and install IDE adapters ---

header "Detecting IDEs..."

# JSON fallback note for IDEs that may not support shell
JSON_FALLBACK="
> Note: If your IDE does not support running shell commands, check \`.spec-driven-dev/state/pipeline.json\` directly for the current pipeline state."

install_adapter() {
  local name="$1"
  local path="$2"
  local content="$3"
  local mode="${4:-create}"   # create | append

  if [ "$IS_UPDATE" = true ] && [ -f "$PROJECT_ROOT/$path" ]; then
    skip "$name — adapter exists (use manual update)"
    return
  fi

  local dir
  dir="$(dirname "$PROJECT_ROOT/$path")"
  mkdir -p "$dir"

  if [ "$mode" = "append" ] && [ -f "$PROJECT_ROOT/$path" ]; then
    # Check if already contains our section (fixed-string match)
    if grep -qF "spec-driven-dev" "$PROJECT_ROOT/$path" 2>/dev/null; then
      skip "$name — section already present"
      return
    fi
    # Ensure file ends with newline before appending
    if [ -s "$PROJECT_ROOT/$path" ] && [ -n "$(tail -c1 "$PROJECT_ROOT/$path")" ]; then
      echo "" >> "$PROJECT_ROOT/$path"
    fi
    printf "%s" "$content" >> "$PROJECT_ROOT/$path"
    info "$name — section appended to $path"
  else
    printf "%s" "$content" > "$PROJECT_ROOT/$path"
    info "$name — created $path"
  fi
}

# Cursor
if [ -d "$PROJECT_ROOT/.cursor" ] || [ "$ALL_IDES" = true ]; then
  install_adapter "Cursor" ".cursor/rules/spec-driven-dev.mdc" \
"---
description: Spec-driven development workflow with 3-phase pipeline
globs: \"**/*\"
alwaysApply: true
---

Read and follow \`.spec-driven-dev/skill.md\` for all feature development.
Before starting any feature, run: \`sh .spec-driven-dev/scripts/pipeline.sh status\`
${JSON_FALLBACK}
"
fi

# Windsurf
if [ -f "$PROJECT_ROOT/.windsurfrules" ] || [ "$ALL_IDES" = true ]; then
  install_adapter "Windsurf" ".windsurfrules" \
"## Spec-Driven Development

Read and follow \`.spec-driven-dev/skill.md\` for all feature development.
Before starting any feature, run: \`sh .spec-driven-dev/scripts/pipeline.sh status\`
${JSON_FALLBACK}
" "append"
fi

# Claude Code
if [ -f "$PROJECT_ROOT/CLAUDE.md" ] || [ "$ALL_IDES" = true ]; then
  install_adapter "Claude Code" "CLAUDE.md" \
"## Spec-Driven Development

Read and follow \`.spec-driven-dev/skill.md\` for all feature development.
Before starting any feature, run: \`sh .spec-driven-dev/scripts/pipeline.sh status\`
${JSON_FALLBACK}
" "append"
fi

# VSCode Copilot
if [ -d "$PROJECT_ROOT/.github" ] || [ "$ALL_IDES" = true ]; then
  install_adapter "VSCode Copilot" ".github/copilot-instructions.md" \
"## Spec-Driven Development

Read and follow \`.spec-driven-dev/skill.md\` for all feature development.
Before starting any feature, run: \`sh .spec-driven-dev/scripts/pipeline.sh status\`
${JSON_FALLBACK}
" "append"
fi

# Kiro
if [ -d "$PROJECT_ROOT/.kiro" ] || [ "$ALL_IDES" = true ]; then
  install_adapter "Kiro" ".kiro/specs/spec-driven-dev.md" \
"## Spec-Driven Development

This project uses a custom spec-driven pipeline in \`.spec-driven-dev/\`.
Refer to \`.spec-driven-dev/skill.md\` for the full workflow.
Phase templates are in \`.spec-driven-dev/templates/\`.
State is managed via \`sh .spec-driven-dev/scripts/pipeline.sh\`.
${JSON_FALLBACK}
"
fi

# Antigravity
if [ -d "$PROJECT_ROOT/.antigravity" ] || [ "$ALL_IDES" = true ]; then
  install_adapter "Antigravity" ".antigravity/agents.yaml" \
"agents:
  spec-driven-dev:
    description: 'Spec-driven development: 3-phase pipeline with approval gates'
    instructions: .spec-driven-dev/skill.md
    tools:
      - shell: sh .spec-driven-dev/scripts/pipeline.sh
"
fi

# --- gitignore ---

header "Configuring .gitignore..."

GITIGNORE="$PROJECT_ROOT/.gitignore"
IGNORE_LINE=".spec-driven-dev/state/"

if [ -f "$GITIGNORE" ]; then
  if grep -qF "$IGNORE_LINE" "$GITIGNORE" 2>/dev/null; then
    skip "state/ already in .gitignore"
  else
    # Ensure file ends with newline before appending
    if [ -s "$GITIGNORE" ] && [ -n "$(tail -c1 "$GITIGNORE")" ]; then
      echo "" >> "$GITIGNORE"
    fi
    echo "$IGNORE_LINE" >> "$GITIGNORE"
    info "Added $IGNORE_LINE to .gitignore"
  fi
else
  echo "$IGNORE_LINE" > "$GITIGNORE"
  info "Created .gitignore with $IGNORE_LINE"
fi

# --- done ---

header "Done!"
echo ""
echo "  To start a spec-driven pipeline:"
echo "    sh .spec-driven-dev/scripts/pipeline.sh init <feature-name>"
echo ""
echo "  Or just tell your AI assistant:"
echo "    \"I want to add <feature description>\""
echo ""
