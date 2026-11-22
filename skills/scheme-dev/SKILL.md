---
name: scheme-dev
description: Conventions, the allowed-built-in whitelist, run/test commands, self-review checklist and known AI failure modes for writing restricted #lang racket/base Scheme for CS F301 Assignment 2 (problems S1 and S2).
---

# scheme-dev

Use this skill for every unit of Scheme work in this repository. One invocation =
one unit of work (one function, one test file, or one review). Never ask for, and
never produce, a whole problem in a single step.

## 1. Language and environment

- **Language:** Racket 8.x, and every solution file begins with exactly
  `#lang racket/base`.
- **Run exactly as the grader does:** `racket code/id_q3.rkt`,
  `racket code/id_q4.rkt`. The grader **appends its own calls to the end of the
  file**, so the file as submitted must define things and do nothing else.
- **No top-level calls, no top-level printing.** Loading the file must produce no
  output whatsoever.

## 2. The whitelist (this is the hard part — check every single identifier)

Only these may appear:

`define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (with
`else`), `and`, `or`, `not`, `begin`, `quote` written `'`, `cons`, `car`, `cdr`,
`list`, every composition of `car`/`cdr` up to four letters (`cadr`, `cddr`,
`caddr`, `cdddr`, `cadddr`, ...), `null?`, `pair?`, `eq?`, `assq`, `assoc`,
`+ - * / < > <= >= =`, `max`, `display`, `newline`.
**S2 additionally allows `read`.**

Explicitly forbidden, however convenient: `set!` and every mutator, vectors, hash
tables, strings and all string procedures, `do` and `for` loops, and
`length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`,
`list-tail`. Also forbidden because they are simply not on the list: `else` as a
bare value, `when`, `unless`, `case`, `apply`, `equal?`, `number?`, `symbol?`,
`list?`, `add1`, `sub1`, `zero?`, `length*`, `foldl`, `foldr`, `printf`,
`displayln`, `write`, `error`, `assert`, `quasiquote`/`unquote`.

If a needed helper is not on the list, **write it**, prefixed `my-`
(`my-length`, `my-reverse`, `my-map`). Writing the helper is the exercise.

Recursion replaces every loop. Iteration is expressed as a named `let` or a
tail-recursive helper, never `do`/`for`.

## 3. Coding conventions

- **Naming.** `kebab-case`. Predicates end in `?` (`len-ok?`, `leaf?`).
  Own replacements for forbidden built-ins are prefixed `my-`. Accumulator
  parameters are named `acc` or `<thing>-acc`.
- **State through arguments only.** No mutation is available and none is wanted:
  every helper that accumulates takes the accumulator as a parameter and returns
  the updated value.
- **Shape of a definition.** Public functions named by the PDF
  (`print-inorder`, `insert-if-short`, ...) are thin wrappers; the work lives in
  a named helper. This keeps the required signature exact.
- **Comments.** Every function carries a header comment of three parts:
  1. a signature/contract line, e.g. `;; my-map : (A -> B) (listof A) -> (listof B)`
  2. a one-sentence **recursive reading** stated as what the result *is*, not as
     steps. Good: "`(inorder-acc t acc)` is the inorder value list of `t`
     prepended to `acc`." Bad: "walks the left subtree, then ...".
  3. the base case, the recursive case, and the measure that shrinks (subtree
     size, list length), so termination is visible.
  Inline comments explain *why*, never restate the code.
- **Tail recursion where it is natural.** Linear walks over a list
  (`my-length`, `my-reverse`, the loop inside `my-map`) must be tail-recursive
  with an accumulator. Tree walks use accumulator-passing so that no intermediate
  list is ever appended; do not contort a tree recursion into a hand-rolled stack
  just to claim tail calls.
- **Never build then append.** `append` is forbidden anyway; the accumulator
  style (`(f left (cons v (f right acc)))`) produces the list in one pass.
- **Printing.** Use `display` for the value and a single `newline` after it.
  Every printing function ends its output with a newline, and prints nothing else
  — no prompt, no label, no trailing space.

## 4. Treating `()` correctly

`'()` is **not** a pair, so `pair?` is false for it, and a dispatch written only
on `pair?` will silently treat the empty list as an atom. When a value may be an
atom or a (possibly empty) list, the test is `(or (pair? item) (null? item))`.
The assignment leans on this: an empty list still has a length (zero) and is
still a list that can receive an insertion.

## 5. How to run and test

- Test files live in `tests/` and are `#lang racket/base` programs with a tiny
  hand-written `check-equal` helper (rackunit is not guaranteed to be installed,
  and keeping tests in `racket/base` keeps them honest).
- Because the solution files export nothing and the grader appends calls to them,
  the tests reproduce that exactly: they copy the solution source to a temporary
  file, append the calls under test, run `racket` on it and compare the captured
  stdout string.
- Run a test file: `racket tests/test_q3.rkt`
- Every test file must contain, at minimum:
  - every example printed in the assignment PDF, verbatim, including the exact
    spacing of the displayed list and its trailing newline;
  - the empty tree / empty list case;
  - a stress case matching the stated hidden tests (nesting depth 100, lists of
    10 000 elements) to prove no stack or quadratic blow-up.

## 6. Self-review checklist (apply before answering, every time)

Answer each item out loud; if any answer is "no" or "unsure", fix the code first.

1. Does the file start with `#lang racket/base` and contain definitions only?
2. Does loading the file print nothing and call nothing?
3. **Identifier audit:** list every identifier used in the file and tick each one
   against the Section 2 whitelist. Any identifier not on the list is a defect
   even if the program runs.
4. Is `set!` absent? Are strings, vectors and hash tables absent?
5. Is every forbidden list primitive (`length`, `append`, `reverse`, `map`, ...)
   replaced by a `my-` helper that I actually defined in this file?
6. Is every `car`/`cdr` composition at most four letters?
7. Does every list-walking helper carry an accumulator and tail-call itself?
8. Is `'()` handled wherever an atom-or-list dispatch happens?
9. Does each printing function end with exactly one `newline`, and print nothing
   else?
10. Does the displayed form match the PDF byte-for-byte — parentheses, single
    spaces between elements, no dots, no quotes around symbols?
11. For S2: are lengths measured on the **original** list, before any insertion?
12. For S2: is there exactly **one** definition of `insert-if-short` in the file,
    and is it the one written in terms of `make-inserter`?
13. Will depth 100 and 10 000 elements work without exhausting the stack?
14. Does `read` get called exactly the specified number of times, in the
    specified order, and only in S2?

## 7. Known failure modes of AI tools on this kind of Scheme (watch for these)

- **Using a forbidden built-in because it is idiomatic.** `map`, `length`,
  `append`, `reverse`, `foldr`, `string-append` and `displayln` all appear
  unbidden. This is the single most common failure; run the identifier audit.
- **`displayln` instead of `display` + `newline`.** `displayln` is not on the
  whitelist.
- **Leaving a top-level test call** (`(print-inorder t1)`) at the bottom of the
  solution file. The grader appends its own calls; any of ours corrupts stdout.
- **Defining a function twice** — e.g. a plain `insert-if-short` early in the
  file and the `make-inserter` version later. In Racket the second `define` of
  the same name at module level is an error, and S2.c requires exactly one.
- **Treating `'()` as an atom** because the dispatch used only `pair?`.
- **Measuring length after insertion**, which makes nested results drift by one.
- **Mutating with `set!`** to build a result list.
- **Non-tail recursion over a 10 000-element list** where an accumulator was
  available.
- **Inventing `#lang racket` features** (`for/list`, `match`, keyword arguments)
  that `racket/base` plus the whitelist does not permit.
- **Wrong `let` form.** `let` evaluates its bindings in parallel; reading three
  values from stdin in order requires `let*` (or nested `let`), otherwise the
  read order is not guaranteed to be the specified one.
- **Confusing `eq?` with `equal?`.** `equal?` is not on the whitelist; `eq?` is
  reliable for symbols and small integers only, so prefer structural recursion
  over equality tests.
- **Assuming `display` adds a newline.** It does not.
