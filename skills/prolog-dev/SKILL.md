---
name: prolog-dev
description: Conventions, run/test commands, self-review checklist and known AI failure modes for writing pure SWI-Prolog 9.x predicates for CS F301 Assignment 2 (problems P1 and P2).
---

# prolog-dev

Use this skill for every unit of Prolog work in this repository. One invocation =
one unit of work (one predicate, one test file, or one review). Never ask for, and
never produce, a whole problem in a single step.

## 1. Language and environment

- **Language:** SWI-Prolog 9.x. No other Prolog dialect.
- **Run exactly as the grader does:**
  - `swipl -q -f code/id_q1.pl -g main -t halt`
  - `swipl -q -f code/id_q1.pl -g "<goal>" -t halt` for any other predicate.
- **Files contain definitions only.** No `:- initialization(...)` directive, ever.
  No top-level goals that run on load. Never call `halt/0` from inside the code:
  the grader supplies `-t halt`.
- **Allowed libraries:** `lists`, `apply`, `yall`, `aggregate`. Nothing else.
  Built-ins (`format/2`, `forall/2`, `findall/3`, `sort/2`, `append/3`,
  `permutation/2`, `memberchk/2`, arithmetic) are fine.
- **Forbidden:** `assert/1`, `asserta/1`, `assertz/1`, `retract/1`,
  `b_setval/2`, `nb_setval/2`, `b_getval/2`, `nb_getval/2`, and any other global
  mutable state. The programs must be pure: all state travels through arguments.

## 2. Coding conventions

- **Naming.** Predicates and atoms are `lower_snake_case`. Variables are
  `UpperCamelCase` and say what they hold (`Solution`, `Active`, `LeftTree`,
  not `X`, `L`, `T`). A variable used once is written `_` or `_Name`.
- **Argument order.** Inputs first, outputs last: `count_solutions(+Active, -N)`.
- **One clause, one idea.** Prefer several short clauses with distinct heads over
  one clause with a long body and nested `->`.
- **Comments.** Every exported predicate carries a header comment of three parts,
  in this order:
  1. a mode/type line, e.g. `%! all_equations(+List:list(integer), -Equations:list(string)) is det.`
  2. a one-sentence **declarative reading**: what relation holds between the
     arguments, stated as a fact, not as a sequence of steps.
     Good: "`Equations` is the duplicate-free, `sort/2`-ordered list of every
     valid equation over `List`." Bad: "first we split the list, then we ...".
  3. for recursive predicates, a one-line note on what shrinks each step, so the
     reader can see termination.
  Inline comments explain *why*, never restate the code.
- **Determinism.** State the determinism of every predicate in its mode line
  (`is det`, `is semidet`, `is nondet`) and make the code match. Use `once/1`
  where a predicate is specified to give one answer; do not sprinkle cuts.
- **Failure, not error.** A predicate specified to "fail if there is no answer"
  must fail cleanly. Guard arithmetic (`Divisor =\= 0` before dividing) so no
  exception can escape.
- **No print/parse round trips.** Never build a string and read it back as a term
  in order to evaluate it. Evaluate the term structure directly.
- **Output.** Only the predicate that is specified to print may print, and it
  prints exactly the specified characters: no banner, no extra blank line, no
  debugging residue.

## 3. Declarative / recursive reading (required before writing code)

Before writing a predicate, write its declarative reading in one sentence, and for
a recursive predicate name the three parts explicitly:

- **Base case(s):** which argument shape terminates, and what the answer is there.
- **Recursive case:** what smaller sub-problem is solved, and how its answer is
  combined.
- **Measure:** the quantity that strictly decreases (list length, number of
  elements still to be split), proving termination.

For a generate-and-test predicate, state separately what the **generator**
enumerates and what the **test** rejects, and confirm the generator is finite.

## 4. How to run and test

- Test files live in `tests/` and use `library(plunit)`. They load the solution
  with `ensure_loaded/1` using a path relative to the test file.
- Run a test file:
  `swipl -q -g run_tests -t halt tests/test_q1.pl`
- Every test file must contain, at minimum:
  - every example printed in the assignment PDF, verbatim;
  - the degenerate inputs (`[]`, single-element list, empty tree);
  - at least one case that must **fail** and one that must be **deterministic**.
- To check printed output, capture it with
  `with_output_to(string(S), Goal)` and compare `S` to the expected string
  including its newlines.

## 5. Self-review checklist (apply before answering, every time)

Answer each item out loud; if any answer is "no" or "unsure", fix the code first.

1. Does the file contain **only** definitions, with no `initialization` directive
   and no top-level side effect?
2. Is `halt/0` absent from the file?
3. Are `assert`/`retract`/`b_setval`/`nb_setval` absent?
4. Are all libraries used within {`lists`, `apply`, `yall`, `aggregate`}?
5. Does every predicate have a mode line and a declarative reading?
6. Does each recursive predicate have a decreasing measure, and does the
   generator terminate on `[]` and on a one-element list?
7. Is every arithmetic operation guarded (no division by zero, no evaluation of
   an unbound variable)?
8. Does a predicate specified to fail actually **fail**, rather than raise or loop?
9. Is the printed output byte-for-byte what the PDF shows (spaces, commas,
   brackets, one trailing newline, nothing else)?
10. Have I re-read the PDF example list and confirmed my output set matches it
    exactly in both content **and** order?
11. Is anything hard-coded that the problem says must be derived? (For P1 the
    answer must come from the clues, never from a literal solution.)
12. Does the predicate still behave when its output argument is already bound?

## 6. Known failure modes of AI tools on this kind of Prolog (watch for these)

- **Inventing built-ins.** Hallucinated predicates such as `sum_list_of/2`,
  `string_join/3`, `list_to_set/2`-with-ordering guarantees, or library
  predicates from other Prologs. Check every non-obvious predicate against the
  SWI-Prolog manual before using it.
- **Reaching for `assert/1`.** LLMs cache results with `assertz`. This assignment
  forbids it; use accumulators and `findall/3` instead.
- **Adding `:- initialization(main).`** This is the usual Prolog-script idiom and
  is explicitly forbidden here.
- **Calling `halt/0`** at the end of `main`, which breaks the grader's `-t halt`.
- **Hard-coding the puzzle answer** after "reasoning it out", instead of deriving
  it from the clue predicates.
- **Confusing `\=` with `\==`.** For already-ground terms `\==` is the honest
  check; `\=` on unbound variables silently succeeds or fails in surprising ways.
- **Confusing atoms with strings.** `'AI'` and `"AI"` are different terms;
  `"4*2=5+3"` must be a *string*, and `sort/2` orders strings by code points.
- **Forgetting quoting.** `'c++'` and `'AI'` must be quoted atoms in source but
  print unquoted under `~w`.
- **Off-by-one in splits.** `append(L, R, List)` yields `L = []` and `R = []`;
  both must be rejected when a non-empty split is required.
- **Integer division sloppiness.** `X is A/B` can give a float or rational.
  Require `B =\= 0, A mod B =:= 0` and then use `//`.
- **Duplicate answers.** `findall/3` over a nondeterministic generator repeats
  solutions; `sort/2` (not `msort/2`) is what removes duplicates.
- **Silent nontermination** from an unbounded generator; always bound the search
  by the input list before testing.
- **Over-cutting.** A stray `!` makes a predicate miss answers that
  `all_equations/2` needs. Prefer `once/1` at the single place one answer is wanted.
