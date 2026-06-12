#!/usr/bin/env bash
# check-counts.sh — verify the counts quoted in README.md and docs/*.html
# against the source of truth (lib/, t/, examples/). Fails on any drift so
# the hand-written doc numbers can never silently rot.
#
# Derived facts:
#   - per-sublib public fn counts  (grep '^fn Utils::<Mod>' lib/<Mod>.stk)
#   - 6-sublib total
#   - assertion count              (grep 'assert_' t/test_utils.stk)
#   - runnable example count        (examples/*.stk)
#
# Usage: scripts/check-counts.sh   (exit 0 = docs match, 1 = drift)
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

readme="README.md"
index="docs/index.html"
report="docs/report.html"
fail=0

note() { printf 'DRIFT  %s\n' "$1"; fail=1; }
ok()   { printf 'ok     %s\n' "$1"; }

# Modules in display order.
mods="String List Hash Num Time Path"
total=0

for m in $mods; do
    have=$(grep -c "^fn Utils::$m" "lib/$m.stk")
    total=$((total + have))

    # README table row:  | String | `use Utils::String` | 24 | ...
    rd=$(grep -E "^\| $m +\| \`use Utils::$m\`" "$readme" | awk -F'|' '{gsub(/ /,"",$4); print $4}')
    # index.html cnt cell tied to this module's file
    ix=$(grep -oE "Utils::$m</td><td><code>lib/$m\.stk</code></td><td class=\"cnt\">[0-9]+" "$index" | grep -oE '[0-9]+$')

    if [[ "$rd" == "$have" ]]; then ok "README $m = $have"; else note "README $m says '$rd', source has $have"; fi
    if [[ "$ix" == "$have" ]]; then ok "index  $m = $have"; else note "index.html $m says '$ix', source has $have"; fi
done

# Totals quoted several ways across the docs.
for claim in \
    "$readme:$total functions total" \
    "$readme:(opt-in, $total fns)" \
    "$readme:\"$total composites the language" \
    "$index:$total functions across 6 modules" \
    "$index:$total composite functions" \
    "$report:$total composite fns"; do
    file=${claim%%:*}; text=${claim#*:}
    if grep -qF "$text" "$file"; then ok "total $total in $file"; else note "missing '$text' in $file (total should be $total)"; fi
done

# Assertion count -> report.html "assertions in t/" stat card.
asserts=$(grep -c 'assert_' "t/test_utils.stk")
rasserts=$(grep -oE '>[0-9]+</div><div class="stat-label">assertions' "$report" | grep -oE '[0-9]+')
if [[ "$rasserts" == "$asserts" ]]; then ok "assertions = $asserts"; else note "report.html assertions says '$rasserts', t/ has $asserts"; fi

# Runnable example count -> report.html "runnable examples" stat card.
examples=$(find examples -maxdepth 1 -name '*.stk' | wc -l | tr -d ' ')
rex=$(grep -oE '>[0-9]+</div><div class="stat-label">runnable examples' "$report" | grep -oE '[0-9]+')
if [[ "$rex" == "$examples" ]]; then ok "examples = $examples"; else note "report.html examples says '$rex', examples/ has $examples"; fi

if [[ $fail -eq 0 ]]; then
    printf '\nall doc counts match source.\n'
else
    printf '\ndoc counts drifted from source — fix the docs (or the source).\n'
fi
exit $fail
