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

### `[PURE-STRYKE UTILITY BELT // NO CDYLIB, NO HELPER BINARY]`

> *"Composites only — every function does work the language doesn't already do."*

`stryke-utils` is a pure-stryke utility library: six sublibraries (`String`, `List`, `Hash`, `Num`, `Time`, `Path`) of higher-level composites that aren't part of stryke core. No `[ffi]` table, no cdylib, no helper binary — just `.stk` modules loaded on `use Utils`. Created by MenkeTechnologies.

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

stryke core stays small on purpose — the daily-driver install is the
shell + bytecode VM + the Perl-superset standard library. Higher-level
composites (`slugify`, `deep_merge`, `format_bytes`, `parse_duration`,
`levenshtein`, …) live outside core so they can iterate independently
and stay opt-in.

| Tier | Properties | This package |
|---|---|---|
| Core (~40 MB stryke) | builtins everyone needs everywhere | `length`, `keys`, `uc`, `sort`, `time`, `sprintf`, file tests, regex, async |
| `stryke-utils` (opt-in) | composites: 1 call, multiple builtins worth of work | `slugify`, `chunk`, `deep_merge`, `format_bytes`, `format_duration`, `levenshtein` |

Every function in this repo is a *composite* — it does something you'd
otherwise write 3-10 lines of stryke for. We do not ship aliases over
stryke builtins.

## [0x01] Install

From a release:

```sh
s pkg install -g github.com/MenkeTechnologies/stryke-utils
```

From a local checkout:

```sh
cd ~/projects/stryke-utils
s pkg install -g .              # installs into ~/.stryke/store/utils@<version>/
```

Or:

```sh
make install
```

No cargo step. No cdylib. The store directory ends up containing
`stryke.toml` + `lib/*.stk` only.

## [0x02] Quick Start

```perl
use Utils                                      # pulls all six sublibraries

# Strings
Utils::String::slugify("Hello, World! 2026")    # "hello-world-2026"
Utils::String::snake_case("HelloWorld")         # "hello_world"
Utils::String::truncate("a long string", 8)     # "a long …"
Utils::String::levenshtein("kitten", "sitting") # 3

# Lists — set ops + sliding windows (chunk/uniq/group_by are builtins)
Utils::List::difference([1,2,3,4], [2,4])       # [1,3]
Utils::List::intersection([1,2,3], [2,3,5])     # [2,3]
Utils::List::windows([1,2,3,4], 2)              # [[1,2],[2,3],[3,4]]

# Hashes — n-ary merge + dot-path access (deep_merge/pick/omit are builtins)
my $cfg = Utils::Hash::deep_merge_all(
    $defaults, $from_env, $runtime)
Utils::Hash::deep_get($cfg, "db.pool.max")      # nested read by dot path
Utils::Hash::deep_has($cfg, "db.pool.min")      # missing-vs-undef differentiator

# Numbers — ordinal + round-to-multiple (clamp/format_bytes/format_number are builtins)
Utils::Num::ordinal(21)                         # "21st"
Utils::Num::round_to_multiple(13, 5)            # 15

# Time — duration parsing + relative phrasing (now_ms/format_duration are builtins)
Utils::Time::parse_duration("1h30m")            # 5400
Utils::Time::ago(time() - 90)                   # "1 minute ago"
Utils::Time::format_iso8601()                   # "2026-06-10T14:23:05Z"

# Paths — path-string arithmetic (basename/common_prefix are builtins)
Utils::Path::compound_ext("archive.tar.gz")     # "tar.gz"
Utils::Path::set_ext("a/b.csv", "parquet")      # "a/b.parquet"
Utils::Path::normalize("/a/b/../c/./d")         # "/a/c/d"
Utils::Path::relative("/a/x", "/a/b/c")         # "../../x"
```

Pull only what you need:

```perl
use Utils::String
use Utils::Path

Utils::String::slugify("…")
Utils::Path::normalize("…")
```

## [0x03] Sublibraries

| Module | `use` | Highlights |
|---|---|---|
| String | `use Utils::String` | `trim`/`ltrim`/`rtrim`, `slugify`, `{snake,kebab,camel,pascal,title}_case`, `swap_case`, `pad_{left,right,center}`, `truncate`, `strip_ansi`, `visible_width`, `starts_with`, `ends_with`, `contains`, `count_occurrences`, `find_all_indices`, `levenshtein`, `hamming`, `dice_coefficient`, `common_prefix`, `common_suffix`, `word_wrap`, `indent`, `dedent`, `squeeze`, `compact_whitespace`, `partition`/`rpartition`, `between`, `chunks`, `mask_middle`, `escape_shell`, `expand_tabs`, `rot13`, `unwrap`, `is_blank`, `is_palindrome`, `reverse_chars` |
| List   | `use Utils::List`   | `chunk`, `uniq`, `uniq_by`, `group_by`, `count_by`, `index_by`, `partition`, `compact`, `pluck`, `flatten`, `sum`, `mean`, `median`, `min_by`, `max_by`, `sort_by`, `zip`, `difference`, `intersection`, `union`, `range`, `windows`, `take`, `drop` |
| Hash   | `use Utils::Hash`   | `deep_merge`, `deep_merge_all`, `pick`, `omit`, `invert`, `deep_get`, `deep_set`, `deep_has`, `to_pairs`, `from_pairs`, `map_keys`, `map_values`, `filter`, `is_empty`, `all_hashes` |
| Num    | `use Utils::Num`    | `clamp`, `between`, `lerp`, `round_to`, `round_to_multiple`, `format_number`, `format_bytes`, `format_percent`, `ordinal`, `sign`, `is_even`, `is_odd`, `gcd`, `lcm` |
| Time   | `use Utils::Time`   | `format_duration`, `parse_duration`, `ago`, `now_ms`, `now_us`, `format_iso8601`, `format_date`, `format_time`, `timed`, `elapsed` |
| Path   | `use Utils::Path`   | `ext`, `compound_ext`, `without_ext`, `set_ext`, `splitext`, `basename`, `dirname`, `join`, `normalize`, `is_absolute`, `is_bare`, `relative`, `common_prefix` |

Every sublibrary stands alone — no FFI, no required environment, no
state between calls. You can copy a single `lib/*.stk` file out of this
repo and drop it into another project as long as its dependencies (only
ever sibling sublibs, never external) come with it.

## [0x04] What's NOT in Here

By design — these are stryke builtins, so we don't re-wrap them:

* `uc` / `lc` / `ucfirst` / `lcfirst` / `length` / `sprintf` / `substr` / `index` / `split`
* `push` / `pop` / `shift` / `unshift` / `splice` / `sort` / `reverse` / `map` / `grep` / `join` / `keys` / `values` / `exists` / `defined` / `scalar` / `wantarray`
* `abs` / `int` / `sqrt` / `time` / `localtime` / `gmtime` / `sleep`
* `mkdir` / `unlink` / `rmdir` / `opendir` / `readdir` / `-e` / `-d` / `-f` / `-s`
* `to_json` / `from_json`
* the `..` range operator, the `x` repetition operator

If a function here can be replaced with one builtin call, it's a bug —
file an issue.

## [0x05] CLI

`bin/utils.stk` is a thin dispatcher over the public functions:

```sh
s bin/utils.stk slugify "Hello, World!"        # hello-world
s bin/utils.stk snake "HelloWorld"             # hello_world
s bin/utils.stk truncate "long string here" 8  # long st…
s bin/utils.stk bytes 1572864                  # 1.5 MiB
s bin/utils.stk number 1234567.89              # 1,234,567.89
s bin/utils.stk duration 5400                  # 1h 30m
s bin/utils.stk parse-duration 1h30m           # 5400
s bin/utils.stk iso                            # 2026-06-10T14:23:05Z
s bin/utils.stk compound-ext archive.tar.gz    # tar.gz
s bin/utils.stk normalize a/./b/../c           # a/c
s bin/utils.stk help
```

## [0x06] Tests

```sh
s test t/                       # ~150 assertions across all six sublibs
```

`t/test_utils.stk` covers every public function with at least one
round-trip / boundary assertion and exits TAP-style via `test_run`.

## [0x07] Layout

```
stryke-utils/
  stryke.toml                  # pure-stryke package manifest (no [ffi])
  Makefile                     # test / install / clean
  LICENSE                      # MIT
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
    word_frequency.stk         # String + List + Hash + Num pipeline
    config_merge.stk           # layered config via deep_merge_all + deep_get
```

## [0xFF] License

MIT.
