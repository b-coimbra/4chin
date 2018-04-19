#lang racket

(require net/url
         html-parsing
         xml/path)

(define args (vector->list (current-command-line-arguments)))

(if (not (eq? (length args) 2))
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

(define (basename f)
  (string-append folder (last (regexp-split #rx"/" f))))

(define (download file)
  (if (not (file-exists? (basename file)))
      (call-with-output-file (basename file)
        (lambda (f) (display (port->bytes (get-pure-port (string->url (string-append "https:" file)))) f))
        #:exists 'replace)
      (void)))

(for ([elem (in-list (remove-duplicates xexpr))])
  (let ([in (list-ref (cdr elem) 0)])
    (if (regexp-match #rx"^//.*.(jpg|png)$" in)
        (begin
          (download in)
          (printf "\e[32m~a\e[0m -> ~a | ~a kb \n" folder in (file-size (basename in))))
        (void))))
