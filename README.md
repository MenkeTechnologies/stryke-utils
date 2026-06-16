```
 ███████╗████████╗██████╗ ██╗   ██╗██╗  ██╗███████╗
 ██╔════╝╚══██╔══╝██╔══██╗╚██╗ ██╔╝██║ ██╔╝██╔════╝
 ███████╗   ██║   ██████╔╝ ╚████╔╝ █████╔╝ █████╗
 ╚════██║   ██║   ██╔══██╗  ╚██╔╝  ██╔═██╗ ██╔══╝
 ███████║   ██║   ██║  ██║   ██║   ██║  ██╗███████╗
 ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
                   [ u t i l s ]
```

[![CI](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![stryke](https://img.shields.io/badge/stryke-package-cyan.svg)](https://github.com/MenkeTechnologies/strykelang)

### `[BOUNDARY HELPERS // EVERYTHING ELSE IS A STRYKE BUILTIN]`

> *"117 composites the language doesn't already ship. Cross-checked against `%b` — zero overlap."*

`stryke-utils` is a small pure-stryke utility library: six sublibraries (`String`, `List`, `Hash`, `Num`, `Time`, `Path`) of higher-level composites that aren't already in stryke core. No `[ffi]` table, no cdylib, no helper binary — just `.stk` modules loaded on `use Utils`. Created by MenkeTechnologies.

### [`strykelang`](https://github.com/MenkeTechnologies/strykelang) &middot; [`MenkeTechnologiesMeta`](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta) · [`stryke-arrow`](https://github.com/MenkeTechnologies/stryke-arrow) · [`stryke-demo`](https://github.com/MenkeTechnologies/stryke-demo)

---

## Table of Contents

- [\[0x00\] Why a Package, Not Core](#0x00-why-a-package-not-core)
- [\[0x01\] Install](#0x01-install)
- [\[0x02\] Quick Start](#0x02-quick-start)
- [\[0x03\] Sublibraries](#0x03-sublibraries)
- [\[0x04\] What's NOT in Here](#0x04-whats-not-in-here)
- [\[0x05\] CLI](#0x05-cli)
- [\[0x06\] Tests](#0x06-tests)
- [\[0x07\] Layout](#0x07-layout)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] Why a Package, Not Core

stryke core absorbed most of the obvious composites — `slugify`,
`snake_case`, `truncate`, `levenshtein`, `chunk`, `uniq`, `group_by`,
`deep_merge`, `pick`, `omit`, `clamp`, `format_bytes`, `format_duration`,
`now_ms`, `basename`, `common_prefix`, and roughly seventy more landed
in `%b`. This package shrunk in response. What's left here is the long
tail: helpers that are still useful glue but live below the bar for core
inclusion.

| Tier | Properties | Examples |
|---|---|---|
| stryke core (`%b`, 10k+ entries) | builtins everyone needs everywhere | `length`, `keys`, `uc`, `sort`, `time`, `sprintf`, `slugify`, `chunk`, `deep_merge`, `format_bytes`, `levenshtein`, `basename`, … |
| `stryke-utils` (opt-in, 117 fns) | path-aware variants, n-ary wrappers, regex composites, the long tail | `deep_merge_all`, `parse_duration`, `compound_ext`, `round_to_multiple`, `pad_center`, `escape_shell`, `mask_middle`, `unwrap`, `windows`, `difference`/`intersection`/`union` |

Every function in this repo is cross-checked against `%b` at build time
— zero name collisions with builtins. The two exceptions, `Utils::Path::join`
and `Utils::Path::normalize`, are intentionally distinct: stryke's `join`
is the array builtin and stryke's `normalize` is a vector op.

## [0x01] Install

From a release:

```sh
s pkg install -g github.com/MenkeTechnologies/stryke-utils
```

From a local checkout:

```sh
cd ~/projects/stryke-utils
s pkg install -g .              # installs into ~/.stryke/store/stryke-utils@<version>/
```

Or:

```sh
make install
```

No cargo step. No cdylib. The store directory ends up containing
`stryke.toml` + `lib/*.stk` only.

## [0x02] Quick Start

```perl
use Utils                                       # pulls all six sublibraries

# Strings — composites that aren't in core
Utils::String::ltrim("   hello")                # "hello"
Utils::String::pad_center("hi", 8, ".")         # "...hi..."
Utils::String::squeeze("aaabbc")                # "abc"
Utils::String::compact_whitespace("a   b\t c")  # "a b c"
Utils::String::rpartition("a/b/c", "/")         # ("a/b", "/", "c")
Utils::String::mask_middle("4111222233334444", 4, 4)  # "4111********4444"
Utils::String::escape_shell("it's \$foo")       # "'it'\\''s \$foo'"
Utils::String::unwrap('"quoted"', '"')          # "quoted"

# Lists — set ops + sliding windows
Utils::List::difference([1,2,3,4], [2,4])       # [1,3]
Utils::List::intersection([1,2,3], [2,3,5])     # [2,3]
Utils::List::union([1,2], [2,3])                # [1,2,3]
Utils::List::windows([1,2,3,4], 2)              # [[1,2],[2,3],[3,4]]
Utils::List::transpose([[1,2,3],[4,5,6]])       # [[1,4],[2,5],[3,6]]

# Hashes — variadic merge + dot-path access
my $cfg = Utils::Hash::deep_merge_all(
    $defaults, $from_env, $runtime)
Utils::Hash::deep_get($cfg, "db.pool.max")      # nested read by dot path
Utils::Hash::deep_set($cfg, "db.pool.min", 5)   # autovivifying write
Utils::Hash::deep_has($cfg, "db.pool.min")      # missing-vs-undef differentiator

# Numbers — long tail
Utils::Num::ordinal(21)                         # "21st"
Utils::Num::round_to_multiple(13, 5)            # 15

# Time — parsing + relative phrasing + ISO formatting
Utils::Time::parse_duration("1h30m")            # 5400
Utils::Time::ago(time() - 90)                   # "1 minute ago"
Utils::Time::format_iso8601()                   # "2026-06-10T14:23:05Z"

# Paths — string-only path arithmetic
Utils::Path::compound_ext("archive.tar.gz")     # "tar.gz"
Utils::Path::set_ext("a/b.csv", "parquet")      # "a/b.parquet"
Utils::Path::normalize("/a/b/../c/./d")         # "/a/c/d"
Utils::Path::relative("/a/x", "/a/b/c")         # "../../x"
Utils::Path::join("/a", "b/", "/c")             # "/a/b/c"
```

For everything else — `slugify`, `chunk`, `uniq`, `deep_merge`,
`format_bytes`, `levenshtein`, `basename`, … — just call the stryke
builtin directly. No wrapper indirection.

Pull only what you need:

```perl
use Utils::Path
use Utils::Time

Utils::Path::compound_ext("a.tar.gz")
Utils::Time::parse_duration("90m")
```

## [0x03] Sublibraries

| Module | `use` | fns | Surface |
|---|---|---|---|
| String | `use Utils::String` | 26 | `ltrim` &middot; `rtrim` &middot; `pad_center` &middot; `visible_width` &middot; `count_occurrences` &middot; `reverse_chars` &middot; `squeeze` &middot; `compact_whitespace` &middot; `rpartition` &middot; `mask_middle` &middot; `escape_shell` &middot; `expand_tabs` &middot; `unwrap` &middot; `ellipsize` &middot; `truncate_words` &middot; `nth_index` &middot; `splitn` &middot; `capitalize_first` &middot; `uncapitalize` &middot; `titleize` &middot; `normalize_newlines` &middot; `collapse_blank_lines` &middot; `strip_quotes` &middot; `repeat_to` &middot; `remove_prefix` &middot; `remove_suffix` |
| List   | `use Utils::List`   | 14 | `difference` &middot; `intersection` &middot; `union` &middot; `symmetric_difference` &middot; `is_disjoint` &middot; `windows` &middot; `chunk` &middot; `cartesian` &middot; `rle_encode` &middot; `rle_decode` &middot; `top_n` &middot; `bottom_n` &middot; `count_where` &middot; `transpose` |
| Hash   | `use Utils::Hash`   | 20 | `deep_merge_all` &middot; `deep_get` &middot; `deep_set` &middot; `deep_has` &middot; `map_keys` &middot; `map_values` &middot; `all_hashes` &middot; `rename_keys` &middot; `flatten_keys` &middot; `unflatten_keys` &middot; `deep_delete` &middot; `defaults` &middot; `deep_keys` &middot; `deep_values` &middot; `count_values` &middot; `map_entries` &middot; `merge_with` &middot; `pick_by` &middot; `hash_diff` (+ `_vstr` helper) |
| Num    | `use Utils::Num`    | 18 | `round_to_multiple` &middot; `ordinal` &middot; `percent_change` &middot; `weighted_avg` &middot; `percentile_of` &middot; `digit_sum` &middot; `digit_count` &middot; `digital_root` &middot; `pct_of` &middot; `mean_abs_dev` &middot; `is_close` &middot; `to_radians` &middot; `to_degrees` &middot; `round_sig` &middot; `clamp01` &middot; `remap` &middot; `wrap` &middot; `gcd` |
| Time   | `use Utils::Time`   | 16 | `parse_duration` &middot; `ago` &middot; `format_iso8601` &middot; `format_date` &middot; `format_time` &middot; `timed` &middot; `day_of_week` &middot; `format_human` &middot; `format_clock` &middot; `add_duration` &middot; `sub_duration` &middot; `parse_iso8601` &middot; `quarter` &middot; `is_same_day` &middot; `next_weekday` (+ `_days_from_civil` helper) |
| Path   | `use Utils::Path`   | 23 | `ext` &middot; `compound_ext` &middot; `without_ext` &middot; `set_ext` &middot; `splitext` &middot; `join` &middot; `normalize` &middot; `is_absolute` &middot; `is_bare` &middot; `relative` &middot; `with_name` &middot; `add_suffix` &middot; `strip_trailing_slash` &middot; `ensure_trailing_slash` &middot; `segments` &middot; `depth` &middot; `is_under` &middot; `is_hidden` &middot; `expand_user` &middot; `sibling` &middot; `ancestors` &middot; `with_stem` &middot; `common_ancestor` |

117 functions total. Every sublibrary stands alone — no FFI, no required
environment, no state between calls. Drop a single `lib/*.stk` into
another project and it works.

## [0x04] What's NOT in Here

By design — these are stryke builtins, so we don't re-wrap them. Every
omission below was present in `stryke-utils` at one point and got
deleted when the corresponding builtin landed in core:

| Category | Builtins (call directly) |
|---|---|
| String case/slug | `trim` &middot; `slugify` &middot; `snake_case` &middot; `kebab_case` &middot; `camel_case` &middot; `pascal_case` &middot; `title_case` &middot; `swap_case` &middot; `indent` &middot; `dedent` &middot; `rot13` |
| String predicates / distance | `contains` &middot; `starts_with` &middot; `ends_with` &middot; `is_blank` &middot; `is_palindrome` &middot; `levenshtein` &middot; `hamming` &middot; `dice_coefficient` &middot; `find_all_indices` &middot; `common_prefix` &middot; `common_suffix` |
| String padding / shaping | `pad_left` &middot; `pad_right` &middot; `truncate` &middot; `strip_ansi` &middot; `word_wrap` |
| List | `chunk` &middot; `compact` &middot; `uniq` &middot; `uniq_by` &middot; `flatten` &middot; `group_by` &middot; `count_by` &middot; `index_by` &middot; `partition` &middot; `pluck` &middot; `sum` &middot; `mean` &middot; `median` &middot; `min_by` &middot; `max_by` &middot; `sort_by` &middot; `zip` &middot; `take` &middot; `drop` &middot; `range` |
| Hash | `deep_merge` &middot; `pick` &middot; `omit` &middot; `invert` &middot; `filter` &middot; `from_pairs` &middot; `to_pairs` &middot; `is_empty` |
| Num | `clamp` &middot; `between` &middot; `lerp` &middot; `round_to` &middot; `format_number` &middot; `format_bytes` &middot; `format_percent` &middot; `gcd` &middot; `lcm` &middot; `sign` &middot; `is_even` &middot; `is_odd` |
| Time | `now_ms` &middot; `now_us` &middot; `format_duration` &middot; `elapsed` |
| Path | `basename` &middot; `dirname` &middot; `common_prefix` |
| Core | `uc`/`lc`/`length`/`sprintf`/`substr`/`index`/`rindex`/`split` &middot; `push`/`pop`/`shift`/`unshift`/`splice`/`sort`/`reverse`/`map`/`grep`/`join`/`keys`/`values`/`exists`/`defined`/`scalar`/`wantarray` &middot; `abs`/`int`/`sqrt`/`time`/`localtime`/`gmtime`/`sleep` &middot; `mkdir`/`unlink`/`rmdir`/`opendir`/`readdir`/`-e`/`-d`/`-f`/`-s` &middot; `to_json`/`from_json` &middot; the `..` range and `x` repetition operators |

If a function here can be replaced with one builtin call, it's a bug —
file an issue.

## [0x05] CLI

`bin/utils.stk` is a thin dispatcher exposing the surviving lib fns
plus convenience routes to a few common builtins:

```sh
s bin/utils.stk pad-center "hi" 8 .            # ...hi...
s bin/utils.stk squeeze "aaabbc"               # abc
s bin/utils.stk mask 4111222233334444 4 4      # 4111********4444
s bin/utils.stk escape-shell "it's \$foo"      # 'it'\''s $foo'
s bin/utils.stk unwrap '"quoted"' '"'          # quoted
s bin/utils.stk ordinal 21                     # 21st
s bin/utils.stk round-multiple 13 5            # 15
s bin/utils.stk parse-duration 1h30m           # 5400
s bin/utils.stk ago $((now - 90))              # 1 minute ago
s bin/utils.stk iso                            # 2026-06-10T14:23:05Z
s bin/utils.stk compound-ext archive.tar.gz    # tar.gz
s bin/utils.stk normalize a/./b/../c           # a/c
s bin/utils.stk relative /a/x /a/b/c           # ../../x
s bin/utils.stk help
```

For builtins (`slugify`, `chunk`, `deep_merge`, `format_bytes`, …), call
stryke one-liner-style — no wrapper needed:

```sh
s -e 'print slugify($ARGV[0])' -- "Hello, World!"
```

## [0x06] Tests

```sh
s test t/                       # assertions across every public function
make check-counts               # verify every doc count matches the source
```

`t/test_utils.stk` covers every public function with at least one
round-trip / boundary assertion and exits TAP-style via `test_run`.

`scripts/check-counts.sh` derives the per-sublib fn counts, the total,
the assertion count, and the example count straight from `lib/`, `t/`,
and `examples/`, then fails if any number quoted in `README.md` or
`docs/*.html` disagrees — so the hand-written doc numbers can't silently
rot. It runs in CI on every push.

## [0x07] Layout

```
stryke-utils/
  stryke.toml                  # pure-stryke package manifest (no [ffi])
  Makefile                     # test / check-counts / install / clean
  LICENSE                      # MIT
  scripts/
    check-counts.sh            # doc-count invariant (CI-enforced)
  lib/
    Utils.stk                  # `use Utils` — pulls all six sublibs
    String.stk                 # `use Utils::String`
    List.stk                   # `use Utils::List`
    Hash.stk                   # `use Utils::Hash`
    Num.stk                    # `use Utils::Num`
    Time.stk                   # `use Utils::Time`
    Path.stk                   # `use Utils::Path`
  bin/
    utils.stk                  # CLI front-end
  t/
    test_utils.stk             # all-surface assertions
  examples/
    discover.stk               # one call per sublib
    word_frequency.stk         # builtin-powered text pipeline
    config_merge.stk           # layered config via deep_merge_all + deep_get
    deploy_digest.stk          # cross-module pipeline (Time + String + Num + List + Path)
```

## [0xFF] License

MIT.
