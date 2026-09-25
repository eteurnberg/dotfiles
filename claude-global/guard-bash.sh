#!/usr/bin/env bash
#
# Claude Code PreToolUse hook: refuses the handful of Bash commands whose
# damage no diff shows and no later step undoes. Wired up in settings.json
# against the Bash matcher.
#
# Contract: exit 0 lets the command through; exit 2 refuses it and hands the
# stderr text back to Claude as the reason. Any other exit is treated as a
# non-fatal hook error, which is why every failure path here exits 0 -- a
# guard that cannot run must not brick Bash in every session on the machine.
#
# Deliberately short. The permission prompt already covers "are you sure";
# this is only for the cases where being wrong is unrecoverable, and every
# rule added here is a rule paid for on every Bash call.
#
# Matching is textual and so approximate: it catches the slipped variable and
# the stray space, not a command written to evade it. The one false positive
# worth naming is avoided -- a rule fires only when its command *starts* a
# segment, so `git commit -m "guard against rm -rf /"` is left alone.

set -uo pipefail

# Branches a force-push must never rewrite.
PROTECTED_BRANCHES='master|main'

# Removal targets with nothing left to recover: the filesystem root and the
# home directory, bare or globbed, literal or by variable.
# shellcheck disable=SC2016  # a regex matching the literal text "$HOME", not an expansion
CATASTROPHIC_TARGET='(/|/\*|~|~/|~/\*|\$HOME|\$HOME/|\$HOME/\*|\$\{HOME\}|\$\{HOME\}/|\$\{HOME\}/\*)'

payload=$(cat 2>/dev/null || true)

# jq parses the command out of JSON correctly whatever quoting it contains.
# Missing, it is better to allow than to guess.
command -v jq >/dev/null 2>&1 || exit 0

cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0
cwd=$(printf '%s' "$payload" | jq -r '.cwd // ""' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

refuse() {
    printf '%s\n' "$1" >&2
    exit 2
}

# Refuses an `rm` that is both recursive and forced at a target there is no
# coming back from. Anything less and rm either stops at the first directory
# or asks, so the shell is already the guard.
check_rm() {
    local segment="$1" flags

    # Flags may be combined (-rf), separate (-r -f), in either order, or
    # spelled out. Collapsed to one string so the two tests below stay simple.
    flags=$(printf '%s' "$segment" | grep -oE '(^|[[:space:]])-[a-zA-Z]+' | tr -d ' -' | tr -d '\n')
    case "$segment" in *--recursive*) flags="${flags}r" ;; esac
    case "$segment" in *--force*) flags="${flags}f" ;; esac

    case "$flags" in *[rR]*) ;; *) return 0 ;; esac
    case "$flags" in *f*) ;; *) return 0 ;; esac

    if printf '%s' "$segment" | grep -Eq "[[:space:]]$CATASTROPHIC_TARGET([[:space:]]|\$)"; then
        refuse "Refused: this deletes the home directory or the filesystem root. If that is genuinely the intent, run it by hand outside Claude Code."
    fi
}

# Refuses a force-push that rewrites a protected branch. --force-with-lease is
# left alone on purpose: it already refuses when the remote has moved, which is
# the discipline this rule is asking for, and blocking it would only push the
# next attempt toward the blunt flag. The trailing word boundary below is what
# keeps --force from matching it.
check_git_push() {
    local segment="$1" forced=0 positional refspec target

    case "$segment" in
        *" push"*) ;;
        *) return 0 ;;
    esac

    if printf '%s' "$segment" | grep -Eq '(^|[[:space:]])(-f|--force)([[:space:]]|$)'; then
        forced=1
    fi

    # Positional arguments after `push`: remote, then refspec.
    positional=$(printf '%s' "$segment" \
        | sed -E 's/.*[[:space:]]push[[:space:]]*//' \
        | tr ' ' '\n' | grep -v '^-' | grep -v '^$')
    refspec=$(printf '%s\n' "$positional" | sed -n '2p')

    # A leading + forces that refspec on its own, with no flag anywhere.
    case "$refspec" in
        +*) forced=1; refspec=${refspec#+} ;;
    esac

    [ "$forced" -eq 1 ] || return 0

    if [ -n "$refspec" ]; then
        # src:dst -- the destination is the branch actually being rewritten.
        target=${refspec##*:}
    else
        # No refspec: push.default=simple in .gitconfig sends the current branch.
        target=$(git -C "${cwd:-.}" --no-optional-locks branch --show-current 2>/dev/null || true)
    fi

    if printf '%s' "$target" | grep -Eq "^($PROTECTED_BRANCHES)\$"; then
        refuse "Refused: force-pushing $target rewrites history others have. Use --force-with-lease, or push to a branch and open a PR."
    fi
}

# One simple command per line, so that a rule sees the invocation it belongs
# to rather than its neighbour's arguments.
# shellcheck disable=SC2020  # char-for-char is exactly what's wanted: each of ; & | becomes a newline
segments=$(printf '%s' "$cmd" | tr ';&|' '\n\n\n')

while IFS= read -r segment; do
    # Leading whitespace, and the wrappers that still leave the next word as
    # the command being run.
    segment="${segment#"${segment%%[![:space:]]*}"}"
    while :; do
        case "$segment" in
            sudo\ *|command\ *|time\ *|nohup\ *) segment="${segment#* }"
                segment="${segment#"${segment%%[![:space:]]*}"}" ;;
            *) break ;;
        esac
    done

    # A rule fires only when its command starts the segment -- that is what
    # keeps quoted text in someone else's arguments from tripping it.
    case "$segment" in
        rm\ *|/bin/rm\ *|/usr/bin/rm\ *) check_rm "$segment" ;;
        git\ *|/usr/bin/git\ *) check_git_push "$segment" ;;
    esac
done <<EOF
$segments
EOF

exit 0
