#!/usr/bin/env bash
# Claude Code Notification hook: raise a desktop notification when Claude wants
# input. Wired up in settings.json for the idle_prompt|permission_prompt matcher.
#
# A script rather than an inline settings.json command so the macOS/Linux split
# stays readable instead of being escaped into a JSON string -- same reason
# statusline-command.sh is a script.

TITLE="Claude Code"
message="Claude is waiting for your input"

# The hook payload arrives on stdin and carries a per-event message, so
# idle_prompt and permission_prompt read differently. jq is optional here on
# purpose: a missing jq should downgrade the wording, not lose the notification.
input=$(cat 2>/dev/null || true)
if [ -n "$input" ] && command -v jq >/dev/null 2>&1; then
    parsed=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
    [ -n "$parsed" ] && message="$parsed"
fi

if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"${message//\"/\\\"}\" with title \"$TITLE\" sound name \"Glass\""
elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$TITLE" "$message"
fi

# No notifier available (headless, minimal container): stay silent rather than
# failing, so the hook never interrupts a session with an error.
exit 0
