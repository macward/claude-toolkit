#!/bin/bash
set -euo pipefail

# ─── Config ──────────────────────────────────────────────────────────────────
TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"
COMMANDS_DIR="$HOME/.claude/commands"
RULES_DIR="$HOME/.claude/rules"

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
DIM='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Helpers ─────────────────────────────────────────────────────────────────
info()  { echo -e "${BLUE}▸${NC} $1" >&2; }
ok()    { echo -e "${GREEN}✓${NC} $1" >&2; }
warn()  { echo -e "${YELLOW}⚠${NC} $1" >&2; }
err()   { echo -e "${RED}✗${NC} $1" >&2; }
dim()   { echo -e "${DIM}  $1${NC}" >&2; }

is_toolkit_link() {
    local path="$1"
    if [ -L "$path" ]; then
        local real
        real="$(readlink "$path")"
        if [[ "$real" == "$TOOLKIT_DIR"* ]]; then
            return 0
        fi
    fi
    return 1
}

# ─── Item collectors ─────────────────────────────────────────────────────────
get_toolkit_skills() {
    for dir in "$TOOLKIT_DIR"/skills/*/; do
        [ -f "$dir/SKILL.md" ] && basename "$dir"
    done
}

# Prints NUL-delimited relative paths (no extension) for .md files under folder
get_toolkit_md_files_z() {
    local folder="$1"
    [ -d "$TOOLKIT_DIR/$folder" ] || return 0
    find "$TOOLKIT_DIR/$folder" -name "*.md" -type f -print0 | while IFS= read -r -d '' f; do
        local rel="${f#$TOOLKIT_DIR/$folder/}"
        printf '%s\0' "${rel%.md}"
    done
}

# ─── Generic .md symlink installer ───────────────────────────────────────────
install_md_files() {
    local folder="$1"
    local dst_dir="$2"
    local count=0

    mkdir -p "$dst_dir"

    while IFS= read -r -d '' rel; do
        local src="$TOOLKIT_DIR/$folder/${rel}.md"
        local dst="$dst_dir/${rel}.md"
        local dst_parent display_name
        dst_parent="$(dirname "$dst")"
        display_name="$(basename "$rel")"

        mkdir -p "$dst_parent"

        if is_toolkit_link "$dst"; then
            dim "$display_name (already linked)"
            count=$((count + 1))
            continue
        fi

        rm -f "$dst"
        ln -s "$src" "$dst"
        ok "$display_name"
        count=$((count + 1))
    done < <(get_toolkit_md_files_z "$folder")

    echo "$count"
}

uninstall_md_files() {
    local folder="$1"
    local dst_dir="$2"
    local removed=0

    while IFS= read -r -d '' rel; do
        local dst="$dst_dir/${rel}.md"
        local display_name
        display_name="$(basename "$rel")"
        if is_toolkit_link "$dst"; then
            rm "$dst"
            ok "removed $display_name"
            removed=$((removed + 1))
        fi
    done < <(get_toolkit_md_files_z "$folder")

    echo "$removed"
}

list_md_files() {
    local folder="$1"
    local dst_dir="$2"

    while IFS= read -r -d '' rel; do
        local dst="$dst_dir/${rel}.md"
        local display_name
        display_name="$(basename "$rel")"
        if is_toolkit_link "$dst"; then
            ok "$display_name ${DIM}(linked)${NC}"
        elif [ -f "$dst" ]; then
            warn "$display_name ${DIM}(copy — run install to link)${NC}"
        else
            err "$display_name ${DIM}(not installed)${NC}"
        fi
    done < <(get_toolkit_md_files_z "$folder")
}

# ─── Install ─────────────────────────────────────────────────────────────────
cmd_install() {
    echo -e "\n${BOLD}Installing claude-toolkit${NC}" >&2
    echo -e "${DIM}Source: $TOOLKIT_DIR${NC}\n" >&2

    mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$COMMANDS_DIR" "$RULES_DIR"

    local skill_count=0
    echo -e "${BOLD}Skills${NC}" >&2
    for name in $(get_toolkit_skills); do
        local src="$TOOLKIT_DIR/skills/$name"
        local dst="$SKILLS_DIR/$name"
        if is_toolkit_link "$dst"; then
            dim "$name (already linked)"
            skill_count=$((skill_count + 1))
            continue
        fi
        rm -rf "$dst"
        ln -s "$src" "$dst"
        ok "$name"
        skill_count=$((skill_count + 1))
    done
    echo "" >&2

    echo -e "${BOLD}Agents${NC}" >&2
    local agent_count
    agent_count=$(install_md_files "agents" "$AGENTS_DIR")
    echo "" >&2

    echo -e "${BOLD}Commands${NC}" >&2
    local command_count
    command_count=$(install_md_files "commands" "$COMMANDS_DIR")
    echo "" >&2

    echo -e "${BOLD}Rules${NC}" >&2
    local rule_count
    rule_count=$(install_md_files "rules" "$RULES_DIR")
    echo "" >&2

    echo -e "${GREEN}${BOLD}Done.${NC} $skill_count skills, $agent_count agents, $command_count commands, $rule_count rules installed." >&2
    echo "" >&2
}

# ─── Uninstall ───────────────────────────────────────────────────────────────
cmd_uninstall() {
    echo -e "\n${BOLD}Uninstalling claude-toolkit${NC}\n" >&2

    local total=0

    echo -e "${BOLD}Skills${NC}" >&2
    local skill_removed=0
    for name in $(get_toolkit_skills); do
        local dst="$SKILLS_DIR/$name"
        if is_toolkit_link "$dst"; then
            rm "$dst"
            ok "removed $name"
            skill_removed=$((skill_removed + 1))
        fi
    done
    total=$((total + skill_removed))
    echo "" >&2

    echo -e "${BOLD}Agents${NC}" >&2
    local agent_removed
    agent_removed=$(uninstall_md_files "agents" "$AGENTS_DIR")
    total=$((total + agent_removed))
    echo "" >&2

    echo -e "${BOLD}Commands${NC}" >&2
    local command_removed
    command_removed=$(uninstall_md_files "commands" "$COMMANDS_DIR")
    total=$((total + command_removed))
    echo "" >&2

    echo -e "${BOLD}Rules${NC}" >&2
    local rule_removed
    rule_removed=$(uninstall_md_files "rules" "$RULES_DIR")
    total=$((total + rule_removed))
    echo "" >&2

    if [ "$total" -eq 0 ]; then
        info "Nothing to remove — no toolkit symlinks found."
    else
        echo -e "${GREEN}${BOLD}Done.${NC} Removed $total symlinks." >&2
    fi
    echo "" >&2
}

# ─── List ────────────────────────────────────────────────────────────────────
cmd_list() {
    echo -e "\n${BOLD}claude-toolkit status${NC}\n" >&2

    echo -e "${BOLD}Skills${NC}" >&2
    for name in $(get_toolkit_skills); do
        local dst="$SKILLS_DIR/$name"
        if is_toolkit_link "$dst"; then
            ok "$name ${DIM}(linked)${NC}"
        elif [ -d "$dst" ]; then
            warn "$name ${DIM}(copy — run install to link)${NC}"
        else
            err "$name ${DIM}(not installed)${NC}"
        fi
    done

    echo "" >&2
    echo -e "${BOLD}Agents${NC}" >&2
    list_md_files "agents" "$AGENTS_DIR"

    echo "" >&2
    echo -e "${BOLD}Commands${NC}" >&2
    list_md_files "commands" "$COMMANDS_DIR"

    echo "" >&2
    echo -e "${BOLD}Rules${NC}" >&2
    list_md_files "rules" "$RULES_DIR"

    echo "" >&2
}

# ─── Usage ───────────────────────────────────────────────────────────────────
cmd_help() {
    echo -e "\n${BOLD}claude-toolkit installer${NC}\n"
    echo "Usage: ./install.sh <command>"
    echo ""
    echo "Commands:"
    echo "  install     Symlink skills, agents, commands, and rules to ~/.claude/"
    echo "  uninstall   Remove toolkit symlinks from ~/.claude/"
    echo "  list        Show install status of all toolkit items"
    echo "  help        Show this message"
    echo ""
    echo "Skills are symlinked as directories (preserving internal references)."
    echo "Agents, commands, and rules are symlinked as individual .md files."
    echo "Existing files are replaced without backup."
    echo ""
}

# ─── Main ────────────────────────────────────────────────────────────────────
case "${1:-help}" in
    install)            cmd_install ;;
    uninstall|--uninstall) cmd_uninstall ;;
    list)               cmd_list ;;
    help|-h|--help)     cmd_help ;;
    *)
        err "Unknown command: $1"
        cmd_help
        exit 1
        ;;
esac
