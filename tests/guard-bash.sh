#!/usr/bin/env bash
#
# Tests for claude-global/guard-bash.sh.
#
# The guard fails open by design -- a broken hook must not brick Bash in every
# session -- which also means a broken *rule* is silent. That is what this
# exists for. Run it after touching any pattern in the guard.
#
#   ./tests/guard-bash.sh     exits 0 when every case matches expectation

set -uo pipefail

GUARD="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/claude-global/guard-bash.sh"
FAILURES=0

# run <BLOCK|ALLOW> <command> [cwd]
run() {
    local want="$1" cmd="$2" cwd="${3:-$PWD}" output status got

    output=$(jq -nc --arg c "$cmd" --arg d "$cwd" \
        '{tool_name: "Bash", cwd: $d, tool_input: {command: $c}}' \
        | bash "$GUARD" 2>&1)
    status=$?

    # Only exit 2 refuses; anything else lets the command through.
    if [ "$status" -eq 2 ]; then got=BLOCK; else got=ALLOW; fi

    if [ "$got" = "$want" ]; then
        printf '  ok    %-5s  %s\n' "$got" "$cmd"
    else
        printf '  FAIL  want=%s got=%s  %s\n          %s\n' "$want" "$got" "$cmd" "$output"
        FAILURES=$((FAILURES + 1))
    fi
}

# A throwaway repo on master, for the force-push cases that carry no refspec
# and so depend on which branch HEAD is actually on.
MASTER_REPO="$(mktemp -d)"
trap 'rm -rf "$MASTER_REPO"' EXIT
git -C "$MASTER_REPO" init -q -b master
git -C "$MASTER_REPO" commit -q --allow-empty -m init

echo "rm: refused"
run BLOCK 'rm -rf ~'
run BLOCK 'rm -rf /'
# shellcheck disable=SC2016  # literal text for the guard to match, not an expansion
run BLOCK 'rm -rf $HOME'
# shellcheck disable=SC2016  # literal text for the guard to match, not an expansion
run BLOCK 'rm -rf ${HOME}/'
run BLOCK 'rm -fr ~/'
run BLOCK 'rm -r -f ~'
run BLOCK 'rm --recursive --force ~'
run BLOCK 'rm -rf /*'
run BLOCK 'sudo rm -rf /'
run BLOCK 'echo hi && rm -rf /'
run BLOCK 'cd /tmp; rm -rf ~'

echo "rm: allowed"
run ALLOW 'rm -rf node_modules'
run ALLOW 'rm -rf ./build'
run ALLOW 'rm -rf /tmp/scratch'
run ALLOW 'rm -i ~'
run ALLOW 'rm ~/notes.txt'
run ALLOW 'ls -la ~'

echo "force-push: refused"
run BLOCK 'git push --force origin master'
run BLOCK 'git push -f origin main'
run BLOCK 'git push origin +master'
run BLOCK 'git push --force origin HEAD:master'
run BLOCK 'git push --force' "$MASTER_REPO"
run BLOCK 'git push -f' "$MASTER_REPO"

echo "force-push: allowed"
run ALLOW 'git push origin master'
run ALLOW 'git push --force-with-lease origin master'
run ALLOW 'git push --force origin feature/x'
run ALLOW 'git push' "$MASTER_REPO"

# The rules match text, so the thing most likely to break them is text that
# merely mentions a dangerous command.
echo "quoted arguments: not a command"
run ALLOW 'git commit -m "guard against rm -rf / and git push --force origin master"'
run ALLOW 'echo "rm -rf ~"'
run ALLOW 'npm run build'

echo
if [ "$FAILURES" -eq 0 ]; then
    echo "All cases passed."
else
    echo "$FAILURES case(s) failed." >&2
fi
exit $((FAILURES > 0))
