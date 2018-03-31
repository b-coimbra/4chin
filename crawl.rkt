#lang racket

(require net/url
         html-parsing
         xml/path)

(define args (vector->list (current-command-line-arguments)))

(if (eq? '() args)
    (raise "USAGE: racket 4chin.rkt <url> <folder>")
    (void))

(define url (car args))
(define folder (string-append (cadr args) "/"))

(if (not (directory-exists? folder))
    (make-directory folder)
    (void))

(define (page-get url)
  (call/input-url (string->url url)
                  get-pure-port
                  html->xexp))

(define xexpr (se-path*/list '(a @) (caddr (page-get url))))

(define (append-element 1st elem)
  (foldr cons (list elem) 1st))

(define (download file)
  (call-with-output-file (string-append folder (last (regexp-split #rx"/" file)))
    (lambda (f) (display (port->bytes (get-pure-port (string->url (string-append "https:" file)))) f))
    #:exists 'replace))

(for ([elem (in-list xexpr)])
  (let ([in (list-ref (cdr elem) 0)])
    (if (regexp-match #rx"^//.*.(jpg|png)$" in)
        (begin
          (download in)
          (printf "\e[32m~a\e[0m -> ~a\n" folder in))
        (void))))
