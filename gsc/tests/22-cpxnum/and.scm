(declare (extended-bindings) (not constant-fold) (not safe))

(define s1 (##cpxnum-make 2 3))
(define s2 (##cpxnum-make -1 6))

(define (test2 x y)
  ;(println (and x y))
  (println (if (and x y) 11 22))
  ;(println (and (##not x) y))
  (println (if (and (##not x) y) 11 22))
  ;(println (and x (##not y)))
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
  (test2 x s1)
  (test2 x s2))

(test s1)
(test s2)
