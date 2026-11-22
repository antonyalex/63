#lang racket/base

;; tests/test_q3.rkt  --  tests for S1 (code/63_q3.rkt)
;;
;; Run with:  racket tests/test_q3.rkt
;;
;; The solution file exports nothing, because the grader runs it by appending
;; its own calls to the end of the file.  These tests reproduce that exactly:
;; each case copies the solution source to a temporary file, appends the calls
;; under test, runs `racket` on the copy, and compares the captured stdout
;; byte for byte -- newlines included.  That makes the tests check the real
;; delivered artefact rather than some other way of loading it.
;;
;; The test harness itself is ordinary Racket; the whitelist in the assignment
;; constrains the solution files, not the tests.

(require racket/file
         racket/port
         racket/system
         racket/runtime-path)

(define-runtime-path solution-file "../code/63_q3.rkt")

(define racket-executable
  (let ([exec (find-system-path 'exec-file)])
    (or (and (absolute-path? exec) exec)
        (find-executable-path exec)
        (find-executable-path "racket"))))

;; run-grader-style : string -> string
;; The stdout produced by the solution file with `calls` appended to it.
(define (run-grader-style calls)
  (define temporary (make-temporary-file "popl63-q3-~a.rkt"))
  (display-to-file (string-append (file->string solution-file) "\n" calls "\n")
                   temporary
                   #:exists 'replace)
  (define output
    (with-output-to-string
      (lambda () (system* racket-executable temporary))))
  (delete-file temporary)
  output)

(define failures 0)

(define (check label calls expected)
  (define actual (run-grader-style calls))
  (cond
    [(equal? actual expected)
     (printf "ok    ~a\n" label)]
    [else
     (set! failures (add1 failures))
     (printf "FAIL  ~a\n      expected ~s\n      actual   ~s\n"
             label expected actual)]))

;; The three trees named in the assignment.
(define definitions
  (string-append
   "(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))\n"
   "(define t2 '(1 () (2 () (3 () ()))))\n"
   "(define t3 '(a (b () ()) (c () ())))\n"))

(define (with-trees calls) (string-append definitions calls))

;; ---------------------------------------------------------------------------
;; S1.a  --  print-inorder
;; ---------------------------------------------------------------------------

(check "print-inorder t1"
       (with-trees "(print-inorder t1)")
       "(1 2 3 4 5 6 7)\n")

(check "print-inorder t2"
       (with-trees "(print-inorder t2)")
       "(1 2 3)\n")

(check "print-inorder t3 (symbol values)"
       (with-trees "(print-inorder t3)")
       "(b a c)\n")

(check "print-inorder of the empty tree"
       "(print-inorder '())"
       "()\n")

(check "print-inorder of a single node"
       "(print-inorder '(9 () ()))"
       "(9)\n")

;; ---------------------------------------------------------------------------
;; S1.b  --  print-all-traversals
;; ---------------------------------------------------------------------------

(check "print-all-traversals t1"
       (with-trees "(print-all-traversals t1)")
       "(1 2 3 4 5 6 7)\n(4 2 1 3 6 5 7)\n(1 3 2 5 7 6 4)\n")

(check "print-all-traversals t2 (right spine)"
       (with-trees "(print-all-traversals t2)")
       "(1 2 3)\n(1 2 3)\n(3 2 1)\n")

(check "print-all-traversals t3"
       (with-trees "(print-all-traversals t3)")
       "(b a c)\n(a b c)\n(b c a)\n")

(check "print-all-traversals of the empty tree"
       "(print-all-traversals '())"
       "()\n()\n()\n")

(check "print-all-traversals of a left spine"
       "(print-all-traversals '(1 (2 (3 () ()) ()) ()))"
       "(3 2 1)\n(1 2 3)\n(3 2 1)\n")

;; ---------------------------------------------------------------------------
;; S1.c  --  print-height-and-leaves
;; ---------------------------------------------------------------------------

(check "print-height-and-leaves t1"
       (with-trees "(print-height-and-leaves t1)")
       "(3 4)\n")

(check "print-height-and-leaves t2"
       (with-trees "(print-height-and-leaves t2)")
       "(3 1)\n")

(check "print-height-and-leaves t3"
       (with-trees "(print-height-and-leaves t3)")
       "(2 2)\n")

(check "print-height-and-leaves of the empty tree"
       "(print-height-and-leaves '())"
       "(0 0)\n")

(check "a single node has height 1 and is one leaf"
       "(print-height-and-leaves '(9 () ()))"
       "(1 1)\n")

(check "an unbalanced tree takes the larger subtree height"
       "(print-height-and-leaves '(1 (2 (3 () ()) ()) (4 () ())))"
       "(3 2)\n")

;; ---------------------------------------------------------------------------
;; The file must be inert when merely loaded
;; ---------------------------------------------------------------------------

(check "loading the solution with no appended calls prints nothing"
       ""
       "")

;; ---------------------------------------------------------------------------
;; Scale: a deep tree must not exhaust the stack
;; ---------------------------------------------------------------------------

(check "a 5000-deep left spine"
       (string-append
        "(define (spine n) (if (= n 0) '() (list n (spine (- n 1)) '())))\n"
        "(print-height-and-leaves (spine 5000))")
       "(5000 1)\n")

;; ---------------------------------------------------------------------------

(printf "\n~a\n" (if (= failures 0)
                     "all S1 tests passed"
                     (format "~a S1 test(s) FAILED" failures)))
(exit (if (= failures 0) 0 1))
