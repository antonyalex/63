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
