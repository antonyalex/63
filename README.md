# CS F301 Principles of Programming Languages — Assignment 2

**Group 63** — Logic and Functional Programming
Two Prolog problems and two Scheme problems.

Members: **Alex Antony** and **Johns Panicker Mathews**.

For the per-member commit contribution, run `git shortlog -sn HEAD`.

## Layout

```
63/
  code/      63_q1.pl  63_q2.pl  63_q3.rkt  63_q4.rkt   the four solutions
  tests/     test_q1.pl test_q2.pl test_q3.rkt test_q4.rkt
             check_constraints.rkt   mechanical whitelist audit
             run_tests.sh            runs everything
  skills/    prolog-dev/SKILL.md   scheme-dev/SKILL.md
  prompts/   P1.md  P2.md  S1.md  S2.md   the prompts used, word for word
  P1_REPORT.md
```

## The problems

| File | Problem | Entry points |
|---|---|---|
| `code/63_q1.pl` | P1 Department Assignment Puzzle | `main/0`, `clue/2`, `count_solutions/2` |
| `code/63_q2.pl` | P2 Form a Valid Arithmetic Equation | `generate_equation/2`, `all_equations/2`, `count_equations/2` |
| `code/63_q3.rkt` | S1 Binary Tree Traversals | `print-inorder`, `print-all-traversals`, `print-height-and-leaves` |
| `code/63_q4.rkt` | S2 Conditionally Insert into a Nested List | `print-insert-result`, `insert-if-short`, `make-inserter`, `my-length`, `my-map` |

Every solution file contains **definitions only**. The Prolog files have no
`initialization` directive and never call `halt/0`; the Racket files print
nothing when loaded, because the grader appends its own calls to the end.

## Running the solutions

```sh
# P1
swipl -q -f code/63_q1.pl -g main -t halt
swipl -q -f code/63_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), format('~w~n',[N])" -t halt

# P2
swipl -q -f code/63_q2.pl -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt

# S1 and S2 — the grader appends its calls to the end of the file
racket code/63_q3.rkt
racket code/63_q4.rkt
```

## Running the tests

```sh
./tests/run_tests.sh
```

That runs three layers: the constraint checks (forbidden Prolog built-ins, the
Scheme built-in whitelist, and that the solution files stay silent when merely
loaded), then the four test suites, then every worked example from the
assignment end to end.

Individually:

```sh
swipl -q -g run_tests -t halt tests/test_q1.pl
swipl -q -g run_tests -t halt tests/test_q2.pl
racket tests/test_q3.rkt
racket tests/test_q4.rkt
racket tests/check_constraints.rkt
```

The two Scheme test files run the solution the way the grader does: they copy
the source to a temporary file, append the calls under test, run `racket` on
the copy and compare stdout byte for byte. `check_constraints.rkt` reads the
Scheme sources as s-expressions and reports any identifier that is neither on
the assignment's whitelist nor defined in the file itself.

## Environment

Written for SWI-Prolog 9.x and Racket 8.x, as the assignment specifies.
Developed and verified on SWI-Prolog 11.0.0 and Racket 9.3; only features
present in the specified versions are used.

## Answers at a glance

- **P1.b** — `count_solutions([1,2,3,4,5,6,7,8], N)` gives **N = 3**: the
  puzzle as given is under-determined. See `P1_REPORT.md`.
- **P1.c** — clue 9 ("the friend who works in the design department prefers
  embedded projects") brings it to **N = 1**.
- **P2** — `all_equations([4,2,5,3], Es)` gives the seven equations listed in
  the assignment, in the same order.
