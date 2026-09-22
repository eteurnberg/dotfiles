#!/usr/bin/env bash
# Claude Code Notification hook: desktop notification naming the session, the
# repo it belongs to, and what it wants. Wired up in settings.json.
#
# The payload arrives on stdin, but its .message is a fixed string for
# idle_prompt, so the specifics come from the session transcript instead.

MAX_BODY=100  # roughly what a notification renders before truncating

title="Claude Code"
subtitle=""
body="Claude is waiting for your input"
sound="Glass"
group=""

input=$(cat 2>/dev/null || true)

# Missing jq downgrades the wording rather than losing the notification.
if [ -n "$input" ] && command -v jq >/dev/null 2>&1; then
    # Unit separator, not tab: read collapses runs of IFS whitespace, so an
    # empty field would shift every field after it.
    fields=$(printf '%s' "$input" | jq -r '
        [.notification_type // "", .message // "", .cwd // "",
         .transcript_path // "", .session_id // ""]
        | map(gsub("[\n\t]"; " ")) | join("\u001f")' 2>/dev/null)
    IFS=$'\037' read -r kind message cwd transcript group <<<"$fields"
fi

condense() {
    printf '%s' "$1" | tr '\n\t' '  ' | sed 's/  */ /g; s/^ //; s/ *$//' |
        awk -v n="$MAX_BODY" '{ if (length($0) > n) printf "%s…", substr($0, 1, n - 1); else printf "%s", $0 }'
}

# 400 records is enough: a tool_result always follows its tool_use, so anything
# still unanswered sits near the tail.
tail_records() {
    tail -n 400 "$transcript" 2>/dev/null
}

# Pending = a tool_use with no matching tool_result.
pending_tool() {
    tail_records | jq -rs '
        ([ .[] | select(.type == "user") | .message.content[]?
                | select(.type == "tool_result") | .tool_use_id ]
         | map({(.): true}) | add // {}) as $done
        | [ .[] | select(.type == "assistant" and (.isSidechain | not)) | .message.content[]?
            | select(.type == "tool_use") | select($done[.id] | not) ]
        | last // empty
        | .name + ((.input.command // .input.file_path // .input.pattern // .input.url // "")
                   | if . == "" then "" else ": " + . end)' 2>/dev/null
}

last_assistant_text() {
    tail_records | jq -rs '
        [ .[] | select(.type == "assistant" and (.isSidechain | not))
              | .message.content[]? | select(.type == "text") | .text ] | last // empty' 2>/dev/null
}

if [ -n "${transcript:-}" ] && [ -r "${transcript:-}" ]; then
    # Claude Code names the session itself, but not until a few turns in.
    title=$(grep '"type":"ai-title"' "$transcript" 2>/dev/null | tail -1 | jq -r '.aiTitle // empty' 2>/dev/null)
    [ -n "$title" ] ||
        title=$(grep '"type":"last-prompt"' "$transcript" 2>/dev/null | tail -1 | jq -r '.lastPrompt // empty' 2>/dev/null)
fi

project=""
branch=""
if [ -n "${cwd:-}" ]; then
    project=$(basename "$cwd")
    # Skip optional locks so this never blocks or writes to the repo.
    if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
        [ -n "$branch" ] || branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    fi
fi

case "${kind:-}" in
    permission_prompt)
        label="Permission"
        detail=$(pending_tool)
        ;;
    idle_prompt)
        label="Waiting"
        sound="Tink"
        detail=$(last_assistant_text)
        ;;
    agent_needs_input)
        label="Agent needs input"
        detail="$message"
        ;;
    agent_completed)
        label="Agent finished"
        sound="Blow"
        detail="$message"
        ;;
    auth_success)
        label="Auth"
        sound="Blow"
        detail="$message"
        ;;
    elicitation_dialog | elicitation_url_dialog)
        label="Input requested"
        detail="$message"
        ;;
    *)
        label=""
        detail="$message"
        ;;
esac

[ -n "$detail" ] || detail="$message"
[ -n "$detail" ] && body=$(condense "$detail")
[ -n "$title" ] && title=$(condense "$title") || title="${project:-Claude Code}"

subtitle="$project${branch:+ · $branch}"
[ -n "$label" ] && subtitle="${subtitle:+$subtitle — }$label"

if command -v terminal-notifier >/dev/null 2>&1; then
    args=(-title "$title" -subtitle "$subtitle" -message "$body" -sound "$sound")
    # One live notification per session, replaced rather than stacked.
    [ -n "${group:-}" ] && args+=(-group "$group")
    # Pane ids are globally unique, so the window resolves from the pane alone.
    if [ -n "${TMUX_PANE:-}" ]; then
        focus="tmux select-window -t '$TMUX_PANE'; tmux select-pane -t '$TMUX_PANE'"
        [ -n "${__CFBundleIdentifier:-}" ] && focus="open -b '$__CFBundleIdentifier'; $focus"
        args+=(-execute "$focus")
    fi
    terminal-notifier "${args[@]}" >/dev/null 2>&1
elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$subtitle
$body"
fi

# Never fail: a non-zero exit would surface as an error in the session.
exit 0
