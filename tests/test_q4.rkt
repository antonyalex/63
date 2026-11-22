#lang racket/base

;; tests/test_q4.rkt  --  tests for S2 (code/63_q4.rkt)
;;
;; Run with:  racket tests/test_q4.rkt
;;
;; As for S1, each case copies the solution source to a temporary file,
;; appends the calls under test, runs `racket` on the copy with the given
;; standard input, and compares the captured stdout byte for byte.  That is
;; exactly how the grader exercises the file.
;;
;; The scale cases match the hidden tests named in the assignment: nesting
;; depth 100 and lists of 10 000 elements.  Their expected output is built
;; here from the definition of the problem, independently of the solution, so
;; they are a real check and not a restatement of the implementation.

(require racket/file
         racket/port
         racket/string
         racket/system
         racket/runtime-path)

(define-runtime-path solution-file "../code/63_q4.rkt")

(define racket-executable
  (let ([exec (find-system-path 'exec-file)])
    (or (and (absolute-path? exec) exec)
        (find-executable-path exec)
        (find-executable-path "racket"))))

;; run-grader-style : string string -> string
;; The stdout produced by the solution file with `calls` appended to it and
;; `input` supplied on standard input.
(define (run-grader-style calls input)
  (define temporary (make-temporary-file "popl63-q4-~a.rkt"))
  (display-to-file (string-append (file->string solution-file) "\n" calls "\n")
                   temporary
                   #:exists 'replace)
  (define output
    (parameterize ([current-input-port (open-input-string input)])
      (with-output-to-string
        (lambda () (system* racket-executable temporary)))))
  (delete-file temporary)
  output)

(define failures 0)

(define (check label calls input expected)
  (define actual (run-grader-style calls input))
  (cond
    [(equal? actual expected)
     (printf "ok    ~a\n" label)]
    [else
     (set! failures (add1 failures))
     (printf "FAIL  ~a\n      expected ~s\n      actual   ~s\n"
             label expected actual)]))

;; read-case : string string -> void
;; Shorthand for the S2.a entry point: one line of standard input in, one line
;; of output expected.
(define (read-case label input expected)
  (check label "(print-insert-result)" input expected))

;; ---------------------------------------------------------------------------
;; S2.a  --  the four examples printed in the assignment
;; ---------------------------------------------------------------------------

(read-case "example 1"
           "42 ((1 2) (3 4 5) (6) ()) 3\n"
           "((42 1 2) (3 4 5) (42 6) (42))\n")

(read-case "example 2 (deeper nesting)"
           "0 (((1) 2) (3) ((4 5 6) ())) 3\n"
           "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))\n")

(read-case "example 3 (empty top-level list, 0 < n)"
           "7 () 3\n"
           "(7)\n")

(read-case "example 4 (empty top-level list, n = 0)"
           "7 () 0\n"
           "()\n")

;; ---------------------------------------------------------------------------
;; S2.a  --  reading behaviour
;; ---------------------------------------------------------------------------

(read-case "the three values may be spread over several lines"
           "42\n((1 2) (3 4 5) (6) ())\n3\n"
           "((42 1 2) (3 4 5) (42 6) (42))\n")

(read-case "x may be a symbol"
           "star ((1) ()) 2\n"
           "((star 1) (star))\n")

(read-case "symbols nest like any other atom"
           ;; The top-level list has length 2, which is also < 3, so it
           ;; receives a z of its own as well as its two elements doing so.
           "z ((a b) (c)) 3\n"
           "(z (z a b) (z c))\n")

;; ---------------------------------------------------------------------------
;; The rules the problem is really testing
;; ---------------------------------------------------------------------------

(read-case "length is measured before insertion, not after"
           ;; The inner (1 2) has length 2 < 3 so it gains an element.  If the
           ;; length were re-measured afterwards it would be 3 and nothing
           ;; would be inserted, so this case separates the two readings.
           "9 ((1 2)) 3\n"
           "(9 (9 1 2))\n")

(read-case "n = 0 inserts nothing anywhere"
           "9 ((1) () (2 3)) 0\n"
           "((1) () (2 3))\n")

(read-case "a list of exactly length n is left alone"
           "9 ((1 2 3)) 3\n"
           "(9 (1 2 3))\n")

(read-case "the top-level list is treated like every other list"
           "9 (1 2) 3\n"
           "(9 1 2)\n")

(read-case "a long top-level list is not touched but its short elements are"
           "9 (1 2 3 4 (5)) 3\n"
           "(1 2 3 4 (9 5))\n")

(read-case "empty lists nested inside become single-element lists"
           ;; The top-level list has length 3, which is not < 2, so it is left
           ;; alone while every empty list inside it gains a 9.
           "9 (() (()) ()) 2\n"
           "((9) (9 (9)) (9))\n")

;; ---------------------------------------------------------------------------
;; S2.b  --  the hand-written list primitives
;; ---------------------------------------------------------------------------

(check "my-length counts top-level elements"
       "(display (my-length '(1 (2 3) 4))) (newline)"
       ""
       "3\n")

(check "my-length of the empty list is 0"
       "(display (my-length '())) (newline)"
       ""
       "0\n")

(check "my-reverse reverses"
       "(display (my-reverse '(1 2 3))) (newline)"
       ""
       "(3 2 1)\n")

(check "my-reverse of the empty list is the empty list"
       "(display (my-reverse '())) (newline)"
       ""
       "()\n")

(check "my-map preserves order"
       "(display (my-map (lambda (v) (+ v 1)) '(1 2 3))) (newline)"
       ""
       "(2 3 4)\n")

(check "my-map of the empty list is the empty list"
       "(display (my-map (lambda (v) v) '())) (newline)"
       ""
       "()\n")

;; ---------------------------------------------------------------------------
;; S2.c  --  make-inserter with a predicate other than "shorter than n"
;; ---------------------------------------------------------------------------

(check "make-inserter accepts an arbitrary length test"
       (string-append
        "(define insert-into-pairs (make-inserter 'z (lambda (k) (= k 2))))\n"
        "(display (insert-into-pairs '((1 2) (3) ()))) (newline)")
       ""
       "((z 1 2) (3) ())\n")

(check "the function make-inserter returns is reusable"
       (string-append
        "(define f (make-inserter 'q (lambda (k) (< k 1))))\n"
        "(display (f '(() (1)))) (newline)\n"
        "(display (f '(()))) (newline)")
       ""
       "((q) (1))\n((q))\n")

(check "insert-if-short agrees with make-inserter used directly"
       (string-append
        "(display (insert-if-short 5 '((1) (2 3)) 2)) (newline)\n"
        "(display ((make-inserter 5 (lambda (k) (< k 2))) '((1) (2 3)))) (newline)")
       ""
       "((5 1) (2 3))\n((5 1) (2 3))\n")

;; ---------------------------------------------------------------------------
;; The file must be inert when merely loaded
;; ---------------------------------------------------------------------------

(check "loading the solution with no appended calls prints nothing"
       "" "" "")

;; ---------------------------------------------------------------------------
;; Scale, matching the hidden tests named in the assignment
;; ---------------------------------------------------------------------------

;; wrap : number (string -> string) string -> string
;; Apply f to seed, times times.
(define (wrap times f seed)
  (if (= times 0) seed (wrap (- times 1) f (f seed))))

;; A chain nested 100 deep: L1 = (), L(k+1) = (Lk).
(define depth 100)
(define deep-input (wrap (- depth 1) (lambda (s) (string-append "(" s ")")) "()"))
;; With n = 3 every list on the chain has length 0 or 1, so all of them gain a 9:
;; R1 = (9), R(k+1) = (9 Rk).
(define deep-expected (wrap (- depth 1) (lambda (s) (string-append "(9 " s ")")) "(9)"))

(read-case "nesting depth 100"
           (string-append "9 " deep-input " 3\n")
           (string-append deep-expected "\n"))

;; A flat list of 10 000 numbers.
(define wide-count 10000)
(define wide-elements
  (string-join (for/list ([i (in-range 1 (+ wide-count 1))]) (number->string i)) " "))

(read-case "10 000 elements, top-level list short enough to receive x"
           (string-append "9 (" wide-elements ") " (number->string (+ wide-count 1)) "\n")
           (string-append "(9 " wide-elements ")\n"))

(read-case "10 000 elements, top-level list too long to receive x"
           (string-append "9 (" wide-elements ") 1\n")
           (string-append "(" wide-elements ")\n"))

;; A flat list of 10 000 empty lists: each one is short, the outer one is not.
(define wide-empties (string-join (for/list ([i (in-range wide-count)]) "()") " "))
(define wide-empties-expected (string-join (for/list ([i (in-range wide-count)]) "(9)") " "))

(read-case "10 000 nested empty lists each receive x"
           (string-append "9 (" wide-empties ") 1\n")
           (string-append "(" wide-empties-expected ")\n"))

;; ---------------------------------------------------------------------------

(printf "\n~a\n" (if (= failures 0)
                     "all S2 tests passed"
                     (format "~a S2 test(s) FAILED" failures)))
(exit (if (= failures 0) 0 1))
