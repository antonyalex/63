%  63_q2.pl  --  P2: Form a Valid Arithmetic Equation
%
%  CS F301 Principles of Programming Languages, Assignment 2, Group 63.
%
%  Given a list of non-negative integers, insert the operators + - * / and
%  exactly one = between the numbers, using every number once in the given
%  order, with optional parentheses, so that both sides have the same value.
%
%  Expressions are kept as terms and evaluated as terms.  A string is produced
%  only at the very end, for output, and is never read back in to be evaluated.
%
%      num(N)            a single number
%      op(Op, Left, Right)   Left Op Right, with Op one of + - * /
%
%  The file holds definitions only: no initialization directive, no top-level
%  goal, no printing.

:- use_module(library(lists)).

%  ---------------------------------------------------------------------------
%  Expression trees and their values
%  ---------------------------------------------------------------------------

%! operator(?Op:atom) is nondet.
%  Op is one of the four operators that may be inserted between numbers.
operator(+).
operator(-).
operator(*).
operator(/).

%! evaluate(+Op:atom, +Left:integer, +Right:integer, -Value:integer) is semidet.
%  Value is Left Op Right under the rules of this problem: everything stays an
%  integer, sub-expressions may be negative, and division is allowed only when
%  the divisor is non-zero and the result has no remainder.  The guard comes
%  before the division, so a zero divisor makes this fail rather than raise.
evaluate(+, Left, Right, Value) :- Value is Left + Right.
evaluate(-, Left, Right, Value) :- Value is Left - Right.
evaluate(*, Left, Right, Value) :- Value is Left * Right.
evaluate(/, Left, Right, Value) :-
    Right =\= 0,
    Left mod Right =:= 0,
    Value is Left // Right.

%! expression(+Numbers:list(integer), -Expression, -Value:integer) is nondet.
%  Expression is a parse tree that uses exactly the integers in Numbers, in the
%  order given, and Value is its integer value.
%
%  Base case: a one-element list is the single number itself, which is already
%  a complete expression.
%  Recursive case: split Numbers into a non-empty prefix and a non-empty
%  suffix, build an expression over each side, and join them with an operator.
%  Measure: both sides are strictly shorter than Numbers, so the recursion
%  terminates; on [] it has no clause that applies and simply fails.
%
%  Every distinct parse tree is produced exactly once, because a split point
%  plus a left tree plus a right tree plus an operator determines the tree and
%  append/3 yields each split point once.
expression([Number], num(Number), Number) :-
    integer(Number).
expression(Numbers, op(Op, LeftTree, RightTree), Value) :-
    append(Left, Right, Numbers),
    Left = [_ | _],
    Right = [_ | _],
    expression(Left, LeftTree, LeftValue),
    expression(Right, RightTree, RightValue),
    operator(Op),
    evaluate(Op, LeftValue, RightValue, Value).

%  ---------------------------------------------------------------------------
%  Canonical form
%  ---------------------------------------------------------------------------
%
%  The printing rule given in the assignment, which gives every distinct parse
%  tree a distinct string:
%
%    * and / bind tighter than + and -;  operators are left-associative;
%    a LEFT operand is parenthesised only if its top operator has LOWER
%    precedence than its parent's;  a RIGHT operand is parenthesised if its top
%    operator has the SAME OR LOWER precedence than its parent's;  a single
%    number is never parenthesised.
%
%  The right-hand rule is the asymmetric one, and it is what makes 1+2+3 and
%  1+(2+3) print differently even though they have the same value.

%! precedence(+Op:atom, -Level:integer) is det.
%  Level is the binding strength of Op: 2 for * and /, 1 for + and -.
precedence(+, 1).
precedence(-, 1).
precedence(*, 2).
precedence(/, 2).

%! render(+Expression, -Text:string) is det.
%  Text is the canonical, space-free rendering of Expression.
%  Base case: a number renders as its decimal digits.
%  Recursive case: render both operands at this node's precedence and join
%  them with the operator; the sub-trees are strictly smaller.
render(num(Number), Text) :-
    number_string(Number, Text).
render(op(Op, LeftTree, RightTree), Text) :-
    precedence(Op, Level),
    render_operand(left, Level, LeftTree, LeftText),
    render_operand(right, Level, RightTree, RightText),
    format(string(Text), "~w~w~w", [LeftText, Op, RightText]).

%! render_operand(+Side:atom, +ParentLevel:integer, +Expression, -Text:string) is det.
%  Text is Expression rendered, wrapped in parentheses exactly when the rule
%  above requires it for an operand appearing on Side of a parent whose
%  precedence is ParentLevel.
render_operand(Side, ParentLevel, Expression, Text) :-
    render(Expression, Inner),
    (   needs_parentheses(Side, ParentLevel, Expression)
    ->  format(string(Text), "(~w)", [Inner])
    ;   Text = Inner
    ).

%! needs_parentheses(+Side:atom, +ParentLevel:integer, +Expression) is semidet.
%  True when Expression, sitting on Side of a parent of precedence ParentLevel,
%  must be parenthesised.  There is deliberately no clause for num(_): a single
%  number is never parenthesised, so this fails for it.
needs_parentheses(left, ParentLevel, op(Op, _, _)) :-
    precedence(Op, Level),
    Level < ParentLevel.
needs_parentheses(right, ParentLevel, op(Op, _, _)) :-
    precedence(Op, Level),
    Level =< ParentLevel.
