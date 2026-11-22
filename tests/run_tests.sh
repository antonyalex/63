#!/usr/bin/env bash
#
# tests/run_tests.sh -- run every check in this repository.
#
#   ./tests/run_tests.sh
#
# Three layers:
#   1. constraint checks, that the solution files obey the rules in the
#      assignment (forbidden Prolog built-ins, the Scheme whitelist, files
#      that stay silent when merely loaded);
#   2. the four test suites, one per problem;
#   3. the worked examples from the assignment, run end to end exactly the
#      way the grader runs them.

set -u

cd "$(dirname "$0")/.."

status=0
note() { printf '\n==== %s ====\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; status=1; }
pass() { printf 'ok    %s\n' "$1"; }

# --------------------------------------------------------------------------
note "Constraint checks: Prolog"

# Comments are stripped first so that prose mentioning a forbidden built-in
# does not trip the check.
for file in code/63_q1.pl code/63_q2.pl; do
  code_only=$(sed 's/%.*$//' "$file")
  clean=1
  # Whole-word matching, so halt/0 written without parentheses is caught too.
  for banned in assert asserta assertz retract retractall \
                b_setval nb_setval b_getval nb_getval \
                initialization halt; do
    if printf '%s' "$code_only" | grep -qE "(^|[^a-zA-Z0-9_])${banned}($|[^a-zA-Z0-9_])" ; then
      fail "$file uses the forbidden built-in ${banned}"
      clean=0
    fi
  done
  # Positive check: every library actually loaded must be on the allowed list.
  # (Written without grep -P, which BSD/macOS grep does not support.)
  libraries=$(printf '%s' "$code_only" \
    | sed -n 's/.*use_module(library(\([a-z_]*\))).*/\1/p')
  for library in $libraries; do
    case "$library" in
      lists|apply|yall|aggregate) ;;
      *) fail "$file loads library($library), which is outside {lists, apply, yall, aggregate}"
         clean=0 ;;
    esac
  done
  [ "$clean" -eq 1 ] && pass "$file passed the Prolog constraint check"
done

# --------------------------------------------------------------------------
note "Constraint checks: Scheme whitelist"
racket tests/check_constraints.rkt || status=1

# --------------------------------------------------------------------------
note "Constraint checks: solution files are silent when loaded"
for file in code/63_q3.rkt code/63_q4.rkt; do
  output=$(racket "$file")
  if [ -n "$output" ]; then
    fail "$file printed something when merely loaded"
  else
    pass "$file prints nothing when loaded"
  fi
done

# --------------------------------------------------------------------------
note "P1 -- Department Assignment Puzzle (tests/test_q1.pl)"
swipl -q -g run_tests -t halt tests/test_q1.pl || status=1

note "P2 -- Arithmetic Equation (tests/test_q2.pl)"
swipl -q -g run_tests -t halt tests/test_q2.pl || status=1

note "S1 -- Binary Tree Traversals (tests/test_q3.rkt)"
racket tests/test_q3.rkt || status=1

note "S2 -- Conditional Insert (tests/test_q4.rkt)"
racket tests/test_q4.rkt || status=1

# --------------------------------------------------------------------------
note "Worked examples from the assignment, run as the grader runs them"

echo "--- swipl -q -f code/63_q1.pl -g main -t halt"
swipl -q -f code/63_q1.pl -g main -t halt || status=1

echo "--- count_solutions for clues 1..8 and 1..9"
swipl -q -f code/63_q1.pl \
  -g "count_solutions([1,2,3,4,5,6,7,8],A), count_solutions([1,2,3,4,5,6,7,8,9],B), format('clues 1-8 -> ~w~nclues 1-9 -> ~w~n',[A,B])" \
  -t halt || status=1

echo "--- all_equations([4,2,5,3], Es)"
swipl -q -f code/63_q2.pl \
  -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt || status=1

echo "--- the S1 example trees"
tmp3=$(mktemp -t popl63q3).rkt
cat code/63_q3.rkt > "$tmp3"
cat >> "$tmp3" <<'RKT'
(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(print-inorder t1)
(print-all-traversals t1)
(print-height-and-leaves t1)
RKT
racket "$tmp3" || status=1
rm -f "$tmp3"

echo "--- the S2 examples"
tmp4=$(mktemp -t popl63q4).rkt
cat code/63_q4.rkt > "$tmp4"
echo '(print-insert-result)' >> "$tmp4"
for input in '42 ((1 2) (3 4 5) (6) ()) 3' \
             '0 (((1) 2) (3) ((4 5 6) ())) 3' \
             '7 () 3' \
             '7 () 0'; do
  printf '%s\n' "$input" | racket "$tmp4" || status=1
done
rm -f "$tmp4"

# --------------------------------------------------------------------------
note "Result"
if [ "$status" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "SOME CHECKS FAILED"
fi
exit "$status"
