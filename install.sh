#!/usr/bin/env sh
# Spec-Driven Dev — Installer / Updater / Uninstaller
# Usage: sh install.sh [--update] [--uninstall]
#
# Installs .spec-driven-dev/ core into the current directory.
# With --update:    refreshes core files, preserves state/.
# With --uninstall: removes core files (preserves state/ archive).

set -e

VERSION="1.2.0"
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

while [ $# -gt 0 ]; do
  case "$1" in
    --update)    IS_UPDATE=true ;;
    --uninstall) IS_UNINSTALL=true ;;
    *)           die "Unknown flag: $1. Usage: sh install.sh [--update] [--uninstall]" ;;
  esac
  shift
done

# --- uninstall ---

if [ "$IS_UNINSTALL" = true ]; then
  header "Spec-Driven Dev — Uninstall"

  if [ ! -d "$CORE_DIR" ]; then
    info "Nothing to uninstall — .spec-driven-dev/ not found."
    exit 0
  fi

  warn "This will remove .spec-driven-dev/."
  printf "  Continue? [y/N] "
  read -r answer
  case "$answer" in
    [yY]*) ;;
    *)     printf "  Aborted.\n"; exit 0 ;;
  esac

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
        rm -f "$CORE_DIR/templates/explore.md"
        rm -f "$CORE_DIR/templates/requirements.md"
        rm -f "$CORE_DIR/templates/design.md"
        rm -f "$CORE_DIR/templates/implementation.md"
        rm -f "$CORE_DIR/templates/verify.md"
        rm -f "$CORE_DIR/config.yaml"
        rm -f "$CORE_DIR/state/pipeline.kv"
        rm -f "$CORE_DIR/state/pipeline.json"
        info "Core removed. Archives preserved in .spec-driven-dev/state/archive/"
        ;;
    esac
  else
    rm -rf "$CORE_DIR"
  fi

  info "Uninstall complete."
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
# Must check for actual source file, not just directory (mkdir above creates .spec-driven-dev/)
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
LOCAL_SOURCE="$SCRIPT_DIR/.spec-driven-dev"
IS_REMOTE=false

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$LOCAL_SOURCE/skill.md" ]; then
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
copy_core_file "templates/explore.md"
copy_core_file "templates/verify.md"

chmod +x "$CORE_DIR/scripts/pipeline.sh"

# --- generate starter config.yaml (only on fresh install) ---

if [ ! -f "$CORE_DIR/config.yaml" ]; then
  cat > "$CORE_DIR/config.yaml" << 'CONFIGEOF'
# Project configuration for spec-driven development.
# AI agents read this file before each phase to get project context.
# Uncomment and fill in the sections relevant to your project.

# context: |
#   Tech stack: ...
#   Testing: ...
#   Build: ...
#   Lint: ...
#   Conventions: ...
#   Repo structure: ...

# rules:
#   requirements:
#     - ...
#   design:
#     - ...
#   implementation:
#     - ...
CONFIGEOF
  info "config.yaml (starter template)"
else
  info "config.yaml (preserved)"
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
