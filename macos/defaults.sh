#!/usr/bin/env bash
#
# macOS system settings for this machine.
#
# Idempotent: every setting is compared against the live value first, so a
# re-run that finds nothing to change writes nothing and restarts nothing.
#
# Run --diff first. It reads the same settings and reports where this machine
# differs from the list below, changing nothing -- which is also how a setting
# tweaked by hand in System Settings gets noticed and folded back in here.
#
# Usage:
#   ./macos/defaults.sh               apply every setting
#   ./macos/defaults.sh dock finder   apply only the named group(s)
#   ./macos/defaults.sh --diff        report differences, change nothing
#   ./macos/defaults.sh --diff dock   ... for one group
#   ./macos/defaults.sh --no-restart  apply without restarting Dock/Finder
#   ./macos/defaults.sh --list        list the groups
#   ./macos/defaults.sh --help        this message
#
# Appearance, keyboard, pointer and trackpad settings are read at login, so
# those need a logout to take effect -- no killall helps. The script says so
# once it has written one.
#
# Quit System Settings before running this: it caches these domains and writes
# its copy back when it closes, silently undoing what's written here.
#
# Written for bash 3.2, which is what macOS still ships (so: no associative
# arrays).

set -euo pipefail

# Variables, make any wanted changes here

# Needed twice: as the literal string the preference holds -- screencapture
# expands the tilde itself, and leaving it unexpanded keeps the plist portable
# across machines/usernames -- and as a real path for mkdir.
# shellcheck disable=SC2088  # unexpanded on purpose -- screencapture expands it
SCREENSHOT_PREF="~/Documents/screenshots"
SCREENSHOT_DIR="$HOME/Documents/screenshots"

SETTING_GROUPS=(appearance keyboard mouse trackpad dock finder screenshots clock windows)

# Every setting this script owns, as "group|scope|domain|key|type|value".
#
#   group  selects records on the command line and names the ==> banner;
#          a group's records must stay contiguous
#   scope  "user", or "host" for the per-machine ByHost store (-currentHost)
#   type   the `defaults write` flag, without its dash
#   value  free-form, and the only field that may contain "|" or spaces
#
# The type mirrors what System Settings already stores for each key (checked
# with `defaults read-type`) rather than what the key looks like it should be:
# the Trackpad pane ignores a Clicking written as a boolean rather than an
# integer, and the clock ignores a ShowDate written as a boolean rather than
# its enum.
SETTINGS=(
    "appearance|user|NSGlobalDomain|AppleInterfaceStyle|string|Dark"
    # Without this, Auto appearance rewrites AppleInterfaceStyle twice a day
    # and the value above silently loses
    "appearance|user|NSGlobalDomain|AppleInterfaceStyleSwitchesAutomatically|bool|false"

    "keyboard|user|NSGlobalDomain|KeyRepeat|int|2"
    "keyboard|user|NSGlobalDomain|InitialKeyRepeat|int|30"
    "keyboard|user|NSGlobalDomain|NSAutomaticCapitalizationEnabled|bool|true"
    "keyboard|user|NSGlobalDomain|NSAutomaticPeriodSubstitutionEnabled|bool|true"
    "keyboard|user|NSGlobalDomain|NSAutomaticDashSubstitutionEnabled|bool|false"
    "keyboard|user|NSGlobalDomain|NSAutomaticQuoteSubstitutionEnabled|bool|false"
    "keyboard|user|NSGlobalDomain|ApplePressAndHoldEnabled|bool|false"

    "mouse|user|NSGlobalDomain|com.apple.swipescrolldirection|bool|false"
    "mouse|user|NSGlobalDomain|com.apple.mouse.scaling|float|0.125"

    # All three stores have to agree. The two driver domains are what the
    # hardware reads; the ByHost globals are what the Trackpad pane reads, and
    # leaving them stale lets the pane push the old values back over the rest.
    "trackpad|user|com.apple.AppleMultitouchTrackpad|Clicking|int|0"
    "trackpad|user|com.apple.AppleMultitouchTrackpad|Dragging|int|0"
    "trackpad|user|com.apple.AppleMultitouchTrackpad|TrackpadThreeFingerDrag|bool|false"
    "trackpad|user|com.apple.AppleMultitouchTrackpad|TrackpadRightClick|bool|true"
    "trackpad|user|com.apple.AppleMultitouchTrackpad|TrackpadCornerSecondaryClick|int|0"
    "trackpad|user|com.apple.driver.AppleBluetoothMultitouch.trackpad|Clicking|int|0"
    "trackpad|user|com.apple.driver.AppleBluetoothMultitouch.trackpad|Dragging|int|0"
    "trackpad|user|com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadThreeFingerDrag|bool|false"
    "trackpad|user|com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadRightClick|bool|true"
    "trackpad|user|com.apple.driver.AppleBluetoothMultitouch.trackpad|TrackpadCornerSecondaryClick|int|0"
    "trackpad|host|NSGlobalDomain|com.apple.mouse.tapBehavior|int|0"
    "trackpad|host|NSGlobalDomain|com.apple.trackpad.enableSecondaryClick|bool|true"
    "trackpad|host|NSGlobalDomain|com.apple.trackpad.threeFingerDragGesture|bool|false"

    "dock|user|com.apple.dock|autohide|bool|true"
    "dock|user|com.apple.dock|magnification|bool|true"
    "dock|user|com.apple.dock|tilesize|int|58"
    "dock|user|com.apple.dock|largesize|int|79"
    "dock|user|com.apple.dock|showAppExposeGestureEnabled|bool|true"
    "dock|user|com.apple.dock|showMissionControlGestureEnabled|bool|true"
    # Bottom-right hot corner: 14 is Quick Note, 0 no modifier key
    "dock|user|com.apple.dock|wvous-br-corner|int|14"
    "dock|user|com.apple.dock|wvous-br-modifier|int|0"

    "finder|user|NSGlobalDomain|AppleShowAllExtensions|bool|true"
    # Nlsv is list view, and only applies to folders with no view of their own
    # saved in .DS_Store
    "finder|user|com.apple.finder|FXPreferredViewStyle|string|Nlsv"
    "finder|user|com.apple.finder|ShowHardDrivesOnDesktop|bool|false"
    "finder|user|com.apple.finder|ShowExternalHardDrivesOnDesktop|bool|true"
    "finder|user|com.apple.finder|ShowRemovableMediaOnDesktop|bool|true"
    "finder|user|com.apple.finder|ShowPathbar|bool|true"
    "finder|user|com.apple.finder|ShowStatusBar|bool|true"
    "finder|user|com.apple.finder|_FXSortFoldersFirst|bool|true"
    "finder|user|com.apple.finder|FXDefaultSearchScope|string|SCcf"
    "finder|user|com.apple.finder|FXEnableExtensionChangeWarning|bool|false"

    "screenshots|user|com.apple.screencapture|location|string|$SCREENSHOT_PREF"
    "screenshots|user|com.apple.screencapture|target|string|file"

    # ShowAMPM does nothing under a 24-hour locale; kept for portability
    "clock|user|com.apple.menuextra.clock|ShowAMPM|bool|true"
    "clock|user|com.apple.menuextra.clock|ShowDate|int|0"
    "clock|user|com.apple.menuextra.clock|ShowDayOfWeek|bool|true"

    "windows|user|com.apple.WindowManager|HideDesktop|bool|true"
    "windows|user|com.apple.WindowManager|EnableTiledWindowMargins|bool|false"
    "windows|user|com.apple.WindowManager|AutoHide|bool|false"
    "windows|user|com.apple.WindowManager|StageManagerHideWidgets|bool|false"
)

# Restarted in this order, and only when their domain was written to.
RESTART_APPS=(Dock Finder WindowManager ControlCenter)

SELECTED_GROUPS=()
PENDING_RESTARTS=""
NEEDS_LOGOUT=0
DIFF_MODE=0
RESTART=1

group_description() {
    case "$1" in
        appearance)  echo "Dark mode" ;;
        keyboard)    echo "Key repeat rate and text substitutions" ;;
        mouse)       echo "Pointer speed and scroll direction" ;;
        trackpad)    echo "Tap, drag and secondary-click behaviour" ;;
        dock)        echo "Dock size, magnification, autohide and hot corners" ;;
        finder)      echo "Finder view, desktop items and path/status bars" ;;
        screenshots) echo "Where screenshots are saved, and in what format" ;;
        clock)       echo "Menu bar clock" ;;
        windows)     echo "Stage Manager, tiling and desktop visibility" ;;
        *)           echo "(no description)" ;;
    esac
}

# Splits one SETTINGS record into the SETTING_* globals. Both the writer and
# the differ need all six fields, and bash 3.2 has no way to return a record,
# so the fields come back as globals rather than being re-split per call site.
parse_setting() {
    local record="$1"
    IFS='|' read -r SETTING_GROUP SETTING_SCOPE SETTING_DOMAIN SETTING_KEY \
        SETTING_TYPE SETTING_VALUE <<<"$record"
}

# Routes a defaults invocation at the store the current record lives in. The
# ByHost store is a separate plist that `defaults` only reaches with
# -currentHost; reading the wrong one reports the key as unset.
setting_defaults() {
    if [ "$SETTING_SCOPE" = "host" ]; then
        defaults -currentHost "$@"
    else
        defaults "$@"
    fi
}

# No groups named means all of them. The count is checked first because
# expanding an empty array trips `set -u` on bash 3.2.
setting_selected() {
    local group

    if [ "${#SELECTED_GROUPS[@]}" -eq 0 ]; then
        return 0
    fi
    for group in "${SELECTED_GROUPS[@]}"; do
        [ "$group" = "$SETTING_GROUP" ] && return 0
    done
    return 1
}

# Echoes the live value of the current record, or nothing when it is unset --
# `defaults read` reports both a missing key and a missing domain on stderr and
# exits 1, which is an expected outcome here rather than a failure.
read_live_setting() {
    local value

    value="$(setting_defaults read "$SETTING_DOMAIN" "$SETTING_KEY" 2>/dev/null || true)"
    # Collapses the multi-line form a dict or array reads back as, so a key
    # holding an unexpected type stays one row of the diff table
    echo "${value//$'\n'/ }"
}

# Reduces a value to a form both sides of a comparison can be tested on:
# `defaults read` prints booleans as 1/0 whichever flag wrote them, and prints
# reals at round-trip precision, so 0.125 can come back as 0.12500000000000001.
# A non-numeric value passes through untouched, so a key holding the wrong type
# shows up as a difference instead of collapsing to 0.
normalize_setting_value() {
    local type="$1" value="$2"

    case "$type" in
        bool)
            case "$value" in
                1|true|yes) echo "1" ;;
                *)          echo "0" ;;
            esac
            ;;
        int|float)
            if [ -n "$value" ] && [[ "$value" != *[!0-9.eE+-]* ]]; then
                awk -v number="$value" 'BEGIN { printf "%.10g\n", number }'
            else
                echo "$value"
            fi
            ;;
        *)
            echo "$value"
            ;;
    esac
}

# True when the live system already holds the current record's value. An unset
# key reads as empty and is always a difference; no record here wants an empty
# value, so that cannot produce a false mismatch.
setting_matches() {
    local live expected

    live="$(read_live_setting)"
    [ -n "$live" ] || return 1

    live="$(normalize_setting_value "$SETTING_TYPE" "$live")"
    expected="$(normalize_setting_value "$SETTING_TYPE" "$SETTING_VALUE")"
    [ "$live" = "$expected" ]
}

# The process that re-reads a domain, if any. The global, trackpad and
# screencapture domains are deliberately absent: apps read the globals as they
# launch, the multitouch driver reads its own at login, and screencapture reads
# its preference afresh on every invocation.
restart_app_for() {
    case "$1" in
        com.apple.dock)            echo "Dock" ;;
        com.apple.finder)          echo "Finder" ;;
        com.apple.WindowManager)   echo "WindowManager" ;;
        com.apple.menuextra.clock) echo "ControlCenter" ;;
        *)                         echo "" ;;
    esac
}

# Writes the current record and remembers what that obliges the caller to
# restart. Only reached when setting_matches said no.
write_setting() {
    local app

    setting_defaults write "$SETTING_DOMAIN" "$SETTING_KEY" \
        "-$SETTING_TYPE" "$SETTING_VALUE"

    app="$(restart_app_for "$SETTING_DOMAIN")"
    if [ -n "$app" ]; then
        PENDING_RESTARTS="$PENDING_RESTARTS $app"
    fi

    case "$SETTING_GROUP" in
        appearance|keyboard|mouse|trackpad) NEEDS_LOGOUT=1 ;;
    esac
}

# screencapture cannot create its own destination, and does not report the
# failure: with the directory missing, screenshots silently land on the Desktop
# while the preference keeps reading back as set. ~/Documents is TCC-protected,
# so this prompts once for Files and Folders access.
ensure_screenshot_dir() {
    if ! mkdir -p "$SCREENSHOT_DIR" 2>/dev/null; then
        echo "Could not create $SCREENSHOT_DIR -- screenshots will keep landing on the Desktop. Grant your terminal access to Documents under System Settings > Privacy & Security > Files and Folders, then re-run." >&2
    fi
}

warn_if_system_settings_running() {
    if pgrep -x "System Settings" >/dev/null 2>&1; then
        echo "System Settings is open -- it can write its cached values back over these. Quit it and re-run." >&2
    fi
}

# Restarts only the apps whose domain this run actually wrote to. Iterating the
# fixed list rather than what was collected gives a deterministic order and
# needs no dedupe. All of these are disruptive -- killall Finder closes every
# open Finder window -- so a re-run that changed nothing must leave them alone.
restart_changed_apps() {
    local app

    for app in "${RESTART_APPS[@]}"; do
        case " $PENDING_RESTARTS " in
            *" $app "*) ;;
            *) continue ;;
        esac
        echo "==> restart: $app"
        # killall exits 1 when the app isn't running, which is not a failure here
        killall "$app" >/dev/null 2>&1 || true
    done
}

apply_settings() {
    local record group=""

    for record in "${SETTINGS[@]}"; do
        parse_setting "$record"
        setting_selected || continue

        if [ "$SETTING_GROUP" != "$group" ]; then
            group="$SETTING_GROUP"
            echo "==> $group: $(group_description "$group")"
            [ "$group" = "screenshots" ] && ensure_screenshot_dir
        fi

        setting_matches && continue
        write_setting
        printf '    %-41s %s\n' "$SETTING_KEY" "$SETTING_VALUE"
    done

    if [ "$RESTART" -eq 1 ]; then
        restart_changed_apps
    fi

    if [ "$NEEDS_LOGOUT" -eq 1 ]; then
        echo "Appearance, keyboard, pointer and trackpad settings are only read at login -- log out and back in to apply them." >&2
    fi
}

# Column widths come from the longest domain and key in SETTINGS.
diff_settings() {
    local record live differences=0

    for record in "${SETTINGS[@]}"; do
        parse_setting "$record"
        setting_selected || continue
        setting_matches && continue

        if [ "$differences" -eq 0 ]; then
            printf '%-50s %-41s %-22s %s\n' DOMAIN KEY LIVE REPO
        fi
        differences=$((differences + 1))

        live="$(read_live_setting)"
        [ -n "$live" ] || live="<unset>"
        printf '%-50s %-41s %-22s %s\n' \
            "$SETTING_DOMAIN" "$SETTING_KEY" "$live" "$SETTING_VALUE"
    done

    if [ "$differences" -eq 0 ]; then
        echo "No differences -- this machine matches every setting here."
    fi
}

# Prints the header comment above (lines 3-29) as the usage text, so the two
# can't drift apart. Keep the range in step if that block moves.
usage() {
    sed -n '3,29p' "$0" | sed 's/^# \{0,1\}//'
}

list_groups() {
    local group
    echo "Setting groups:"
    for group in "${SETTING_GROUPS[@]}"; do
        printf '  %-12s %s\n' "$group" "$(group_description "$group")"
    done
}

is_valid_group() {
    local candidate="$1" group
    for group in "${SETTING_GROUPS[@]}"; do
        [ "$group" = "$candidate" ] && return 0
    done
    return 1
}

main() {
    local arg

    for arg in "$@"; do
        case "$arg" in
            -h|--help) usage; return 0 ;;
            -l|--list) list_groups; return 0 ;;
            -d|--diff) DIFF_MODE=1 ;;
            --no-restart) RESTART=0 ;;
            -*)
                echo "Unknown option: $arg" >&2
                echo "Try --help." >&2
                return 1
                ;;
            *)
                if ! is_valid_group "$arg"; then
                    echo "Unknown group: $arg" >&2
                    echo "Valid groups: ${SETTING_GROUPS[*]}" >&2
                    return 1
                fi
                SELECTED_GROUPS+=("$arg")
                ;;
        esac
    done

    if [ "$DIFF_MODE" -eq 1 ]; then
        diff_settings
        return 0
    fi

    warn_if_system_settings_running
    apply_settings
}

main "$@"
