(declare (extended-bindings) (not constant-fold) (not safe))

(define v1 keyword1:)
(define v2 keyword2:)

(define (test2 x y)
  (println (##eq? x y))
  (println (if (##eq? x y) 11 22)))

(define (test x)
  (test2 x v1)
  (test2 x v2))

(test v1)
(test v2)
(test keyword1:)
