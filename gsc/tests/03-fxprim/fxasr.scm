(declare (extended-bindings) (not constant-fold) (not safe))

(define a 0)
(define b 536870911)
(define c -536870912)
(define d 1)
(define e -1)
(define f 357913941)

(define (test x)
  (println (##fxarithmetic-shift-right x 0))
  (println (##fxarithmetic-shift-right x 1))
  (println (##fxarithmetic-shift-right x 2))
  (println (##fxarithmetic-shift-right x 3))
  (println (##fxarithmetic-shift-right x 4)))

(test a)
(test b)
(test c)
(test d)
(test e)
(test f)
