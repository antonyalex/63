%  tests/test_q1.pl  --  tests for P1 (code/63_q1.pl)
%
%  Run with:  swipl -q -g run_tests -t halt tests/test_q1.pl
%
%  Covers: the exact output format and content of main/0, every clue
%  individually (one accepting and one rejecting case each), the counts asked
%  for in P1.b, and the uniqueness guaranteed by the repair clue of P1.c.

:- use_module(library(plunit)).
:- use_module(library(lists)).
:- ensure_loaded('../code/63_q1.pl').

%  ---------------------------------------------------------------------------
%  Fixtures: the three assignments that satisfy clues 1 to 8
%  ---------------------------------------------------------------------------

known(one, [p('Alex',  design,      java,       embedded),
            p('Ben',   development, javascript, web),
            p('Carla', testing,     python,     'AI'),
            p('Dana',  research,    'c++',      data)]).
known(two, [p('Alex',  testing,     python,     embedded),
            p('Ben',   development, javascript, web),
            p('Carla', design,      java,       'AI'),
            p('Dana',  research,    'c++',      data)]).
known(three, [p('Alex',  design,      java,       'AI'),
              p('Ben',   development, javascript, web),
              p('Carla', research,    'c++',      data),
              p('Dana',  testing,     python,     embedded)]).

%  ---------------------------------------------------------------------------
%  Helpers: read main/0's printed output back into terms
%  ---------------------------------------------------------------------------

%! main_people(-People:list) is det.
%  People is what main/0 printed, parsed back into p/4 terms.  Parsing the
%  printed text (rather than calling solution/1 again) is what makes this a
%  test of the output format and not just of the search.
main_people(People) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", Chunks),
    once(append(Lines, [""], Chunks)),
    maplist(parse_line, Lines, People).

%! parse_line(+Line:string, -Person) is semidet.
%  Line has exactly the shape  Name = [Dept, Lang, Project]  and Person is the
%  corresponding p/4 term.  Fails on any other shape, which is the point.
parse_line(Line, p(Name, Dept, Lang, Project)) :-
    split_string(Line, "=", " ", [NameText, Bracketed]),
    string_concat("[", Tail, Bracketed),
    string_concat(Inner, "]", Tail),
    split_string(Inner, ",", " ", [DeptText, LangText, ProjectText]),
    atom_string(Name, NameText),
    atom_string(Dept, DeptText),
    atom_string(Lang, LangText),
    atom_string(Project, ProjectText).

:- begin_tests(q1).

%  ---------------------------------------------------------------------------
%  P1.a  --  main/0
%  ---------------------------------------------------------------------------

test(main_prints_exactly_four_lines) :-
    main_people(People),
    length(People, 4).

test(main_prints_the_friends_in_the_fixed_order) :-
    main_people([p(A,_,_,_), p(B,_,_,_), p(C,_,_,_), p(D,_,_,_)]),
    [A, B, C, D] == ['Alex', 'Ben', 'Carla', 'Dana'].

test(main_output_satisfies_clues_1_to_8) :-
    main_people(People),
    satisfies([1, 2, 3, 4, 5, 6, 7, 8], People).

test(main_uses_each_attribute_value_exactly_once) :-
    main_people(People),
    findall(X, member(p(_, X, _, _), People), Depts),
    findall(X, member(p(_, _, X, _), People), Langs),
    findall(X, member(p(_, _, _, X), People), Projects),
    departments(DeptDomain), msort(Depts, SortedDepts), msort(DeptDomain, SortedDeptDomain),
    languages(LangDomain),   msort(Langs, SortedLangs), msort(LangDomain, SortedLangDomain),
    projects(ProjectDomain), msort(Projects, SortedProjects), msort(ProjectDomain, SortedProjectDomain),
    SortedDepts == SortedDeptDomain,
    SortedLangs == SortedLangDomain,
    SortedProjects == SortedProjectDomain.

test(main_output_is_one_of_the_three_known_assignments) :-
    main_people(People),
    once(known(_, People)).

test(main_ends_with_a_newline_and_prints_nothing_else) :-
    with_output_to(string(Out), main),
    string_concat(_, "\n", Out),
    split_string(Out, "\n", "", Chunks),
    length(Chunks, 5).            % four lines plus the empty tail chunk

%  ---------------------------------------------------------------------------
%  The clues, one accepting and one rejecting case each
%  ---------------------------------------------------------------------------

test(all_three_known_assignments_satisfy_clues_1_to_8) :-
    forall(known(_, Solution), satisfies([1, 2, 3, 4, 5, 6, 7, 8], Solution)).

test(clue1_rejects_dana_on_ai) :-
    \+ clue(1, [p('Alex', design, java, embedded), p('Ben', development, javascript, web),
                p('Carla', testing, python, data), p('Dana', research, 'c++', 'AI')]).

test(clue1_rejects_ai_in_research) :-
    \+ clue(1, [p('Alex', research, java, 'AI'), p('Ben', development, javascript, web),
                p('Carla', testing, python, data), p('Dana', design, 'c++', embedded)]).

test(clue2_rejects_alex_in_development) :-
    \+ clue(2, [p('Alex', development, java, embedded), p('Ben', design, javascript, web),
                p('Carla', testing, python, 'AI'), p('Dana', research, 'c++', data)]).

test(clue2_rejects_alex_on_cpp) :-
    \+ clue(2, [p('Alex', design, 'c++', embedded), p('Ben', development, javascript, web),
                p('Carla', testing, python, 'AI'), p('Dana', research, java, data)]).

test(clue3_rejects_tester_without_python) :-
    \+ clue(3, [p('Alex', design, java, embedded), p('Ben', development, javascript, web),
                p('Carla', testing, 'c++', 'AI'), p('Dana', research, python, data)]).

test(clue4_rejects_ben_without_web) :-
    \+ clue(4, [p('Alex', design, java, web), p('Ben', development, javascript, embedded),
                p('Carla', testing, python, 'AI'), p('Dana', research, 'c++', data)]).

test(clue4_rejects_ben_in_testing) :-
    \+ clue(4, [p('Alex', design, java, embedded), p('Ben', testing, python, web),
                p('Carla', development, javascript, 'AI'), p('Dana', research, 'c++', data)]).

test(clue5_rejects_java_outside_design) :-
    \+ clue(5, [p('Alex', research, java, embedded), p('Ben', development, javascript, web),
                p('Carla', testing, python, 'AI'), p('Dana', design, 'c++', data)]).

test(clue6_rejects_carla_on_embedded) :-
    \+ clue(6, [p('Alex', design, java, 'AI'), p('Ben', development, javascript, web),
                p('Carla', testing, python, embedded), p('Dana', research, 'c++', data)]).

test(clue6_rejects_carla_in_development) :-
    \+ clue(6, [p('Alex', design, java, embedded), p('Ben', testing, python, web),
                p('Carla', development, javascript, 'AI'), p('Dana', research, 'c++', data)]).

test(clue7_rejects_dana_on_java) :-
    \+ clue(7, [p('Alex', design, 'c++', embedded), p('Ben', development, javascript, web),
                p('Carla', testing, python, 'AI'), p('Dana', research, java, data)]).

test(clue7_rejects_dana_in_design) :-
    \+ clue(7, [p('Alex', research, java, embedded), p('Ben', development, javascript, web),
                p('Carla', testing, python, 'AI'), p('Dana', design, 'c++', data)]).

test(clue8_rejects_data_outside_research) :-
    \+ clue(8, [p('Alex', design, java, embedded), p('Ben', development, javascript, data),
                p('Carla', testing, python, 'AI'), p('Dana', research, 'c++', web)]).

test(clue8_rejects_data_on_javascript) :-
    \+ clue(8, [p('Alex', design, java, embedded), p('Ben', development, 'c++', web),
                p('Carla', testing, python, 'AI'), p('Dana', research, javascript, data)]).

%  ---------------------------------------------------------------------------
%  P1.b  --  count_solutions/2
%  ---------------------------------------------------------------------------

test(count_of_no_clues_is_the_whole_search_space, [true(N =:= 13824)]) :-
    count_solutions([], N).

test(count_of_clues_1_to_8_is_three, [true(N =:= 3)]) :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8], N).

test(count_ignores_clues_not_listed, [true(N =:= 3)]) :-
    % Clue 9 is defined in the file but must be ignored when it is not Active.
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8], N).

test(count_of_a_single_clue_is_a_real_restriction) :-
    count_solutions([1], N),
    N > 0,
    N < 13824.

test(count_is_monotone_in_the_clue_set) :-
    count_solutions([1, 2, 3, 4], Fewer),
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8], More),
    More =< Fewer.

%  ---------------------------------------------------------------------------
%  P1.c  --  the repair clue
%  ---------------------------------------------------------------------------

test(clues_1_to_9_have_exactly_one_solution, [true(N =:= 1)]) :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8, 9], N).

test(clue9_holds_in_exactly_one_of_the_three_known_assignments) :-
    findall(Tag, ( known(Tag, Solution), once(clue(9, Solution)) ), Tags),
    Tags == [one].

test(clue9_is_not_a_tautology) :-
    count_solutions([9], N),
    N < 13824.

test(the_surviving_assignment_is_the_expected_one) :-
    findall(Solution, ( solution(Solution),
                        satisfies([1, 2, 3, 4, 5, 6, 7, 8, 9], Solution)
                      ), [Survivor]),
    known(one, Survivor).

:- end_tests(q1).
