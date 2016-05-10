(declare (extended-bindings) (not constant-fold) (not safe))

(define a 3.125)
(define b -1.25)

(define (test2 x y)
  (println (and x y))
  (println (if (and x y) 11 22))
  (println (and (##not x) y))
  (println (if (and (##not x) y) 11 22))
  (println (and x (##not y)))
  (println (if (and x (##not y)) 11 22))
  (println (and (##not x) (##not y)))
  (println (if (and (##not x) (##not y)) 11 22))
  (println (##not (and x y)))
  (println (if (##not (and x y)) 11 22))
  (println (##not (and (##not x) y)))
  (println (if (##not (and (##not x) y)) 11 22))
  (println (##not (and x (##not y))))
  (println (if (##not (and x (##not y))) 11 22))
  (println (##not (and (##not x) (##not y))))
  (println (if (##not (and (##not x) (##not y))) 11 22)))

(define (test x)
  (test2 x a)
  (test2 x b))

(test a)
(test b)