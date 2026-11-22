#lang racket/base

;; 63_q3.rkt  --  S1: Binary Tree Traversals
;;
;; CS F301 Principles of Programming Languages, Assignment 2, Group 63.
;;
;; A binary tree is either the empty list '() or a three-element list
;; (value left right), where left and right are binary trees and value is a
;; number or a single-character symbol.  Subtrees are always visited left
;; first, then right.
;;
;; Only the built-ins allowed by the assignment are used: define, if, cond with
;; else, null?, car/cadr/caddr, cons, list, +, max, display, newline and quote.
;; In particular there is no length, append, reverse or map anywhere, and no
;; loop form -- every walk is a recursion.
;;
;; The file defines and does nothing else: loading it prints nothing and calls
;; nothing.  The grader appends its own calls to the end.

;; ---------------------------------------------------------------------------
;; Tree accessors
;;
;; Naming the three positions once keeps every walk below readable and keeps
;; the car/cdr compositions in a single place.
;; ---------------------------------------------------------------------------

;; node-value : tree -> value
;; The value stored at the root of a non-empty tree.
(define (node-value tree) (car tree))

;; node-left : tree -> tree
;; The left subtree of a non-empty tree.
(define (node-left tree) (cadr tree))

;; node-right : tree -> tree
;; The right subtree of a non-empty tree.
(define (node-right tree) (caddr tree))

;; leaf? : tree -> boolean
;; True when tree is a node whose two subtrees are both empty.  The empty tree
;; is not a leaf, which is why the non-emptiness test comes first; and/not keep
;; this to whitelisted built-ins, with no boolean literal needed.
(define (leaf? tree)
  (and (not (null? tree))
       (null? (node-left tree))
       (null? (node-right tree))))

;; ---------------------------------------------------------------------------
;; Traversals, in accumulator-passing style
;;
;; Each of these is written as "the traversal of tree, prepended to acc".
;; Threading the tail through as an argument is what lets the result be built
;; in one pass with nothing but cons -- append is forbidden, and would be
;; quadratic here anyway.
;; ---------------------------------------------------------------------------

;; inorder-onto : tree (listof value) -> (listof value)
;; (inorder-onto t acc) IS the inorder value list of t followed by acc.
;; Base case: the empty tree contributes nothing, so the answer is acc.
;; Recursive case: the right subtree's list is built onto acc, the node's value
;; is consed in front of it, and the left subtree's list is built onto that --
;; which is exactly left, node, right.
;; Measure: both recursive calls take a strict subtree, so the recursion ends.
(define (inorder-onto tree acc)
  (if (null? tree)
      acc
      (inorder-onto (node-left tree)
                    (cons (node-value tree)
                          (inorder-onto (node-right tree) acc)))))

;; preorder-onto : tree (listof value) -> (listof value)
;; (preorder-onto t acc) IS the preorder value list of t followed by acc,
;; that is node, left subtree, right subtree.
(define (preorder-onto tree acc)
  (if (null? tree)
      acc
      (cons (node-value tree)
            (preorder-onto (node-left tree)
                           (preorder-onto (node-right tree) acc)))))

;; postorder-onto : tree (listof value) -> (listof value)
;; (postorder-onto t acc) IS the postorder value list of t followed by acc,
;; that is left subtree, right subtree, node.
(define (postorder-onto tree acc)
  (if (null? tree)
      acc
      (postorder-onto (node-left tree)
                      (postorder-onto (node-right tree)
                                      (cons (node-value tree) acc)))))

;; ---------------------------------------------------------------------------
;; Shape measurements
;; ---------------------------------------------------------------------------

;; tree-height : tree -> number
;; The height of the empty tree is 0, and the height of a node is 1 plus the
;; larger of its two subtree heights, so a single node has height 1.
(define (tree-height tree)
  (if (null? tree)
      0
      (+ 1 (max (tree-height (node-left tree))
                (tree-height (node-right tree))))))

;; leaf-count : tree -> number
;; The number of leaves of tree.  The empty tree has none; a leaf counts once;
;; any other node contributes the leaves of its two subtrees.
(define (leaf-count tree)
  (cond ((null? tree) 0)
        ((leaf? tree) 1)
        (else (+ (leaf-count (node-left tree))
                 (leaf-count (node-right tree))))))

;; ---------------------------------------------------------------------------
;; S1.a, S1.b, S1.c  --  the three functions the grader calls
;;
;; Each prints with display and ends its output with a newline, and prints
;; nothing else: no label, no prompt, no trailing space.
;; ---------------------------------------------------------------------------

;; print-inorder : tree -> void
;; S1.a.  Prints the inorder list of the values of tree on one line.
(define (print-inorder tree)
  (display (inorder-onto tree '()))
  (newline))

;; print-all-traversals : tree -> void
;; S1.b.  Prints three lines: the inorder list, then the preorder list, then
;; the postorder list.
(define (print-all-traversals tree)
  (display (inorder-onto tree '()))
  (newline)
  (display (preorder-onto tree '()))
  (newline)
  (display (postorder-onto tree '()))
  (newline))

;; print-height-and-leaves : tree -> void
;; S1.c.  Prints the two-element list (height leaf-count) on one line.
(define (print-height-and-leaves tree)
  (display (list (tree-height tree) (leaf-count tree)))
  (newline))
