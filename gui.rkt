(require racket/gui/base)

(provide dialog)
(define dialog (instantiate dialog% ("4chin") [width 400]))

(provide url-field)
(define url-field (new text-field% [parent dialog] [label "URL: "]))

(define panel (new horizontal-panel% [parent dialog]
                   [alignment '(center center)]))

(new button% [parent panel]
     [label "Cancel"]
     [callback (lambda (button event)
                 (send dialog show #f))])

(define gauge (new gauge%
                   [label "% "]
                   [parent dialog]
                   [range 100]))

(provide url-given?)
(define url-given? null)

(new button% [parent panel]
     [label "Ok"]
     [callback (lambda (button event)
                 (begin
                   (send gauge set-value 100)
                   (set! url-given? #t)
                   (send dialog show #f)))])

(when (system-position-ok-before-cancel?)
  (send panel change-children reverse))
