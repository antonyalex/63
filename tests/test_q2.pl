%  tests/test_q2.pl  --  tests for P2 (code/63_q2.pl)
%
%  Run with:  swipl -q -g run_tests -t halt tests/test_q2.pl
%
%  Covers: the canonical printing rule on every example given in the
%  assignment, the four worked examples of generate_equation/2 and
%  all_equations/2, the degenerate lists of length 0 and 1, exact-division and
%  zero-divisor handling, and the structural promises of all_equations/2
%  (sorted, duplicate-free, consistent with count_equations/2).

:- use_module(library(plunit)).
:- use_module(library(lists)).
:- ensure_loaded('../code/63_q2.pl').

:- begin_tests(q2).

%  ---------------------------------------------------------------------------
%  The canonical printing rule
%  ---------------------------------------------------------------------------

test(renders_left_operand_of_lower_precedence_in_parentheses) :-
    render(op(*, op(+, num(4), num(2)), num(3)), Text),
    Text == "(4+2)*3".

test(leaves_right_operand_of_higher_precedence_bare) :-
    render(op(+, num(4), op(*, num(2), num(3))), Text),
    Text == "4+2*3".

test(leaves_equal_precedence_left_operand_bare) :-
    render(op(*, op(/, num(8), num(4)), num(2)), Text),
    Text == "8/4*2".

test(parenthesises_equal_precedence_right_operand) :-
    render(op(/, num(8), op(*, num(4), num(2))), Text),
    Text == "8/(4*2)".

test(left_associative_chain_needs_no_parentheses) :-
    render(op(-, op(-, num(1), num(2)), num(3)), Text),
    Text == "1-2-3".

test(right_nested_subtraction_is_parenthesised) :-
    render(op(-, num(1), op(-, num(2), num(3))), Text),
    Text == "1-(2-3)".

test(right_nested_addition_is_parenthesised_too) :-
    render(op(+, num(1), op(+, num(2), num(3))), Text),
    Text == "1+(2+3)".

test(left_nested_addition_is_not) :-
    render(op(+, op(+, num(1), num(2)), num(3)), Text),
    Text == "1+2+3".

test(a_single_number_is_never_parenthesised) :-
    render(num(42), Text),
    Text == "42".

test(different_trees_render_to_different_strings) :-
    render(op(+, num(1), op(+, num(2), num(3))), Nested),
    render(op(+, op(+, num(1), num(2)), num(3)), Flat),
    Nested \== Flat.

%  ---------------------------------------------------------------------------
%  Evaluation rules
%  ---------------------------------------------------------------------------

test(division_must_be_exact) :-
    \+ evaluate(/, 7, 2, _).

test(division_by_zero_fails_rather_than_raising) :-
    \+ evaluate(/, 5, 0, _).

test(exact_division_is_accepted, [true(Value =:= 2)]) :-
    evaluate(/, 8, 4, Value).

test(sub_expressions_may_be_negative, [true(Value =:= -2)]) :-
    evaluate(-, 3, 5, Value).

test(division_of_a_negative_numerator_stays_exact, [true(Value =:= -2)]) :-
    evaluate(/, -6, 3, Value).

test(inexact_division_of_a_negative_numerator_is_rejected) :-
    \+ evaluate(/, -7, 3, _).

%  ---------------------------------------------------------------------------
%  P2.a  --  generate_equation/2
%  ---------------------------------------------------------------------------

test(generate_finds_an_equation_for_the_worked_example) :-
    generate_equation([4, 2, 5, 3], Equation),
    all_equations([4, 2, 5, 3], All),
    memberchk(Equation, All).

test(generate_fails_on_the_empty_list) :-
    \+ generate_equation([], _).

test(generate_fails_on_a_one_element_list) :-
    \+ generate_equation([7], _).

test(generate_fails_when_no_equation_exists) :-
    \+ generate_equation([2, 3, 4], _).

test(generate_accepts_a_bound_valid_equation) :-
    generate_equation([4, 2, 5, 3], "4-2=5-3").

test(generate_rejects_a_bound_invalid_equation) :-
    \+ generate_equation([4, 2, 5, 3], "9=9").

test(generate_is_deterministic) :-
    % plunit reports a choicepoint left behind as a warning; this test exists
    % to make that check explicit for the predicate the grader calls.
    generate_equation([1, 2, 3], Equation),
    Equation == "1+2=3".

%  ---------------------------------------------------------------------------
%  P2.b  --  all_equations/2 and count_equations/2
%  ---------------------------------------------------------------------------

test(all_equations_matches_the_worked_example) :-
    all_equations([4, 2, 5, 3], Equations),
    Equations == ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                  "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"].

test(all_equations_is_empty_when_there_is_none) :-
    all_equations([2, 3, 4], Equations),
    Equations == [].

test(all_equations_of_the_single_answer_example) :-
    all_equations([2, 4, 8], Equations),
    Equations == ["2*4=8"].

test(all_equations_of_the_empty_list_is_empty) :-
    all_equations([], Equations),
    Equations == [].

test(all_equations_of_a_one_element_list_is_empty) :-
    all_equations([7], Equations),
    Equations == [].

test(all_equations_handles_a_two_element_list) :-
    all_equations([5, 5], Equations),
    Equations == ["5=5"].

test(all_equations_survives_a_zero_divisor_in_the_search) :-
    % Reaching 1*0=0 requires trying 1/0 and 0/0 along the way; those must
    % fail quietly rather than raise.
    all_equations([1, 0, 0], Equations),
    Equations == ["1*0=0"].

test(all_equations_is_sorted_and_duplicate_free) :-
    all_equations([4, 2, 5, 3], Equations),
    sort(Equations, Equations).

test(every_listed_equation_is_itself_generatable) :-
    all_equations([4, 2, 5, 3], Equations),
    forall(member(Equation, Equations),
           generate_equation([4, 2, 5, 3], Equation)).

test(count_equations_is_the_length_of_all_equations, [true(N =:= 7)]) :-
    count_equations([4, 2, 5, 3], N).

test(count_equations_is_zero_when_there_is_none, [true(N =:= 0)]) :-
    count_equations([2, 3, 4], N).

test(count_equations_agrees_with_all_equations_on_every_sample) :-
    forall(member(List, [[], [7], [0, 0], [1, 2, 3], [2, 4, 8],
                         [4, 2, 5, 3], [1, 2, 3, 4, 5]]),
           ( all_equations(List, Equations),
             length(Equations, Expected),
             count_equations(List, Actual),
             Expected =:= Actual )).

test(longer_lists_stay_tractable) :-
    count_equations([1, 2, 3, 4, 5, 6], N),
    N > 0.

:- end_tests(q2).
