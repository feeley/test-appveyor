(declare (extended-bindings) (not constant-fold) (not safe))

(define (test x)
  (println (if x 11 22)))

(test 0)
(test 123)
