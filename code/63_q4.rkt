#lang racket/base

;; 63_q4.rkt  --  S2: Conditionally Insert into a Nested List
;;
;; CS F301 Principles of Programming Languages, Assignment 2, Group 63.
;;
;; insert-if-short takes an atom x, a possibly nested list lst and an integer
;; n >= 0, and inserts x at the front of every list whose length is less than
;; n, at every level of nesting.  Lengths are measured on the ORIGINAL list,
;; before any insertion.  The top-level list is treated like every other list,
;; and the empty list is not special: () has length 0, so it becomes (x)
;; whenever 0 < n.
;;
;; Only the built-ins allowed by the assignment are used: define, lambda, let,
;; let*, letrec, named let, if, or, null?, pair?, car, cdr, cons, +, <,
;; display, newline, read and quote.  length, append, map and reverse are
;; forbidden, so my-length, my-map and my-reverse below are written by hand.
;;
;; The file defines and does nothing else: loading it prints nothing and calls
;; nothing.  The grader appends its own calls to the end.

;; ---------------------------------------------------------------------------
;; S2.b  --  hand-written replacements for the forbidden list primitives
;;
;; All three are tail-recursive named lets, so a 10 000-element list costs
;; constant stack.
;; ---------------------------------------------------------------------------

;; my-length : (listof any) -> number
;; The number of top-level elements of lst.
;; Base case: the empty list has length 0, which is the accumulator's start.
;; Recursive case: drop one element and add one to the count.
;; Measure: the remaining list is one element shorter each step.
(define (my-length lst)
  (let count ((rest lst)
              (acc 0))
    (if (null? rest)
        acc
        (count (cdr rest) (+ acc 1)))))

;; my-reverse : (listof A) -> (listof A)
;; The elements of lst in the opposite order.
;; Base case: reversing the empty list gives the accumulator, which holds the
;; elements already moved across.
;; Recursive case: move the head onto the front of the accumulator.
;; Measure: the remaining list shrinks by one element each step.
(define (my-reverse lst)
  (let flip ((rest lst)
             (acc '()))
    (if (null? rest)
        acc
        (flip (cdr rest) (cons (car rest) acc)))))

;; my-map : (A -> B) (listof A) -> (listof B)
;; The list of (f e) for each element e of lst, in the original order.
;; Built back-to-front into an accumulator and reversed once at the end, so
;; the walk stays tail-recursive without needing append.
(define (my-map f lst)
  (let step ((rest lst)
             (acc '()))
    (if (null? rest)
        (my-reverse acc)
        (step (cdr rest) (cons (f (car rest)) acc)))))
