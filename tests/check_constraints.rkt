#lang racket/base

;; tests/check_constraints.rkt
;;
;; A mechanical audit of the two Scheme solution files against the built-in
;; whitelist in the assignment.  Reading the source as s-expressions (rather
;; than grepping text) means comments are ignored for free and an identifier
;; is only ever seen as an identifier.
;;
;; Method: collect every symbol that occurs anywhere in the file, then subtract
;; the whitelist and every name the file itself binds (definitions, lambda
;; parameters, let/let*/letrec bindings and named-let loop names).  Whatever is
;; left is an identifier the file relies on but is not allowed to use.
;;
;; Run with:  racket tests/check_constraints.rkt

(require racket/runtime-path
         racket/list)

(define-runtime-path q3 "../code/63_q3.rkt")
(define-runtime-path q4 "../code/63_q4.rkt")

;; Every composition of car and cdr up to four letters, as the assignment allows.
(define car-cdr-compositions
  (for*/list ([n (in-range 1 5)]
              [combo (in-list (let build ([k n])
                                (if (= k 0)
                                    '(())
                                    (for*/list ([rest (in-list (build (- k 1)))]
                                                [letter (in-list '(a d))])
                                      (cons letter rest)))))])
    (string->symbol
     (apply string-append "c" (append (map symbol->string combo) (list "r"))))))

(define base-whitelist
  '(define lambda let let* letrec if cond else and or not begin quote
    cons car cdr list null? pair? eq? assq assoc
    + - * / < > <= >= = max display newline))

;; S2 additionally allows read.
(define (whitelist-for file)
  (append base-whitelist
          car-cdr-compositions
          (if (equal? file q4) '(read) '())))

;; read-forms : path -> (listof any)
;; The top-level forms of a #lang racket/base file, with the #lang line skipped.
(define (read-forms file)
  (with-input-from-file file
    (lambda ()
      (read-line) ; the #lang line
      (let loop ([acc '()])
        (define form (read))
        (if (eof-object? form)
            (reverse acc)
            (loop (cons form acc)))))))

;; all-symbols : any -> (listof symbol)
(define (all-symbols form)
  (cond [(symbol? form) (list form)]
        [(pair? form) (append (all-symbols (car form)) (all-symbols (cdr form)))]
        [else '()]))

;; binder-names : any -> (listof symbol)
;; Every name this form introduces: definitions, lambda parameters, let-style
;; bindings and named-let loop names, at any depth.
(define (binder-names form)
  (cond
    [(not (pair? form)) '()]
    [else
     (define head (car form))
     (define here
       (cond
         [(eq? head 'define)
          (define target (cadr form))
          (if (pair? target) (all-symbols target) (list target))]
         [(eq? head 'lambda)
          (all-symbols (cadr form))]
         [(memq head '(let let* letrec))
          (define second (cadr form))
          (if (symbol? second)
              ;; named let: the loop name plus its binding names
              (cons second (map car (caddr form)))
              (map car second))]
         [else '()]))
     (append here (append-map binder-names (filter pair? form)))]))

(define failures 0)

(define (audit file label)
  (define forms (read-forms file))
  (define allowed (append (whitelist-for file) (append-map binder-names forms)))
  (define used (remove-duplicates (append-map all-symbols forms)))
  (define offenders (filter (lambda (s) (not (memq s allowed))) used))
  (cond
    [(null? offenders)
     (printf "ok    ~a uses only whitelisted built-ins and its own definitions\n" label)]
    [else
     (set! failures (add1 failures))
     (printf "FAIL  ~a uses identifiers that are not allowed: ~a\n" label offenders)]))

(audit q3 "code/63_q3.rkt")
(audit q4 "code/63_q4.rkt")

(printf "~a\n" (if (= failures 0)
                   "Scheme whitelist audit passed"
                   (format "~a Scheme file(s) FAILED the whitelist audit" failures)))
(exit (if (= failures 0) 0 1))
