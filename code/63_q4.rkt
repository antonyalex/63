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

;; ---------------------------------------------------------------------------
;; S2.c  --  the higher-order inserter
;; ---------------------------------------------------------------------------

;; make-inserter : atom (number -> boolean) -> ((listof any) -> (listof any))
;; Returns a function of one list that inserts x at the front of every list,
;; at every level of nesting, whose length satisfies len-ok?.
;;
;; Two mutually recursive helpers do the work:
;;
;;   transform  is applied to something known to be a list.  It measures the
;;              ORIGINAL length first, rebuilds the elements, and only then
;;              decides whether to put x in front -- so an insertion made
;;              inside an element can never change the length that was tested.
;;
;;   walk       is applied to an element, which may be an atom or a list.  The
;;              test is (or (pair? item) (null? item)) and not pair? alone,
;;              because '() is a list that must still be transformed but is
;;              not a pair.
;;
;; Measure: transform only ever recurses, through walk, into an element of its
;; argument, so the nesting depth strictly decreases and the recursion ends.
(define (make-inserter x len-ok?)
  (letrec ((transform
            (lambda (lst)
              (let* ((original-length (my-length lst))
                     (rebuilt (my-map walk lst)))
                (if (len-ok? original-length)
                    (cons x rebuilt)
                    rebuilt))))
           (walk
            (lambda (item)
              (if (or (pair? item) (null? item))
                  (transform item)
                  item))))
    (lambda (lst)
      (transform lst))))

;; insert-if-short : atom (listof any) number -> (listof any)
;; S2.b and S2.c.  x inserted at the front of every list, at every level of
;; nesting, whose original length is less than n.  This is the file's single
;; definition of insert-if-short, and it is the one written in terms of
;; make-inserter: the only thing it supplies is the length test.
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; ---------------------------------------------------------------------------
;; S2.a  --  read three values, print one result
;; ---------------------------------------------------------------------------

;; print-insert-result : -> void
;; Reads x, then lst, then n from standard input, and prints the result of
;; insert-if-short on one line.  let* is what fixes the three reads into that
;; order; a plain let would not guarantee it.  No prompt and no other text is
;; printed, and the line ends with a newline.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))
