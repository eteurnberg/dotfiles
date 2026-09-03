#!/usr/bin/env bash
# Claude Code statusline: model | directory | git branch | context usage
# Reads the session JSON payload from stdin (see Claude Code docs).

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
dir_name=$(basename "$dir")

# Git branch (skip optional locks so this never blocks/writes to the repo)
branch=""
if git -C "$dir" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
fi

# Context window usage (pre-calculated percentage of used context)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  ctx=$(printf "%.0f%% ctx" "$used")
else
  ctx=""
fi

# Colors (dim variants, since the statusline renders with dimmed colors)
COLOR_MODEL=$'\033[2;36m'   # dim cyan
COLOR_DIR=$'\033[2;33m'     # dim yellow
COLOR_BRANCH=$'\033[2;35m'  # dim magenta
COLOR_CTX=$'\033[2;32m'     # dim green
RESET=$'\033[0m'
SEP=$'\033[2;37m|\033[0m'

parts=()
parts+=("${COLOR_MODEL}${model}${RESET}")
parts+=("${COLOR_DIR}${dir_name}${RESET}")
if [ -n "$branch" ]; then
  parts+=("${COLOR_BRANCH}${branch}${RESET}")
fi
if [ -n "$ctx" ]; then
  parts+=("${COLOR_CTX}${ctx}${RESET}")
fi

out=""
for i in "${!parts[@]}"; do
  if [ "$i" -eq 0 ]; then
    out="${parts[$i]}"
  else
    out="${out} ${SEP} ${parts[$i]}"
  fi
done

printf "%s" "$out"
