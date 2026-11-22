# P1_REPORT — Department Assignment Puzzle, Reloaded

Group 63 · CS F301 Principles of Programming Languages, Assignment 2
Solution file: `code/63_q1.pl` · Tests: `tests/test_q1.pl`

## The value asked for in P1.b

```
?- count_solutions([1,2,3,4,5,6,7,8], N).
N = 3.
```

**N = 3.**

For reference, the same predicate over no clues at all gives the size of the raw
search space, which is the three independent permutations of the four
department, language and project values:

```
?- count_solutions([], N).
N = 13824.          % 24 * 24 * 24
```

So clues 1 to 8 together cut 13824 candidates down to 3 — they do almost all of
the work, and then stop three steps short.

## What N = 3 tells us about the puzzle

**The puzzle as stated is under-determined: it has no unique answer.** A
well-posed logic puzzle of this kind is supposed to have exactly one consistent
assignment, and the phrase "the solution" in the problem statement quietly
assumes that. N = 3 falsifies the assumption. Clues 1 to 8 are *consistent*
(N > 0, so they do not contradict each other) but not *categorical* (N > 1, so
they do not determine a single world).

The three surviving assignments are:

| # | Alex | Ben | Carla | Dana |
|---|------|-----|-------|------|
| 1 | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| 2 | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |
| 3 | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |

Three further things are worth reading off that table.

**1. Ben is already pinned down.** `Ben = [development, javascript, web]` in all
three rows. Clues 4, 5, 7 and 8 between them fix Ben completely, so the
remaining ambiguity is entirely about Alex, Carla and Dana. Counting tells us
*how much* is undetermined; inspecting the surviving models tells us *where*.

**2. The ambiguity is not one single "loose end".** Rows 1 and 2 disagree about
which of Alex and Carla is in design versus testing. Rows 1 and 3 disagree about
who holds the AI project and who holds embedded, and about whether Carla or Dana
is in research. So no single extra fact of the form "attribute X belongs to
friend Y" collapses all three at once by accident — the repair has to be chosen
deliberately.

**3. Two of the three are the same puzzle wearing different name tags.** Strip
the names off and keep only the (department, language, project) triples:

```
row 1 : {(design,java,embedded), (development,javascript,web), (testing,python,AI),  (research,c++,data)}
row 2 : {(design,java,AI),       (development,javascript,web), (testing,python,embedded), (research,c++,data)}
row 3 : {(design,java,AI),       (development,javascript,web), (testing,python,embedded), (research,c++,data)}
```

Rows 2 and 3 are **identical as sets of attribute triples** — they differ only
in which friend holds which triple (row 2 gives Alex the testing triple and
Carla the design triple; row 3 swaps them with Dana). Only two distinct
attribute patterns survive, not three. This is a hard constraint on the repair:
P1.c forbids the new clue from naming any friend, and a clue that speaks only of
attribute values literally cannot see the difference between rows 2 and 3,
because at the level of attribute values those two rows *are* the same world.

Therefore **any legal repair clue must be one that keeps row 1** and rejects the
shared row 2 / row 3 pattern. Trying to single out row 2 or row 3 is impossible
without naming a friend, no matter how the clue is phrased. That is a genuinely
useful piece of information that the bare number N = 3 does not give you, and it
is the reason the repair below was chosen the way it was.

## P1.c — the repair

```prolog
% CLUE 9: The friend who works in the design department prefers embedded projects.
clue(9, Solution) :-
    person(Solution, _Name, design, _Lang, embedded).
```

It satisfies the stated constraints:

- it **names no friend**, referring to them only through attribute values,
  exactly the way clue 5 ("the friend whose favorite language is Java...") does;
- it is **true in row 1** — there design belongs to Alex, whose project is
  embedded;
- it is **false in rows 2 and 3** — in row 2 the design friend (Carla) prefers
  AI, and in row 3 the design friend (Alex) prefers AI;
- it is **not a tautology**: `count_solutions([9], N)` gives `N = 3456`, so on
  its own it still rejects three quarters of the search space.

With it, the puzzle becomes well-posed:

```
?- count_solutions([1,2,3,4,5,6,7,8,9], N).
N = 1.
```

and the surviving assignment is

```
Alex = [design, java, embedded]
Ben = [development, javascript, web]
Carla = [testing, python, AI]
Dana = [research, c++, data]
```

## A note on what `main/0` prints

P1.a specifies that `main/0` prints one solution **satisfying clues 1 to 8**, and
that is exactly what it does: it searches with clues 1 to 8 only, and `once/1`
takes the first assignment the generator reaches. Because that clue set has
three models, "the" answer does not exist at that point — `main/0` prints row 3,
which is a correct solution of clues 1 to 8. Clue 9 is deliberately kept out of
`main/0` so that P1.a answers the question actually asked and the under-
determinacy reported here stays visible rather than being quietly papered over.

## How these numbers were produced

```
swipl -q -f code/63_q1.pl -g main -t halt
swipl -q -f code/63_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), format('~w~n',[N])" -t halt
swipl -q -f code/63_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8,9],N), format('~w~n',[N])" -t halt
swipl -q -g run_tests -t halt tests/test_q1.pl
```

No answer is hard-coded anywhere in `code/63_q1.pl`: `solution/1` is a pure
generator over the three attribute permutations, and every number above is the
result of searching it under the clue predicates.
