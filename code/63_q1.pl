%  63_q1.pl  --  P1: Department Assignment Puzzle, Reloaded
%
%  CS F301 Principles of Programming Languages, Assignment 2, Group 63.
%
%  A fully filled-in Solution is a list of exactly four terms
%
%      [p('Alex',  DeptA, LangA, ProjA),
%       p('Ben',   DeptB, LangB, ProjB),
%       p('Carla', DeptC, LangC, ProjC),
%       p('Dana',  DeptD, LangD, ProjD)]
%
%  always in that name order.  Each of the three attribute domains is used
%  exactly once across the four friends.
%
%  The file holds definitions only: no initialization directive, no top-level
%  goal, no call to halt/0.  The grader runs
%      swipl -q -f 63_q1.pl -g main -t halt

:- use_module(library(lists)).
:- use_module(library(aggregate)).

%  ---------------------------------------------------------------------------
%  Domains
%  ---------------------------------------------------------------------------

%! friends(-Names:list(atom)) is det.
%  Names is the fixed left-to-right order in which a Solution lists the friends.
friends(['Alex', 'Ben', 'Carla', 'Dana']).

%! departments(-Departments:list(atom)) is det.
%  Departments is the set of department values, each used exactly once.
departments([research, development, design, testing]).

%! languages(-Languages:list(atom)) is det.
%  Languages is the set of favourite-language values, each used exactly once.
languages([python, java, 'c++', javascript]).

%! projects(-Projects:list(atom)) is det.
%  Projects is the set of project-preference values, each used exactly once.
projects(['AI', web, embedded, data]).

%  ---------------------------------------------------------------------------
%  Candidate generator
%  ---------------------------------------------------------------------------

%! solution(-Solution:list) is nondet.
%  Solution is a fully filled-in assignment: a list of four p/4 terms in the
%  fixed friend order in which every attribute domain is distributed as a
%  permutation, so each value is used exactly once.  No clue is applied here --
%  this is the generator alone, and it enumerates 24*24*24 = 13824 candidates
%  and then stops, so any search over it terminates.
solution(Solution) :-
    friends([NameA, NameB, NameC, NameD]),
    departments(Departments),
    languages(Languages),
    projects(Projects),
    permutation(Departments, [DeptA, DeptB, DeptC, DeptD]),
    permutation(Languages,   [LangA, LangB, LangC, LangD]),
    permutation(Projects,    [ProjA, ProjB, ProjC, ProjD]),
    Solution = [p(NameA, DeptA, LangA, ProjA),
                p(NameB, DeptB, LangB, ProjB),
                p(NameC, DeptC, LangC, ProjC),
                p(NameD, DeptD, LangD, ProjD)].

%! person(+Solution:list, ?Name, ?Dept, ?Lang, ?Project) is nondet.
%  The friend Name in Solution works in Dept, likes Lang and prefers Project.
%  Used by the clues to look a friend up by any of their four attributes; in a
%  fully filled-in Solution each attribute value identifies exactly one friend.
person(Solution, Name, Dept, Lang, Project) :-
    member(p(Name, Dept, Lang, Project), Solution).

%  ---------------------------------------------------------------------------
%  The clues
%  ---------------------------------------------------------------------------
%
%  clue(N, Solution) succeeds exactly when clue number N holds in the fully
%  filled-in Solution, and fails otherwise.  Each clue is one clause, numbered
%  as in the assignment, with the English sentence directly above it.  Because
%  Solution is ground, \== is the honest inequality test here.

% CLUE 1: The friend who prefers the AI project does not work in research and
%         is not Dana.
clue(1, Solution) :-
    person(Solution, Name, Dept, _Lang, 'AI'),
    Dept \== research,
    Name \== 'Dana'.

% CLUE 2: Alex does not work in development and does not prefer C++.
clue(2, Solution) :-
    person(Solution, 'Alex', Dept, Lang, _Project),
    Dept \== development,
    Lang \== 'c++'.

% CLUE 3: The friend working in the testing department likes Python.
clue(3, Solution) :-
    person(Solution, _Name, testing, python, _Project).

% CLUE 4: Ben prefers web projects and does not work in testing.
clue(4, Solution) :-
    person(Solution, 'Ben', Dept, _Lang, web),
    Dept \== testing.

% CLUE 5: The friend whose favorite language is Java works in the design
%         department.
clue(5, Solution) :-
    person(Solution, _Name, design, java, _Project).

% CLUE 6: Carla's project preference is not embedded, and her department is not
%         development.
clue(6, Solution) :-
    person(Solution, 'Carla', Dept, _Lang, Project),
    Project \== embedded,
    Dept \== development.

% CLUE 7: Dana's favorite language is not Java, and she works in research or
%         testing.
clue(7, Solution) :-
    person(Solution, 'Dana', Dept, Lang, _Project),
    Lang \== java,
    memberchk(Dept, [research, testing]).

% CLUE 8: The friend who prefers data projects works in research and does not
%         use JavaScript.
clue(8, Solution) :-
    person(Solution, _Name, research, Lang, data),
    Lang \== javascript.

%  ---------------------------------------------------------------------------
%  Applying a set of clues
%  ---------------------------------------------------------------------------

%! satisfies(+Active:list(integer), +Solution:list) is semidet.
%  Every clue number in Active holds in Solution.  Semidet by construction:
%  forall/2 commits, so a clue that can be proved more than one way still
%  contributes exactly one success.
satisfies(Active, Solution) :-
    forall(member(Number, Active), clue(Number, Solution)).

%  ---------------------------------------------------------------------------
%  P1.a  --  solve
%  ---------------------------------------------------------------------------

%! main is det.
%  Prints one assignment satisfying clues 1 to 8, as four lines
%      Name = [Dept, Lang, Project]
%  in the fixed order Alex, Ben, Carla, Dana.  The answer is derived by search
%  over solution/1 and the clue predicates; nothing about it is hard-coded.
%  once/1 makes main deterministic even though clues 1 to 8 admit more than one
%  assignment (see count_solutions/2 and P1_REPORT.md).
main :-
    once((solution(Solution), satisfies([1, 2, 3, 4, 5, 6, 7, 8], Solution))),
    print_solution(Solution).

%! print_solution(+Solution:list) is det.
%  Writes one line per friend, in Solution order.  Base case: the empty list
%  prints nothing.  Recursive case: print the head, then the tail; the list
%  shrinks by one element each step.
print_solution([]).
print_solution([p(Name, Dept, Lang, Project) | Rest]) :-
    format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Project]),
    print_solution(Rest).
