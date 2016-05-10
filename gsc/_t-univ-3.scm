;;============================================================================

;;; File: "_t-univ-3.scm"

;;; Copyright (c) 2011-2016 by Marc Feeley, All Rights Reserved.
;;; Copyright (c) 2012 by Eric Thivierge, All Rights Reserved.

(include "generic.scm")

(include-adt "_envadt.scm")
(include-adt "_gvmadt.scm")
(include-adt "_ptreeadt.scm")
(include-adt "_sourceadt.scm")
(include-adt "_univadt.scm")

;;----------------------------------------------------------------------------

(define (univ-defs fields methods classes inits all)
  (vector fields methods classes inits all))

(define (univ-defs-fields defs)  (vector-ref defs 0))
(define (univ-defs-methods defs) (vector-ref defs 1))
(define (univ-defs-classes defs) (vector-ref defs 2))
(define (univ-defs-inits defs)   (vector-ref defs 3))
(define (univ-defs-all defs)     (vector-ref defs 4))

(define (univ-make-empty-defs)
  (univ-defs '() '() '() '() '()))

(define (univ-add-field defs field)
  (univ-defs (cons field (univ-defs-fields defs))
             (univ-defs-methods defs)
             (univ-defs-classes defs)
             (univ-defs-inits defs)
             (cons field (univ-defs-all defs))))

(define (univ-add-method defs method)
  (univ-defs (univ-defs-fields defs)
             (cons method (univ-defs-methods defs))
             (univ-defs-classes defs)
             (univ-defs-inits defs)
             (cons method (univ-defs-all defs))))

(define (univ-add-class defs class)
  (univ-defs (univ-defs-fields defs)
             (univ-defs-methods defs)
             (cons class (univ-defs-classes defs))
             (univ-defs-inits defs)
             (cons class (univ-defs-all defs))))

(define (univ-add-init defs init)
  (univ-defs (univ-defs-fields defs)
             (univ-defs-methods defs)
             (univ-defs-classes defs)
             (cons init (univ-defs-inits defs))
             (cons init (univ-defs-all defs))))

(define (univ-defs-combine defs1 defs2)
  (univ-defs (append (univ-defs-fields defs2)
                     (univ-defs-fields defs1))
             (append (univ-defs-methods defs2)
                     (univ-defs-methods defs1))
             (append (univ-defs-classes defs2)
                     (univ-defs-classes defs1))
             (append (univ-defs-inits defs2)
                     (univ-defs-inits defs1))
             (append (univ-defs-all defs2)
                     (univ-defs-all defs1))))

(define (univ-defs-combine-list lst)
  (let loop ((lst lst) (defs (univ-make-empty-defs)))
    (if (pair? lst)
        (loop (cdr lst) (univ-defs-combine defs (car lst)))
        defs)))

(define (univ-def-kind x) (if (vector? x) (vector-ref x 0) 'init))

(define (univ-class
         root-name
         properties
         extends
         class-fields
         instance-fields
         class-methods
         instance-methods
         class-classes
         constructor
         inits)
  (vector 'class
          root-name
          properties
          extends
          class-fields
          instance-fields
          class-methods
          instance-methods
          class-classes
          constructor
          inits))

(define (univ-class-root-name class-descr)        (vector-ref class-descr 1))
(define (univ-class-properties class-descr)       (vector-ref class-descr 2))
(define (univ-class-extends class-descr)          (vector-ref class-descr 3))
(define (univ-class-class-fields class-descr)     (vector-ref class-descr 4))
(define (univ-class-instance-fields class-descr)  (vector-ref class-descr 5))
(define (univ-class-class-methods class-descr)    (vector-ref class-descr 6))
(define (univ-class-instance-methods class-descr) (vector-ref class-descr 7))
(define (univ-class-class-classes class-descr)    (vector-ref class-descr 8))
(define (univ-class-constructor class-descr)      (vector-ref class-descr 9))
(define (univ-class-inits class-descr)            (vector-ref class-descr 10))

(define (univ-method
         name
         properties
         result-type
         params
         #!optional
         (attribs '())
         (body #f))
  (vector 'method
          name
          properties
          result-type
          params
          attribs
          body))

(define (univ-method-name method-descr)        (vector-ref method-descr 1))
(define (univ-method-properties method-descr)  (vector-ref method-descr 2))
(define (univ-method-result-type method-descr) (vector-ref method-descr 3))
(define (univ-method-params method-descr)      (vector-ref method-descr 4))
(define (univ-method-attribs method-descr)     (vector-ref method-descr 5))
(define (univ-method-body method-descr)        (vector-ref method-descr 6))

(define (univ-method? x) (eq? (vector-ref x 0) 'method))

(define (univ-field name type #!optional (init #f) (properties '()))
  (vector 'field name properties type init))

(define (univ-field-name field-descr)       (vector-ref field-descr 1))
(define (univ-field-properties field-descr) (vector-ref field-descr 2))
(define (univ-field-type field-descr)       (vector-ref field-descr 3))
(define (univ-field-init field-descr)       (vector-ref field-descr 4))

(define (univ-field-inherited? field-descr)
  (memq 'inherited (univ-field-properties field-descr)))

(define (univ-decl-properties decl) (vector-ref decl 2))

(define (univ-emit-var-decl ctx var-descr)
  (case (target-name (ctx-target ctx))

    ((java)
     (^decl
      (univ-field-type var-descr)
      (univ-field-name var-descr)))

    (else
     (univ-field-name var-descr))))

(define (univ-rts-type-alias ctx type-name)
  (case type-name
    ((absent)        'Absent)
    ((bignum)        'Bignum)
    ((boolean)       'Boolean)
    ((box)           'Box)
    ((char)          'Char)
    ((chr)           'Chr)
    ((closure)       'Closure)
    ((continuation)  'Continuation)
    ((cpxnum)        'Cpxnum)
    ((ctrlpt)        'ControlPoint)
    ((entrypt)       'EntryPoint)
    ((eof)           'Eof)
    ((f64vector)     'F64Vector)
    ((fixnum)        'Fixnum)
    ((flonum)        'Flonum)
    ((frame)         'Frame)
    ((jumpable)      'Jumpable)
    ((key)           'Key)
    ((keyword)       'Keyword)
    ((modlinkinfo)   'ModLinkInfo)
    ((null)          'Null)
    ((optional)      'Optional)
    ((pair)          'Pair)
    ((parententrypt) 'ParentEntryPoint)
    ((promise)       'Promise)
    ((ratnum)        'Ratnum)
    ((rest)          'Rest)
    ((returnpt)      'ReturnPoint)
    ((scmobj)        'ScmObj)
    ((string)        'ScmString) ;; to avoid clashes with host's String class
    ((structure)     'Structure)
    ((symbol)        'Symbol)
    ((u16vector)     'U16Vector)
    ((u8vector)      'U8Vector)
    ((u32vector)     'U32Vector)
    ((u64vector)     'U64Vector)
    ((s8vector)      'S8Vector)
    ((s16vector)     'S16Vector)
    ((s32vector)     'S32Vector)
    ((s64vector)     'S64Vector)
    ((f32vector)     'F32Vector)
    ((unbound)       'Unbound)
    ((values)        'Values)
    ((vector)        'Vector)
    ((void)          'Void)
    ((will)          'Will)
    (else            #f)))

(define (univ-emit-decl ctx type name)

  (define (decl type)

    (define (base type-name)
      (if name
          (^ type-name " " name)
          type-name))

    (define (map-type type-name)
      (let ((x (univ-rts-type-alias ctx type-name)))
        ;;(pp (list 'xxxxxxxxxxxxxx x))
        (if x
            (begin
              (univ-use-rtlib ctx type-name)
              (if name
                  (tt"QQQ"(^rts-class-ref type-name))
                  (tt"RRR"(^rts-class-ref type-name))))
            type-name)))

    (case (target-name (ctx-target ctx))

      ((js php python ruby)
       (if name
           name
           (map-type type)))

      ((java)
       (cond ((and (pair? type) (eq? (car type) 'array))
              (^ (decl (cadr type)) "[]"))
             ((and (pair? type) (eq? (car type) 'dict))
              (base (^ "HashMap<"
                       (if (eq? (cadr type) 'int)
                           "Integer"
                           (^type (cadr type)))
                       ","
                       (^type (caddr type)) ">")))
             (else
              (case type
                ((frm)      (decl '(array scmobj)))
                ((noresult) (base 'void))
                ((int)      (base 'int))
                ((Int)      (base 'Integer))
                ((long)     (base 'long))
                ((chr)      (base 'char))
                ((u8)       (base 'byte))  ;;TODO byte is signed (-128..127)
                ((u16)      (base 'short)) ;;TODO short is signed
                ((u32)      (decl 'scmobj)) ;; fixnum or bignum
                ((u64)      (decl 'scmobj)) ;; fixnum or bignum
                ((s8)       (base 'byte))
                ((s16)      (base 'short))
                ((s32)      (decl 'scmobj)) ;; fixnum or bignum
                ((s64)      (decl 'scmobj)) ;; fixnum or bignum
                ((f32)      (base 'float))
                ((f64)      (base 'double))
                ((bool)     (base 'boolean))
                ((unicode)  (base 'int)) ;; Unicode needs 21 bit wide integers
                ((bigdigit) (base 'short))
                ((str)      (base 'String))
                ((object)   (base 'Object))
                (else       (base (map-type type)))))))

      (else
       (compiler-internal-error
        "univ-emit-decl, unknown target"))))

  (decl type))

(define (univ-emit-type ctx type)
  (univ-emit-decl ctx type #f))

(define (univ-emit-procedure-declaration
         ctx
         global?
         proc-type
         root-name
         params
         attribs
         body)
  (univ-emit-defs
   ctx
   (univ-jumpable-declaration-defs
    ctx
    global?
    root-name
    proc-type
    params
    attribs
    body)))

(define (univ-emit-defs ctx defs)

  (define (emit-method m)
    (univ-emit-function-declaration
     ctx
     #t
     (univ-method-name m)
     (univ-method-result-type m)
     (univ-method-params m)
     (univ-method-attribs m)
     (univ-method-body m)
     #t))

  (define (emit-class c)
    (univ-emit-class-declaration
     ctx
     (univ-class-root-name c)
     (univ-class-properties c)
     (univ-class-extends c)
     (univ-class-class-fields c)
     (univ-class-instance-fields c)
     (univ-class-class-methods c)
     (univ-class-instance-methods c)
     (univ-class-class-classes c)
     (univ-class-constructor c)
     (univ-class-inits c)))

  (define (emit-field f)
    (univ-emit-var-declaration
     ctx
     (univ-field-type f)
     (^global-var (^prefix (univ-field-name f)))
     (univ-field-init f)))

  (define (emit-init i)
    (i ctx))

  (let loop ((lst
              (if (eq? (target-name (ctx-target ctx)) 'java)
                  (append (reverse (univ-defs-classes defs))
                          (reverse (univ-defs-methods defs))
                          (reverse (univ-defs-fields defs))
                          (reverse (univ-defs-inits defs)))
                  (reverse (univ-defs-all defs))))
             (code
              (^)))
    (if (pair? lst)
        (let ((x (car lst)))
          (loop (cdr lst)
                (^ code
                   (case (univ-def-kind x)
                     ((class)  (emit-class x))
                     ((method) (emit-method x))
                     ((field)  (emit-field x))
                     ((init)   (emit-init x)))
                   "\n")))
        code)))

(define (univ-capitalize code)

  (define (cap-string str)
    (string-append (string (char-upcase (string-ref str 0)))
                   (substring str 1 (string-length str))))

  (cond ((string? code)
         (cap-string code))
        ((symbol? code)
         (cap-string (symbol->string code)))
        ((and (pair? code) (eq? (car code) univ-bb-prefix))
         (cons univ-capitalized-bb-prefix (cdr code)))
        (else
         (error "cannot capitalize" code))))

(define (univ-jumpable-declaration-defs
         ctx
         global?
         root-name
         jumpable-type
         params
         attribs
         body)
  (if (eq? (univ-procedure-representation ctx) 'class)

      (let ((capitalized-root-name
             (tt"BBB"(^prefix-class (univ-capitalize root-name)))))
        (univ-add-field

         (univ-add-class
          (univ-make-empty-defs)
          (univ-class
           capitalized-root-name ;; root-name
           '() ;; properties
           (and jumpable-type (^rts-class-use jumpable-type)) ;; extends
           '()   ;; class-fields
           attribs ;; instance-fields
           '()     ;; class-methods
           (list   ;; instance-methods
            (univ-method
             'jump
             '(public)
             'jumpable
             '()
             '()
             body))
           '() ;; class-classes
           #f ;; constructor
           '())) ;; inits

         (univ-field
          root-name
          capitalized-root-name
          (^new capitalized-root-name)
          '())))

      (univ-add-method
       (univ-make-empty-defs)
       (univ-method
        (^prefix root-name);;;;;;;;;;;;;;;;;;;;(^mod-method (ctx-module-name ctx) root-name)
        '()
        'jumpable
        params
        attribs
        body))))

(define (univ-emit-function-attribs ctx name attribs)
  (case (target-name (ctx-target ctx))

    ((js python)
     (if (null? attribs)
         (^)
         (^ "\n"
            (map (lambda (attrib)
                   (let* ((val* (univ-field-init attrib))
                          (val (if (procedure? val*)
                                   (val* ctx)
                                   val*)))
                     (^assign
                      (^member name (univ-field-name attrib))
                      val)))
                 attribs))))

    ((php)
     (if (null? attribs)
         (^)
         (^ "static "
            (univ-separated-list
             ", "
             (map (lambda (attrib)
                    (let* ((val* (univ-field-init attrib))
                           (val (if (procedure? val*)
                                    (val* ctx)
                                    val*)))
                      (^assign-expr
                       (^local-var (univ-field-name attrib))
                       val)))
                  attribs))
            "; ")))

    ((ruby)
     (if (null? attribs)
         (^)
         (^ "class << " name "; attr_accessor :" (univ-field-name (car attribs))
            (map (lambda (attrib)
                   (^ ", :" (univ-field-name attrib)))
                 (cdr attribs))
            "; end\n"
            (map (lambda (attrib)
                   (let* ((val* (univ-field-init attrib))
                          (val (if (procedure? val*)
                                   (val* ctx)
                                   val*)))
                     (^assign (^member name (univ-field-name attrib))
                              val)))
                 attribs))))

    ((java)
     (^))

    (else
     (compiler-internal-error
      "univ-emit-function-attribs, unknown target"))))

(define (univ-emit-function-declaration
         ctx
         global?
         root-name
         result-type
         params
         attribs
         body
         #!optional
         (prim? #f))
  (let* ((prn
          root-name)
         (name
          (if prim?
              prn
              (if global?
                  (^global-var prn)
                  (^local-var root-name)))))
    ;;(pp (list root-name prn));;;;;;;;;;;;;
    (case (target-name (ctx-target ctx))

      ((js)
       (^ (univ-emit-fn-decl ctx name result-type params body)
          (if (null? attribs)
              (^)
              (^ "\n"
                 (univ-emit-function-attribs ctx name attribs)))))

      ((php)
       (let ((decl
              (^ (univ-emit-fn-decl
                  ctx
                  (and (or prim? (univ-php-pre53? ctx))
                       prn)
                  result-type
                  params
                  (and body
                       (^ (if (and (not prim?)
                                   (univ-php-pre53? ctx))
                              (^)
                              (univ-emit-function-attribs ctx name attribs))
                          body)))
                 "\n")))
         (cond (prim?
                decl)
               ((univ-php-pre53? ctx)
                (^ decl
                   "\n"
                   (^assign name
                            (^ "create_function('"
                               (univ-separated-list
                                ","
                                (map (lambda (x)
                                       (^ (^local-var (univ-field-name x))
                                          (if (univ-field-init x) (^ "=" (^bool #f)) (^))))
                                     params))
                               "','"
                               (univ-emit-function-attribs ctx name attribs)
                               "return "
                               prn
                               "("
                               (univ-separated-list "," (map univ-field-name params))
                               ");')"))))
               (else
                (^assign name decl)))))

      ((python)
       (^ (univ-emit-fn-decl ctx name result-type params body)
          (if (null? attribs)
              (^)
              (^ "\n"
                 (univ-emit-function-attribs ctx name attribs)))))

      ((ruby)
       (^ (if prim?

              (^ (univ-emit-fn-decl ctx name result-type params body)
                 "\n")

              (let ((parameters
                     (univ-separated-list
                      ","
                      (map (lambda (x)
                             (^ (^local-var (univ-field-name x))
                                (if (univ-field-init x) (^ "=" (^bool #f)) (^))))
                           params))))
                (^assign
                 name
                 (univ-emit-fn-decl ctx #f result-type params body))))

          (univ-emit-function-attribs ctx name attribs)))

      ((java);;TODO adapt to Java
       (^ (univ-emit-fn-decl ctx name result-type params body)
          "\n"
          (univ-emit-function-attribs ctx name attribs)))

      (else
       (compiler-internal-error
        "univ-emit-function-declaration, unknown target")))))

(define (univ-emit-fn-decl ctx name result-type params body)
  (case (target-name (ctx-target ctx))

    ((js)
     (let ((formals
            (univ-separated-list
             ","
             (map univ-field-name params))))
       (^ "function " (or name "") "(" formals ") {"
          (if body
              (univ-indent body)
              "")
          "}")))

    ((php)
     (let ((formals
            (univ-separated-list
             ","
             (map (lambda (x)
                    (^ (^local-var (univ-field-name x))
                       (if (univ-field-init x) (^ "=" (^bool #f)) (^))))
                  params))))
       (^ "function " (or name "") "(" formals ")"
          (if body
              (^ " {"
                 (univ-indent body)
                 "}")
              ";"))))

    ((python)
     (let ((formals
            (univ-separated-list
             ","
             (map (lambda (x)
                    (^ (^local-var (univ-field-name x))
                       (if (univ-field-init x) (^ "=" (^bool #f)) (^))))
                  params))))
       (^ "def " name "(" formals "):"
          (univ-indent
           (or body
               "\npass\n")))))

    ((ruby)
     (let ((formals
            (univ-separated-list
             ","
             (map (lambda (x)
                    (^ (^local-var (univ-field-name x))
                       (if (univ-field-init x) (^ "=" (^bool #f)) (^))))
                  params))))
       (if name

           (^ "def " name (if (null? params) (^) (^ "(" formals ")"))
              (if body
                  (univ-indent body)
                  "\n")
              "end")

           (^ "lambda {" (if (null? params) (^) (^ "|" formals "|"))
              (if body
                  (univ-indent body)
                  "")
              "}"))))

    ((java)
     (let ((formals
            (univ-separated-list
             ","
             (map (lambda (var-descr)
                    (univ-emit-var-decl ctx var-descr))
                  params))))
       (^ (if result-type (^ (^type result-type) " ") (^))
          (or name "") "(" formals ")"
          (if body
              (^ " {"
                 (univ-indent body)
                 "}")
              ";"))))

    (else
     (compiler-internal-error
      "univ-emit-fn-decl, unknown target"))))

(define (univ-emit-fn-body ctx header gen-body)
  (and gen-body
       (univ-call-with-globals
        ctx
        gen-body
        (lambda (ctx body globals)
          (^ header globals body)))))

(define (univ-call-with-globals ctx gen cont)
  (with-new-resources-used
   ctx
   (lambda (ctx)

     (define (global-decl globals)
       (^ "global "
          (univ-separated-list
           ", "
           globals)))

     (let* ((result
             (gen ctx))
            (globals
             (if (eq? (univ-module-representation ctx) 'class)
                 '()
                 (let ((globals
                        (reverse (resource-set-stack (ctx-globals-used ctx)))))
#|
                   ;;TODO: remove
                   (define (used? x)
                     (or (resource-set-member? (ctx-resources-used-rd ctx) x)
                         (resource-set-member? (ctx-resources-used-wr ctx) x)))

                   (define (add! x)
                     (set! globals (cons x globals)))

                   (let loop ((num (- univ-nb-gvm-regs 1)))
                     (if (>= num 0)
                         (begin
                           (if (used? num) (add! (gvm-state-reg ctx num)))
                           (loop (- num 1)))))

                   (if (used? 'sp)        (add! (gvm-state-sp ctx)))
                   (if (used? 'stack)     (add! (gvm-state-stack ctx)))
                   (if (used? 'peps)      (add! (gvm-state-peps ctx)))
                   (if (used? 'glo)       (add! (gvm-state-glo ctx)))
                   (if (used? 'nargs)     (add! (gvm-state-nargs ctx)))
                   (if (used? 'pollcount) (add! (gvm-state-pollcount ctx)))
|#
                   globals))))
       (cont ctx
             result
             (if (null? globals)
                 (^)
                 (case (target-name (ctx-target ctx))
                   ((php)
                    (^ (global-decl globals) ";\n"))
                   ((python)
                    (^ (global-decl globals) "\n"))
                   (else
                    (^)))))))))

(define (univ-field-param ctx name)
  (if (eq? (target-name (ctx-target ctx)) 'java)
      (^ "_" name)
      name))

(define (univ-emit-class-declaration
         ctx
         root-name
         #!optional
         (properties #f)
         (extends #f)
         (class-fields '())
         (instance-fields '())
         (class-methods '())
         (instance-methods '())
         (class-classes '())
         (constructor #f)
         (inits '()))
  (let* ((name (tt"CCC"root-name)) ;; (^prefix-class root-name);;TODO: fix ^prefix
         (abstract? (memq 'abstract properties)))

    (define (qualifiers additional-properties decl)
      (let ((all (append additional-properties (univ-decl-properties decl))))
        (^ (case (target-name (ctx-target ctx))
             ((python)
              "")
             (else
              (if (memq 'public all) "public " "")))
           (case (target-name (ctx-target ctx))
             ((python)
              "")
             (else
              (if (memq 'static all) "static " "")))
           (case (target-name (ctx-target ctx))
             ((python)
              "")
             (else
              (if (and (univ-method? decl) (not (univ-method-body decl)))
                  "abstract "
                  "")))
           (if (memq 'classmethod all) "@classmethod\n" ""))))

    (define (field-decl type name init)
      (univ-emit-var-declaration ctx type name init))

    (define (except-this v)
      (case (target-name (ctx-target ctx))
        ((php) (if (eq? v (^this))
                   (^null)
                   v))
        (else v)))

    (define (qualified-field-decls additional-properties fields)
      (let ((fields
             (keep (lambda (x) (not (univ-field-inherited? x)))
                   fields)))
        (if (pair? fields)
            (^ "\n"
               (map (lambda (field)
                      (^ (qualifiers additional-properties field)
                         (field-decl (univ-field-type field)
                                     (^local-var (univ-field-name field))
                                     (except-this (univ-field-init field)))))
                    fields))
            (^))))

    (define (qualified-method-decls additional-properties methods)
      (map (lambda (method)
             (^ "\n"
                (qualifiers additional-properties method)
                (univ-emit-function-declaration
                 ctx
                 #t
                 (univ-method-name method)
                 (univ-method-result-type method)
                 (if (eq? (target-name (ctx-target ctx)) 'python)
                     (cons (univ-field (^this) 'object)
                           (univ-method-params method))
                     (univ-method-params method))
                 (univ-method-attribs method)
                 (univ-method-body method)
                 #t)
                (if (eq? (target-name (ctx-target ctx)) 'python)
                    "" ;; avoid repeated empty lines
                    "\n")))
           methods))

    (define (qualified-class-decls additional-properties classes)
      (map (lambda (class)
             (^ "\n"
                (qualifiers additional-properties class)
                (univ-emit-class-declaration
                 ctx
                 (univ-class-root-name class)
                 (univ-class-properties class)
                 (univ-class-extends class)
                 (univ-class-class-fields class)
                 (univ-class-instance-fields class)
                 (univ-class-class-methods class)
                 (univ-class-instance-methods class)
                 (univ-class-class-classes class)
                 (univ-class-constructor class)
                 (univ-class-inits class))))
           classes))

    (define (ruby-attr-accessors fields)
      (^ "\n"
         "attr_accessor " ;; allow read/write on all fields
         (univ-separated-list
          ","
          (map (lambda (field) (^ ":" (univ-field-name field)))
               fields))
         "\n"))

    (define (initless fields)
      (keep (lambda (field) (not (univ-field-init field)))
            fields))

    (define (gen-inits ctx inits)
      (if (null? inits)
          '()
          (^ "\n"
             (map (lambda (i) (i ctx)) inits))))

    (define (assign-field-decls obj fields)
      (map (lambda (field)
             (let* ((field-name (univ-field-name field))
                    (field-init (univ-field-init field))
                    (init (if (procedure? field-init)
                              (field-init ctx)
                              field-init)))
               (^assign (^member obj field-name)
                        (or init (^local-var (univ-field-param ctx field-name))))))
           fields))

    (define (js-class-declaration
             ctx
             obj
             name
             properties
             extends
             class-fields
             instance-fields
             class-methods
             instance-methods
             class-classes
             constructor
             inits)

      (define (assign-method-decls obj methods)
        (map (lambda (method)
               (^ "\n"
                  (^assign (^member obj (univ-method-name method))
                           (univ-emit-fn-decl
                            ctx
                            #f
                            (univ-method-result-type method)
                            (univ-method-params method)
                            (univ-method-body method)))
                  (univ-emit-function-attribs
                   ctx
                   (^member obj (univ-method-name method))
                   (univ-method-attribs method))))
             methods))

      (define (assign-class-decls obj classes)
        (map (lambda (class)
               (^ "\n"
                  (js-class-declaration
                   ctx
                   obj
                   (univ-class-root-name class)
                   (univ-class-properties class)
                   (univ-class-extends class)
                   (univ-class-class-fields class)
                   (univ-class-instance-fields class)
                   (univ-class-class-methods class)
                   (univ-class-instance-methods class)
                   (univ-class-class-classes class)
                   (univ-class-constructor class)
                   (univ-class-inits class))))
             classes))

      (define (fn-decl name)
        (univ-emit-fn-decl
         ctx
         name
         #f
         (initless instance-fields)
         (univ-emit-fn-body
          ctx
          "\n"
          (lambda (ctx)
            (if (or constructor
                    (not (null? instance-fields)))
                (^ (assign-field-decls (^this) instance-fields)
                   (if constructor (constructor ctx) (^)))
                (^))))))

      (let ((objname name)) ;;(if obj (^member obj name) name)))
        ;;(pp (list obj name objname))
        (^ (if obj
               (^assign objname (fn-decl #f))
               (^ (fn-decl name)
                  "\n"))

           (if extends
               (begin ;;(pp (list 'extends extends (^type extends)))
               (^ "\n"
                  (^assign (^member objname 'prototype)
                           (^call-prim (^member "Object" 'create)
                                       (^member (^type extends) 'prototype))))
               )
               (^))

           (assign-method-decls (^member objname 'prototype) instance-methods)

           (assign-class-decls objname class-classes)

           (assign-method-decls objname class-methods)

           (if (pair? class-fields)
               (^ "\n" (assign-field-decls objname class-fields))
               (^))

           (gen-inits ctx inits))))

    (case (target-name (ctx-target ctx))

      ((js)
       (js-class-declaration
        ctx
        #f
        root-name
        properties
        extends
        class-fields
        instance-fields
        class-methods
        instance-methods
        class-classes
        constructor
        inits))

      ((php)
       (let* ((c-classes
               (qualified-class-decls '() class-classes))
              (c-fields
               (qualified-field-decls '(static) class-fields))
              (i-fields
               (qualified-field-decls '() instance-fields))
              (all-fields
               (append c-fields i-fields))
              (constr
               (if (and (not abstract?)
                        (or constructor (not (null? instance-fields))))
                   (^ (univ-emit-fn-decl
                       ctx
                       name
                       #f
                       (map (lambda (field)
                              (univ-field
                               (univ-field-param ctx (univ-field-name field))
                               (univ-field-type field)
                               (univ-field-init field)
                               (univ-field-properties field)))
                            (initless instance-fields))
                       (univ-emit-fn-body
                        ctx
                        "\n"
                        (lambda (ctx)
                          (^ (assign-field-decls (^this) instance-fields)
                             (if constructor (constructor ctx) (^))))))
                      "\n")
                   '()))
              (c-methods
               (qualified-method-decls
                (if abstract? '(abstract static) '(static))
                class-methods))
              (i-methods
               (qualified-method-decls
                (if abstract? '(abstract) '())
                instance-methods))
              (all-methods
               (append constr
                       c-methods
                       i-methods))
              (c-inits
               (gen-inits ctx inits)))
         (^ c-classes
            (if abstract? "abstract " "") "class " name
            (if extends (^ " extends " (^type extends)) "")
            " {"
            (univ-indent
             (^ (if (and (null? all-fields)
                         (null? all-methods)
                         (null? c-inits))
                    ""
                    "\n")
                all-fields
                (if (null? all-methods)
                    ""
                    "\n")
                all-methods
                (if (null? c-inits)
                    (^)
                    (^ "static {"
                       (univ-indent c-inits)
                       "}\n"))))
            "}\n")))

      ((python)
       (let* ((c-classes
               (qualified-class-decls '(static) class-classes))
              (c-fields
               (qualified-field-decls '(static) class-fields))
              (c-methods
               (qualified-method-decls '(classmethod) class-methods))
              (i-methods
               (qualified-method-decls '() instance-methods))
              (c-inits
               (gen-inits ctx inits)))
         (^ "class " name
            (if extends (^ "(" (^type extends) ")") "")
            ":\n"
            (univ-indent
             (if (and (not abstract?)
                      (or constructor
                          (not (null? c-classes))
                          (not (null? c-fields))
                          (not (null? c-methods))
                          (not (null? instance-fields))
                          (not (null? i-methods))
                          (not (null? c-inits))))
                 (^ c-classes
                    c-fields
                    c-methods
                    (if (or constructor
                            (not (null? instance-fields)))
                        (^ "\n"
                           (univ-emit-fn-decl
                            ctx
                            "__init__"
                            #f
                            (cons (univ-field (^this) 'object)
                                  (initless instance-fields))
                            (univ-emit-fn-body
                             ctx
                             "\n"
                             (lambda (ctx)
                               (if (and (null? instance-fields) (not constructor))
                                   "pass\n"
                                   (^ (assign-field-decls (^this) instance-fields)
                                      (if constructor (constructor ctx) (^))))))))
                        (^))
                    i-methods)
                 "pass\n"))
            c-inits))) ;; class inits are outside of class definition in case there are self dependencies

      ((ruby)
       (^ "class " name
          (if extends (^ " < " (^type extends)) "")
          (univ-indent
           (if (or constructor
                   (not (null? class-fields))
                   (not (null? instance-fields))
                   (not (null? class-methods))
                   (not (null? instance-methods)))
               (^ "\n"
                  (if (or (not (null? class-fields))
                          (not (null? class-methods)))
                      (^ "\n"
                         "class << " (^this)
                         (univ-indent
                          (^ (ruby-attr-accessors class-fields)
                             (qualified-method-decls '() class-methods)))
                         "end\n"
                         "\n"
                         (assign-field-decls 'self-class class-fields))
                      (^))
                  (if (pair? instance-fields)
                      (ruby-attr-accessors instance-fields)
                      (^))
                  (if (or constructor
                          (not (null? instance-fields)))
                      (^ "\n"
                         "def initialize("
                         (univ-separated-list
                          ","
                          (map univ-field-name
                               (initless instance-fields)))
                         ")\n"
                         (univ-indent
                          (^ (assign-field-decls (^this) instance-fields)
                             (if constructor (constructor ctx) (^))))
                         "end\n")
                      (^))
                  (qualified-method-decls '() instance-methods))
               (^)))
          "\nend\n"))

      ((java)
       (let* ((c-classes
               (qualified-class-decls '(static) class-classes))
              (c-fields
               (qualified-field-decls '(static) class-fields))
              (i-fields
               (qualified-field-decls '() instance-fields))
              (all-fields
               (append c-fields i-fields))
              (constr
               (if (and (not abstract?)
                        (or constructor (not (null? instance-fields))))
                   (list "\n"
                         (univ-emit-fn-decl
                          ctx
                          name
                          #f
                          (map (lambda (field)
                                 (univ-field
                                  (univ-field-param ctx (univ-field-name field))
                                  (univ-field-type field)
                                  (univ-field-init field)
                                  (univ-field-properties field)))
                               (initless instance-fields))
                          (univ-emit-fn-body
                           ctx
                           "\n"
                           (lambda (ctx)
                             (^ (assign-field-decls (^this) instance-fields)
                                (if constructor (constructor ctx) (^))))))
                         "\n")
                   '()))
              (c-methods
               (qualified-method-decls
                (if abstract? '(abstract static) '(static))
                class-methods))
              (i-methods
               (qualified-method-decls
                (if abstract? '(abstract) '())
                instance-methods))
              (all-methods
               (append constr c-methods i-methods))
              (c-inits
               (gen-inits ctx inits)))
         (^ (if abstract? "abstract " "") "class " name
            (if extends (^ " extends " (^type extends)) "")
            " {"
            (univ-indent
             (^ (if (and (null? c-classes)
                         (or abstract?
                             (null? all-methods)))
                    ""
                    "\n")
                c-classes
                all-fields
                all-methods
                (if (null? c-inits)
                    (^)
                    (^ "static {"
                       (univ-indent c-inits)
                       "}\n"))))
            "}\n")))

      (else
       (compiler-internal-error
        "univ-emit-class-declaration, unknown target")))))

(define (univ-emit-comment ctx comment)
  (^ (univ-single-line-comment-prefix (target-name (ctx-target ctx)))
     " "
     comment))

(define (univ-single-line-comment-prefix targ-name)
  (case targ-name

    ((js php java)
     "//")

    ((python ruby)
     "#")

    (else
     (compiler-internal-error
      "univ-single-line-comment-prefix, unknown target"))))

(define (univ-emit-return-poll ctx expr poll? call?)

  (define (ret)
    (if (or call? (univ-always-return-jump? ctx))
        (^return-jump expr)
        (^return expr)))

  (univ-emit-poll-or-continue ctx expr poll? ret))

(define (univ-emit-poll-or-continue ctx expr poll? cont)
  (if poll?
      (^inc-by (gvm-state-pollcount-use ctx 'rdwr)
               -1
               (lambda (inc)
                 (^if (^= inc (^int 0))
                      (^return-call-prim
                       (^rts-method-use 'poll)
                       expr)
                      (cont))))
      (cont)))

(define (univ-emit-return-call-prim ctx expr . params)
  (^return
   (apply univ-emit-call-prim (cons ctx (cons expr params)))))

(define (univ-emit-return-jump ctx expr)
  (^return
   (if (not (univ-never-return-jump? ctx))
       (^jump (univ-unstringify-method expr))
       expr)))

(define (univ-emit-return ctx expr)
  (case (target-name (ctx-target ctx))

    ((js php java)
     (^ "return " expr ";\n"))

    ((python ruby)
     (^ "return " expr "\n"))

    (else
     (compiler-internal-error
      "univ-emit-return, unknown target"))))

(define (univ-emit-null ctx)
  (case (target-name (ctx-target ctx))

    ((js java)
     (univ-constant "null"))

    ((python)
     (univ-constant "None"))

    ((ruby)
     (univ-constant "nil"))

    ((php)
     (univ-constant "NULL"))

    (else
     (compiler-internal-error
      "univ-emit-null-ref, unknown target"))))

(define (univ-emit-null? ctx expr)
  (^eq? expr (^null)))

(define (univ-emit-null-obj ctx)
  (case (univ-null-representation ctx)

    ((class)
     (^rts-field-use 'null_obj))

    (else
     (^null))))

(define (univ-emit-null-obj? ctx expr)
  (case (univ-null-representation ctx)

    ((class)
     (^instanceof (^type 'null) expr))

    (else
     (^null? expr))))

(define (univ-emit-void ctx)
  (case (target-name (ctx-target ctx))

    ((js)
     (univ-constant "void 0")) ;; JavaScript's "undefined" value

    (else
     (^null))))

(define (univ-emit-void? ctx expr)
  (^eq? expr (^void)))

(define (univ-emit-void-obj ctx)
  (case (univ-void-representation ctx)

    ((class)
     (^rts-field-use 'void_obj))

    (else
     (^void))))

(define (univ-emit-str->string ctx expr)
  (^string-box (^str-to-codes expr)))

(define (univ-emit-string->str ctx expr)
  (case (univ-string-representation ctx)

    ((class)
     (^tostr  expr))

    ((host)
     expr)))

(define (univ-emit-void-obj? ctx expr)
  (case (univ-void-representation ctx)

    ((class)
     (^instanceof (^type 'void) expr))

    (else
     (case (target-name (ctx-target ctx))
      ((js) (^void? expr))
      (else (^null? expr))))))

(define (univ-emit-str? ctx expr)
  (case (target-name (ctx-target ctx))

    ((js)
     (^typeof "string" expr))

    ((php)
     (^call-prim "is_string" expr))

    ((python)
     (^instanceof "str" expr))

    ((ruby)
     (^instanceof "String" expr))

    (else
     (compiler-internal-error
       "univ-emit-str?, unknown target"))))

(define (univ-emit-float? ctx expr)
  (case (target-name (ctx-target ctx))

    ((js)
     (^typeof "number" expr))

    ((php)
     (^ "is_float(" expr ")"))

    ((python)
     (^ "isinstance(" expr ", float)"))

    ((ruby)
     (^ expr ".instance_of?(Float)"))

    (else
     (compiler-internal-error
       "univ-emit-float?, unknown target"))))

(define (univ-emit-int? ctx expr)
  (case (target-name (ctx-target ctx))

   ((js)
    (^typeof "number" expr))

   ((php)
    (^call-prim "is_int" expr))

   ((python)
    (^and (^instanceof "int" expr)
          (^not (^instanceof "bool" expr))))

   ((ruby)
    (^instanceof "Fixnum" expr))

   (else
    (compiler-internal-error
     "univ-emit-int?, unknown target"))))

(define (univ-emit-eof ctx)
  (case (univ-eof-representation ctx)

    ((class)
     (^rts-field-use 'eof_obj))

    (else
     (compiler-internal-error
      "univ-emit-eof, host representation not implemented"))))

(define (univ-emit-absent ctx)
  (case (univ-absent-representation ctx)

    ((class)
     (^rts-field-use 'absent_obj))

    (else
     (compiler-internal-error
      "univ-emit-absent, host representation not implemented"))))

(define (univ-emit-unbound1 ctx)
  (case (univ-unbound-representation ctx)

    ((class)
     (^rts-field-use 'unbound1_obj))

    (else
     (compiler-internal-error
      "univ-emit-unbound1, host representation not implemented"))))

(define (univ-emit-unbound2 ctx)
  (case (univ-unbound-representation ctx)

    ((class)
     (^rts-field-use 'unbound2_obj))

    (else
     (compiler-internal-error
      "univ-emit-unbound2, host representation not implemented"))))

(define (univ-emit-unbound? ctx expr)
  (case (univ-unbound-representation ctx)

    ((class)
     (^instanceof (^type 'unbound) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-unbound?, host representation not implemented"))))

(define (univ-emit-optional ctx)
  (case (univ-optional-representation ctx)

    ((class)
     (^rts-field-use 'optional_obj))

    (else
     (compiler-internal-error
      "univ-emit-optional, host representation not implemented"))))

(define (univ-emit-key ctx)
  (case (univ-key-representation ctx)

    ((class)
     (^rts-field-use 'key_obj))

    (else
     (compiler-internal-error
      "univ-emit-key, host representation not implemented"))))

(define (univ-emit-rest ctx)
  (case (univ-rest-representation ctx)

    ((class)
     (^rts-field-use 'rest_obj))

    (else
     (compiler-internal-error
      "univ-emit-rest, host representation not implemented"))))

(define (univ-emit-bool ctx val)
  (case (target-name (ctx-target ctx))

    ((js ruby php java)
     (univ-constant (if val "true" "false")))

    ((python)
     (univ-constant (if val "True" "False")))

    (else
     (compiler-internal-error
      "univ-emit-bool, unknown target"))))

(define (univ-emit-bool? ctx expr)
  (case (target-name (ctx-target ctx))

   ((js)
    (^typeof "boolean" expr))

   ((php)
    (^call-prim "is_bool" expr))

   ((python)
    (^instanceof "bool" expr))

   ((ruby)
    (^or (^instanceof "FalseClass" expr)
         (^instanceof "TrueClass" expr)))

   (else
    (compiler-internal-error
     "univ-emit-bool?, unknown target"))))

(define (univ-emit-boolean-obj ctx obj)
  (case (univ-boolean-representation ctx)

    ((class)
     (univ-box
      (^rts-field-use (if obj 'true_obj 'false_obj))
      (^bool obj)))

    (else
     (^bool obj))))

(define (univ-emit-boolean-box ctx expr)
  (case (univ-boolean-representation ctx)

    ((class)
     (univ-box
      (^if-expr expr
                (^boolean-obj #t)
                (^boolean-obj #f))
      expr))

    (else
     expr)))

(define (univ-emit-boolean-unbox ctx expr)
  (case (univ-boolean-representation ctx)

    ((class)
     (or (univ-unbox expr)
         (^member (^cast* 'boolean expr) 'val)))

    (else
     expr)))

(define (univ-emit-boolean? ctx expr)
  (case (univ-boolean-representation ctx)

    ((class)
     (^instanceof (^type 'boolean) (^cast*-scmobj expr)))

    (else
     (^bool? expr))))

(define (univ-emit-chr ctx val)
  (univ-constant (char->integer val)))

(define (univ-emit-char-obj ctx obj force-var?)
  (case (univ-char-representation ctx)

    ((class)
     (let ((x (^chr obj)))
       (univ-box
        (univ-obj-use
         ctx
         obj
         force-var?
         (lambda ()
           (^char-box x)))
        x)))

    (else
     (compiler-internal-error
      "univ-emit-char-obj, host representation not implemented"))))

(define (univ-emit-char-box ctx expr)
  (case (univ-char-representation ctx)

    ((class)
     (univ-box
      (^call-prim
       (^rts-method-use 'make_interned_char)
       expr)
      expr))

    (else
     (^char-box-uninterned expr))))

(define (univ-emit-char-box-uninterned ctx expr)
  (case (univ-char-representation ctx)

    ((class)
     (^new (^type 'char) expr))

    (else
     (compiler-internal-error
      "univ-emit-char-box-uninterned, host representation not implemented"))))

(define (univ-emit-char-unbox ctx expr)
  (case (univ-char-representation ctx)

    ((class)
     (or (univ-unbox expr)
         (^member (^cast* 'char expr) 'code)))

    (else
     (compiler-internal-error
      "univ-emit-char-unbox, host representation not implemented"))))

(define (univ-emit-chr-fromint ctx expr)
  (case (target-name (ctx-target ctx))

    ((js php python ruby)
     expr)

    ((java)
     (^cast* 'unicode expr))

    (else
     (compiler-internal-error
      "univ-emit-chr-fromint, unknown target"))))

(define (univ-emit-chr-toint ctx expr)
  (case (target-name (ctx-target ctx))

    ((js php python ruby)
     expr)

    ((java)
     (^cast* 'int expr))

    (else
     (compiler-internal-error
      "univ-emit-chr-toint, unknown target"))))

(define (univ-emit-chr-tostr ctx expr)
  (case (target-name (ctx-target ctx))

    ((js)
     (^call-prim (^member "String" 'fromCharCode) expr))

    ((php)
     (^call-prim "chr" expr))

    ((python)
     (^call-prim "unichr" expr))

    ((ruby)
     (^ expr ".chr"))

    ((java)
     (^call-prim (^member 'String 'valueOf) expr))

    (else
     (compiler-internal-error
      "univ-emit-chr-tostr, unknown target"))))

(define (univ-emit-char? ctx expr)
  (case (univ-char-representation ctx)

    ((class)
     (^instanceof (^type 'char) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-char?, host representation not implemented"))))

(define (univ-emit-int ctx val)
  (univ-constant val))

(define (univ-emit-fixnum-box ctx expr)
  (case (univ-fixnum-representation ctx)

    ((class)
     (univ-box
      (^call-prim
       (^rts-method-use 'make_fixnum)
       expr)
      expr))

    (else
     expr)))

(define (univ-emit-fixnum-unbox ctx expr)
  (case (univ-fixnum-representation ctx)

    ((class)
     (or (univ-unbox expr)
         (^member (^cast* 'fixnum expr) 'val)))

    (else
     expr)))

(define (univ-emit-fixnum? ctx expr)
  (case (univ-fixnum-representation ctx)

    ((class)
     (^instanceof (^type 'fixnum) (^cast*-scmobj expr)))

    (else
     (^int? expr))))

(define (univ-emit-empty-dict ctx type)
  (case (target-name (ctx-target ctx))

    ((js python ruby)
     (^ "{}"))

    ((php)
     (^ "array()"))

    ((java)
     (^new (^type type)))

    (else
     (compiler-internal-error
      "univ-emit-empty-dict, unknown target"))))

(define (univ-emit-dict ctx alist)

  (define (dict alist sep open close)
    (^ open
       (univ-separated-list
        ","
        (map (lambda (x) (^ (^str (car x)) sep (cdr x))) alist))
       close))

  (case (target-name (ctx-target ctx))

    ((js python)
     (dict alist ":" "{" "}"))

    ((php)
     (dict alist "=>" "array(" ")"))

    ((ruby)
     (dict alist "=>" "{" "}"))

    (else
     (compiler-internal-error
      "univ-emit-dict, unknown target"))))

(define (univ-emit-dict-key-exists? ctx expr1 expr2)
  (case (target-name (ctx-target ctx))

    ((js php python ruby)
     (^prop-index-exists? expr1 expr2))

    ((java)
     (^call-prim
      (^member expr1 'containsKey)
      expr2))

    (else
     (compiler-internal-error
      "univ-emit-dict-key-exists?, unknown target"))))

(define (univ-emit-dict-get ctx expr1 expr2 expr3)
  (case (target-name (ctx-target ctx))

    ((js php python ruby)
     (^prop-index expr1 expr2 expr3))

    ((java)
     (if (and expr3
              (not (equal? expr3 (^null))))
         (if (univ-java-pre7? ctx)
             (^if-expr (^dict-key-exists? expr1 expr2)
                       (^dict-get expr1 expr2)
                       expr3)
             (^call-prim (^member expr1 'getOrDefault) expr2 expr3))
         (^call-prim (^member expr1 'get) expr2)))

    (else
     (compiler-internal-error
      "univ-emit-dict-get, unknown target"))))

(define (univ-emit-dict-set ctx expr1 expr2 expr3)
  (case (target-name (ctx-target ctx))

    ((js php python ruby)
     (^assign (^prop-index expr1 expr2) expr3))

    ((java)
     (^expr-statement (^call-prim (^member expr1 'put) expr2 expr3)))

    (else
     (compiler-internal-error
      "univ-emit-dict-set, unknown target"))))

(define (univ-emit-member ctx expr name)
  (case (target-name (ctx-target ctx))

    ((js python)
     (^ expr "." name))

    ((php)
     (^ expr "->" name))

    ((ruby)
     (cond ((eq? expr (^this)) ;; optimize access to "self"
            (^ "@" name))
           ((eq? expr 'self-class) ;; for univ-emit-class-declaration
            (^ "@@" name))
           (else
            (^ expr "." name))))

    ((java)
     (cond ((eq? expr (^this)) ;; optimize access to "this"
            name)
           (else
            (^ expr "." name))))

    (else
     (compiler-internal-error
      "univ-emit-member, unknown target"))))

(define (univ-with-ctrlpt-attribs ctx assign? ctrlpt thunk)
  (case (univ-procedure-representation ctx)

    ((class)
     (thunk))

    (else
     (case (target-name (ctx-target ctx))

       ((js python ruby)
        (thunk))

       ((php)
        (let ((attribs-var
               (^ ctrlpt "_attribs"))
              (attribs-array
               (^ "new ReflectionFunction(" ctrlpt ")")))
          (^ (if assign?
                 (^assign attribs-var attribs-array)
                 (^var-declaration 'object attribs-var attribs-array))
             (^assign attribs-var (^ attribs-var "->getStaticVariables()"))
             (thunk))))

       (else
        (compiler-internal-error
         "univ-with-ctrlpt-attribs, unknown target"))))))

(define (univ-get-ctrlpt-attrib ctx ctrlpt attrib)
  (case (univ-procedure-representation ctx)

    ((class)
     (^member ctrlpt attrib))

    (else
     (case (target-name (ctx-target ctx))

       ((js python ruby)
        (^member ctrlpt attrib))

       ((php)
        (let ((attribs-var (^ ctrlpt "_attribs")))
          (^prop-index attribs-var (^str attrib))))

       (else
        (compiler-internal-error
         "univ-get-ctrlpt-attrib, unknown target"))))))

(define (univ-set-ctrlpt-attrib ctx ctrlpt attrib val)
  (case (univ-procedure-representation ctx)

    ((class)
     (^assign (^member ctrlpt attrib) val))

    (else
     (case (target-name (ctx-target ctx))

       ((js python ruby)
        (^assign (^member ctrlpt attrib) val))

       ((php)
        (let ((attribs-var (^ ctrlpt "_attribs")))
          (^assign (^prop-index attribs-var (^str attrib)) val)))

       (else
        (compiler-internal-error
         "univ-set-ctrlpt-attrib, unknown target"))))))

(define (univ-call-with-ctrlpt-attrib ctx expr type-name attrib return)
  (let ((ctrlpt (^local-var (univ-gensym ctx 'ctrlpt))))
    (^ (^var-declaration
        type-name
        ctrlpt
        (^cast* type-name expr))
       (univ-with-ctrlpt-attribs
        ctx
        #f
        ctrlpt
        (lambda ()
          (return
           (univ-get-ctrlpt-attrib ctx ctrlpt attrib)))))))

(define (univ-emit-pair? ctx expr)
  (^instanceof (^type 'pair) (^cast*-scmobj expr)))

(define (univ-emit-cons ctx expr1 expr2)
  (^new (^type 'pair) expr1 expr2))

(define (univ-emit-getcar ctx expr)
  (^member (^cast* 'pair expr) 'car))

(define (univ-emit-getcdr ctx expr)
  (^member (^cast* 'pair expr) 'cdr))

(define (univ-emit-setcar ctx expr1 expr2)
  (^assign (^member (^cast* 'pair expr1) 'car) expr2))

(define (univ-emit-setcdr ctx expr1 expr2)
  (^assign (^member (^cast* 'pair expr1) 'cdr) expr2))

(define (univ-emit-float ctx val)
  ;; TODO: generate correct syntax
  (univ-constant
   (let ((str (number->string val)))

     (cond ((string=? str "+nan.0")
            (case (target-name (ctx-target ctx))
              ((js)     "Number.NaN")
              ((java)   "Double.NaN")
              ((php)    "NAN")
              ((python) "float('nan')")
              ((ruby)   "Float::NAN")
              (else
               (compiler-internal-error
                "univ-emit-float, unknown target"))))

           ((string=? str "+inf.0")
            (case (target-name (ctx-target ctx))
              ((js)     "Number.POSITIVE_INFINITY")
              ((java)   "Double.POSITIVE_INFINITY")
              ((php)    "INF")
              ((python) "float('inf')")
              ((ruby)   "Float::INFINITY")
              (else
               (compiler-internal-error
                "univ-emit-float, unknown target"))))

           ((string=? str "-inf.0")
            (case (target-name (ctx-target ctx))
              ((js)     "Number.NEGATIVE_INFINITY")
              ((java)   "Double.NEGATIVE_INFINITY")
              ((php)    "(-INF)")
              ((python) "(-float('inf'))")
              ((ruby)   "(-Float::INFINITY)")
              (else
               (compiler-internal-error
                "univ-emit-float, unknown target"))))

           ((and (string=? str "-0.")
                 (eq? (target-name (ctx-target ctx)) 'php))
            ;; it is strange that in PHP -0.0 is the same as 0.0
            "(0.0*-1)")

           ((char=? (string-ref str 0) #\.)
            (string-append "0" str))

           ((and (char=? (string-ref str 0) #\-)
                 (char=? (string-ref str 1) #\.))
            (string-append "-0" (substring str 1 (string-length str))))

           ((char=? (string-ref str (- (string-length str) 1)) #\.)
            (string-append str "0"))

           (else
            str)))))

(define (univ-emit-float-fromint ctx expr)
  (case (target-name (ctx-target ctx))

    ((js)
     expr)

    ((php)
     (^ "(float)(" expr ")"))

    ((python)
     (^ "float(" expr ")"))

    ((ruby)
     (^ expr ".to_f"))

    ((java)
     (^cast* 'f64 expr))

    (else
     (compiler-internal-error
      "univ-emit-float-fromint, unknown target"))))

(define (univ-emit-float-toint ctx expr)
  (case (target-name (ctx-target ctx))

    ((js)
     (^float-truncate expr))

    ((php)
     (^ "(int)(" expr ")"))

    ((python)
     (^ "int(" expr ")"))

    ((ruby)
     (^ expr ".to_i"))

    ((java)
     (^cast* 'int expr))

    (else
     (compiler-internal-error
      "univ-emit-float-toint, unknown target"))))

(define (univ-emit-float-abs ctx expr)
  (case (target-name (ctx-target ctx))

    ((js java)
     (^ "Math.abs(" expr ")"))

    ((php)
     (^ "abs(" expr ")"))

    ((python)
     (^ "math.fabs(" expr ")"))

    ((ruby)
     (^ expr ".abs"))

    (else
     (compiler-internal-error
      "univ-emit-float-abs, unknown target"))))

(define (univ-emit-float-floor ctx expr)
  (case (target-name (ctx-target ctx))

    ((js java)
     (^ "Math.floor(" expr ")"))

    ((php)
     (^ "floor(" expr ")"))

    ((python)
     (^ "math.floor(" expr ")"))

    ((ruby)
     (^ expr ".floor"))

    (else
     (compiler-internal-error
      "univ-emit-float-floor, unknown target"))))

(define (univ-emit-float-ceiling ctx expr)
  (case (target-name (ctx-target ctx))

    ((js java)
     (^ "Math.ceil(" expr ")"))

    ((php)
     (^ "ceil(" expr ")"))

    ((python)
     (^ "math.ceil(" expr ")"))

    ((ruby)
     (^ expr ".ceil"))

    (else
     (compiler-internal-error
      "univ-emit-float-ceiling, unknown target"))))

(define (univ-emit-float-truncate ctx expr)
  (case (target-name (ctx-target ctx))

    ((js php java)
     (^if-expr (^< expr (^float targ-inexact-+0))
               (^float-ceiling expr)
               (^float-floor expr)))

    ((python)
     (^ "int(" expr ")"))

    ((ruby)
     (^ expr ".truncate"))

    (else
     (compiler-internal-error
      "univ-emit-float-truncate, unknown target"))))

(define (univ-emit-float-round-half-up ctx expr)
  (case (target-name (ctx-target ctx))

    ((js java)
     (^ "Math.round(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-round-half-up, unknown target"))))

(define (univ-emit-float-round-half-towards-0 ctx expr)
  (case (target-name (ctx-target ctx))

    ((php)
     (^ "round(" expr ")"))

    ((python)
     ;; python v2 rounds towards 0
     (^ "round(" expr ")"))

    ((ruby)
     (^ expr ".round"))

    (else
     (compiler-internal-error
      "univ-emit-float-round-half-towards-0, unknown target"))))

(define (univ-emit-float-round-half-to-even ctx expr)

  (define (use-round-half-up)
    (^- (^float-round-half-up expr)
        (^parens
         (^if-expr (^&& (^!= (^float-mod expr (^float targ-inexact-+2))
                             (^float targ-inexact-+1/2))
                        (^!= (^float-mod expr (^float targ-inexact-+2))
                             (^float -1.5))) ;;;;;;;;;;;;;;;;
                   (^float targ-inexact-+0)
                   (^float targ-inexact-+1)))))

  (define (use-round-half-towards-0)
    (^+ (^float-round-half-towards-0 expr)
        (^- (^parens
             (^if-expr (^= (^float-mod expr (^float targ-inexact-+2))
                           (^float (- targ-inexact-+1/2))) ;;;;;;;;;;;;;;;;;
                       (^float targ-inexact-+1)
                       (^float targ-inexact-+0)))
            (^parens
             (^if-expr (^= (^float-mod expr (^float targ-inexact-+2))
                           (^float targ-inexact-+1/2))
                       (^float targ-inexact-+1)
                       (^float targ-inexact-+0))))))

  (case (target-name (ctx-target ctx))

    ((js java)
     (use-round-half-up))

    ((php ruby)
     (use-round-half-towards-0))

    ((python)
     (if (univ-python-pre3? ctx)
         (use-round-half-towards-0)
         (^ "round(" expr ")")))
    (else
     (compiler-internal-error
      "univ-emit-float-round-half-to-even, unknown target"))))

#|
JS:
for (var i=-8; i<=8; i++) print(i*0.5," ",(i*0.5)%2," ",Math.round(i*0.5));
-4    0   -4
-3.5 -1.5 -3 -1
-3   -1   -3
-2.5 -0.5 -2
-2    0   -2
-1.5 -1.5 -1 -1
-1   -1   -1
-0.5 -0.5  0
0     0    0
0.5   0.5  1 -1
1     1    1
1.5   1.5  2
2     0    2
2.5   0.5  3 -1
3     1    3
3.5   1.5  4
4     0    4

PHP:
i*0.5, fmod(i*0.5,2), round(i*0.5)
-4    0   -4
-3.5 -1.5 -4
-3   -1   -3
-2.5 -0.5 -3 +1
-2    0   -2
-1.5 -1.5 -2
-1   -1   -1
-0.5 -0.5 -1 +1
0     0    0
0.5   0.5  1 -1
1     1    1
1.5   1.5  2
2     0    2
2.5   0.5  3 -1
3     1    3
3.5   1.5  4
4     0    4

Python:
for i in range(-8,8):
  print '%f %f %f' % ((i*0.5),math.fmod(i*0.5,2),round(i*0.5))
-4    0   -4
-3.5 -1.5 -4
-3   -1   -3
-2.5 -0.5 -3 +1
-2    0   -2
-1.5 -1.5 -2
-1   -1   -1
-0.5 -0.5 -1 +1
0     0    0
0.5   0.5  1 -1
1     1    1
1.5   1.5  2
2     0    2
2.5   0.5  3 -1
3     1    3
3.5   1.5  4
4     0    4

Ruby:
(-8..8).each {|i| puts (i*0.5),(i*0.5).remainder(2),(i*0.5).round}
-4.0 -0.0 -4
-3.5 -1.5 -4
-3.0 -1.0 -3
-2.5 -0.5 -3 +1
-2.0 -0.0 -2
-1.5 -1.5 -2
-1.0 -1.0 -1
-0.5 -0.5 -1 +1
 0.0  0.0  0
 0.5  0.5  1 -1
 1.0  1.0  1
 1.5  1.5  2
 2.0  0.0  2
 2.5  0.5  3 -1
 3.0  1.0  3
 3.5  1.5  4
 4.0  0.0  4
|#

(define (univ-emit-float-mod ctx expr1 expr2)
  (case (target-name (ctx-target ctx))

    ((js java)
     (^ expr1 " % " expr2))

    ((php)
     (^ "fmod(" expr1 "," expr2 ")"))

    ((python)
     (^ "math.fmod(" expr1 "," expr2 ")"))

    ((ruby)
     (^ expr1 ".remainder(" expr2 ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-fmod, unknown target"))))

(define (univ-emit-float-exp ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.exp(" expr ")"))

    ((php)
     (^ "exp(" expr ")"))

    ((python)
     (^ "math.exp(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-exp, unknown target"))))

(define (univ-emit-float-log ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.log(" expr ")"))

    ((php)
     (^ "log(" expr ")"))

    ((python)
     (^ "math.log(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-log, unknown target"))))

(define (univ-emit-float-sin ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.sin(" expr ")"))

    ((php)
     (^ "sin(" expr ")"))

    ((python)
     (^ "math.sin(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-sin, unknown target"))))

(define (univ-emit-float-cos ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.cos(" expr ")"))

    ((php)
     (^ "cos(" expr ")"))

    ((python)
     (^ "math.cos(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-cos, unknown target"))))

(define (univ-emit-float-tan ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.tan(" expr ")"))

    ((php)
     (^ "tan(" expr ")"))

    ((python)
     (^ "math.tan(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-tan, unknown target"))))

(define (univ-emit-float-asin ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.asin(" expr ")"))

    ((php)
     (^ "asin(" expr ")"))

    ((python)
     (^ "math.asin(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-asin, unknown target"))))

(define (univ-emit-float-acos ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.acos(" expr ")"))

    ((php)
     (^ "acos(" expr ")"))

    ((python)
     (^ "math.acos(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-acos, unknown target"))))

(define (univ-emit-float-atan ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.atan(" expr ")"))

    ((php)
     (^ "atan(" expr ")"))

    ((python)
     (^ "math.atan(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-atan, unknown target"))))

(define (univ-emit-float-atan2 ctx expr1 expr2)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.atan2(" expr1 "," expr2 ")"))

    ((php)
     (^ "atan2(" expr1 "," expr2 ")"))

    ((python)
     (^ "math.atan2(" expr1 "," expr2 ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-atan2, unknown target"))))

(define (univ-emit-float-expt ctx expr1 expr2)
  (case (target-name (ctx-target ctx))

    ((js java)
     (^ "Math.pow(" expr1 "," expr2 ")"))

    ((php)
     (^ "pow(" expr1 "," expr2 ")"))

    ((python)
     (^ "math.pow(" expr1 "," expr2 ")"))

    ((ruby)
     (^ expr1 " ** " expr2))

    (else
     (compiler-internal-error
      "univ-emit-float-expt, unknown target"))))

(define (univ-emit-float-sqrt ctx expr)
  (case (target-name (ctx-target ctx))

    ((js ruby java)
     (^ "Math.sqrt(" expr ")"))

    ((php)
     (^ "sqrt(" expr ")"))

    ((python)
     (^ "math.sqrt(" expr ")"))

    (else
     (compiler-internal-error
      "univ-emit-float-sqrt, unknown target"))))

#;
(
;; PHP Math functions
abs
acos
acosh
asin
asinh
atan2
atan
atanh
base_ convert
bindec
ceil
cos
cosh
decbin
dechex
decoct
deg2rad
exp
expm1
floor
fmod
getrandmax
hexdec
hypot
is_ finite
is_ infinite
is_ nan
lcg_ value
log10
log1p
log
max
min
mt_ getrandmax
mt_ rand
mt_ srand
octdec
pi
pow
rad2deg
rand
round
sin
sinh
sqrt
srand
tan
tanh
)

(define (univ-emit-float-integer? ctx expr)
  (^&& (^not (^parens (^float-infinite? expr)))
       (^= expr (^float-floor expr))))

(define (univ-emit-float-finite? ctx expr)
  (case (target-name (ctx-target ctx))

    ((php)
     (^call-prim "is_finite" expr))

    (else
     ;;TODO: move constants elsewhere
     (^&& (^>= expr (^float -1.7976931348623151e308))
          (^<= expr (^float 1.7976931348623151e308))))))

(define (univ-emit-float-infinite? ctx expr)
  (case (target-name (ctx-target ctx))

    ((php)
     (^call-prim "is_infinite" expr))

    (else
     ;;TODO: move constants elsewhere
     (^or (^< expr (^float -1.7976931348623151e308))
          (^> expr (^float 1.7976931348623151e308))))))

(define (univ-emit-float-nan? ctx expr)
  (case (target-name (ctx-target ctx))

    ((php)
     (^call-prim "is_nan" expr))

    (else
     (^!= expr expr))))

(define (univ-emit-flonum-box ctx expr)
  (case (univ-flonum-representation ctx)

    ((class)
     (univ-box
      (^new (^type 'flonum) expr)
      expr))

    (else
     expr)))

(define (univ-emit-flonum-unbox ctx expr)
  (case (univ-flonum-representation ctx)

    ((class)
     (or (univ-unbox expr)
         (^member (^cast* 'flonum expr) 'val)))

    (else
     expr)))

(define (univ-emit-flonum? ctx expr)
  (case (univ-flonum-representation ctx)

    ((class)
     (^instanceof (^type 'flonum) (^cast*-scmobj expr)))

    (else
     (^float? expr))))

(define (univ-emit-cpxnum-make ctx expr1 expr2)
  (^new (^type 'cpxnum) expr1 expr2))

(define (univ-emit-cpxnum? ctx expr)
  (^instanceof (^type 'cpxnum) (^cast*-scmobj expr)))

(define (univ-emit-ratnum-make ctx expr1 expr2)
  (^new (^type 'ratnum) expr1 expr2))

(define (univ-emit-ratnum? ctx expr)
  (^instanceof (^type 'ratnum) (^cast*-scmobj expr)))

(define (univ-emit-bignum ctx expr1)
  (^new (^type 'bignum) expr1))

(define (univ-emit-bignum? ctx expr)
  (^instanceof (^type 'bignum) (^cast*-scmobj expr)))

(define (univ-emit-bignum-digits ctx val)
  (^member (^cast* 'bignum val) 'digits))

(define (univ-emit-box? ctx expr)
  (^instanceof (^type 'box) (^cast*-scmobj expr)))

(define (univ-emit-box ctx expr)
  (^new (^type 'box) expr))

(define (univ-emit-unbox ctx expr)
  (^member (^cast* 'box expr) 'val))

(define (univ-emit-setbox ctx expr1 expr2)
  (^assign (^member expr1 'val) expr2))

(define (univ-emit-values-box ctx expr)
  (case (univ-values-representation ctx)

    ((class)
     (^new (^type 'values) expr))

    (else
     expr)))

(define (univ-emit-values-unbox ctx expr)
  (case (univ-values-representation ctx)

    ((class)
     (^member (^cast* 'values expr) 'vals))

    (else
     expr)))

(define (univ-emit-values? ctx expr)
  (case (univ-values-representation ctx)

    ((class)
     (^instanceof (^type 'values) (^cast*-scmobj expr)))

    (else
     (^array? expr))))

(define (univ-emit-values-length ctx expr)
  (^array-length (^values-unbox expr)))

(define (univ-emit-values-ref ctx expr1 expr2)
  (^array-index (^values-unbox expr1) expr2))

(define (univ-emit-values-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^values-unbox expr1) expr2) expr3))

(define (univ-emit-vector-box ctx expr)
  (case (univ-vector-representation ctx)

    ((class)
     (^new (^type 'vector) expr))

    (else
     expr)))

(define (univ-emit-vector-unbox ctx expr)
  (case (univ-vector-representation ctx)

    ((class)
     (^member (^cast* 'vector expr) 'elems))

    (else
     expr)))

(define (univ-emit-vector? ctx expr)
  (case (univ-vector-representation ctx)

    ((class)
     (^instanceof (^type 'vector) (^cast*-scmobj expr)))

    (else
     (^array? expr))))

(define (univ-emit-vector-length ctx expr)
  (^array-length (^vector-unbox expr)))

(define (univ-emit-vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^vector-unbox expr1) expr2))

(define (univ-emit-vector-ref ctx expr1 expr2)
  (^array-index (^vector-unbox expr1) expr2))

(define (univ-emit-vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^vector-unbox expr1) expr2) expr3))

(define (univ-emit-u8vector-box ctx expr)
  (case (univ-u8vector-representation ctx)

    ((class)
     (^new (^type 'u8vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-u8vector-box, host representation not implemented"))))

(define (univ-emit-u8vector-unbox ctx expr)
  (case (univ-u8vector-representation ctx)

    ((class)
     (^member (^cast* 'u8vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-u8vector-unbox, host representation not implemented"))))

(define (univ-emit-u8vector? ctx expr)
  (case (univ-u8vector-representation ctx)

    ((class)
     (^instanceof (^type 'u8vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-u8vector?, host representation not implemented"))))

(define (univ-emit-u8vector-length ctx expr)
  (^array-length (^u8vector-unbox expr)))

(define (univ-emit-u8vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^u8vector-unbox expr1) expr2))

(define (univ-emit-u8vector-ref ctx expr1 expr2)
  (let ((code (^array-index (^u8vector-unbox expr1) expr2)))
    (case (target-name (ctx-target ctx))
      ((java) (^parens (^bitand (^int #xff) code)))
      (else   code))))

(define (univ-emit-u8vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^u8vector-unbox expr1) expr2) expr3))

(define (univ-emit-u16vector-box ctx expr)
  (case (univ-u16vector-representation ctx)

    ((class)
     (^new (^type 'u16vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-u16vector-box, host representation not implemented"))))

(define (univ-emit-u16vector-unbox ctx expr)
  (case (univ-u16vector-representation ctx)

    ((class)
     (^member (^cast* 'u16vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-u16vector-unbox, host representation not implemented"))))

(define (univ-emit-u16vector? ctx expr)
  (case (univ-u16vector-representation ctx)

    ((class)
     (^instanceof (^type 'u16vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-u16vector?, host representation not implemented"))))

(define (univ-emit-u16vector-length ctx expr)
  (^array-length (^u16vector-unbox expr)))

(define (univ-emit-u16vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^u16vector-unbox expr1) expr2))

(define (univ-emit-u16vector-ref ctx expr1 expr2)
  (let ((code (^array-index (^u16vector-unbox expr1) expr2)))
    (case (target-name (ctx-target ctx))
      ((java) (^parens (^bitand (^int #xffff) code)))
      (else   code))))

(define (univ-emit-u16vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^u16vector-unbox expr1) expr2) expr3))

(define (univ-emit-u32vector-box ctx expr)
  (case (univ-u32vector-representation ctx)

    ((class)
     (^new (^type 'u32vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-u32vector-box, host representation not implemented"))))

(define (univ-emit-u32vector-unbox ctx expr)
  (case (univ-u32vector-representation ctx)

    ((class)
     (^member (^cast* 'u32vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-u32vector-unbox, host representation not implemented"))))

(define (univ-emit-u32vector? ctx expr)
  (case (univ-u32vector-representation ctx)

    ((class)
     (^instanceof (^type 'u32vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-u32vector?, host representation not implemented"))))

(define (univ-emit-u32vector-length ctx expr)
  (^array-length (^u32vector-unbox expr)))

(define (univ-emit-u32vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^u32vector-unbox expr1) expr2))

(define (univ-emit-u32vector-ref ctx expr1 expr2)
  (^array-index (^u32vector-unbox expr1) expr2))

(define (univ-emit-u32vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^u32vector-unbox expr1) expr2) expr3))

(define (univ-emit-u64vector-box ctx expr)
  (case (univ-u64vector-representation ctx)

    ((class)
     (^new (^type 'u64vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-u64vector-box, host representation not implemented"))))

(define (univ-emit-u64vector-unbox ctx expr)
  (case (univ-u64vector-representation ctx)

    ((class)
     (^member (^cast* 'u64vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-u64vector-unbox, host representation not implemented"))))

(define (univ-emit-u64vector? ctx expr)
  (case (univ-u64vector-representation ctx)

    ((class)
     (^instanceof (^type 'u64vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-u64vector?, host representation not implemented"))))

(define (univ-emit-u64vector-length ctx expr)
  (^array-length (^u64vector-unbox expr)))

(define (univ-emit-u64vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^u64vector-unbox expr1) expr2))

(define (univ-emit-u64vector-ref ctx expr1 expr2)
  (^array-index (^u64vector-unbox expr1) expr2))

(define (univ-emit-u64vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^u64vector-unbox expr1) expr2) expr3))

(define (univ-emit-s8vector-box ctx expr)
  (case (univ-s8vector-representation ctx)

    ((class)
     (^new (^type 's8vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-s8vector-box, host representation not implemented"))))

(define (univ-emit-s8vector-unbox ctx expr)
  (case (univ-s8vector-representation ctx)

    ((class)
     (^member (^cast* 's8vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-s8vector-unbox, host representation not implemented"))))

(define (univ-emit-s8vector? ctx expr)
  (case (univ-s8vector-representation ctx)

    ((class)
     (^instanceof (^type 's8vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-s8vector?, host representation not implemented"))))

(define (univ-emit-s8vector-length ctx expr)
  (^array-length (^s8vector-unbox expr)))

(define (univ-emit-s8vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^s8vector-unbox expr1) expr2))

(define (univ-emit-s8vector-ref ctx expr1 expr2)
  (^array-index (^s8vector-unbox expr1) expr2))

(define (univ-emit-s8vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^s8vector-unbox expr1) expr2) expr3))

(define (univ-emit-s16vector-box ctx expr)
  (case (univ-s16vector-representation ctx)

    ((class)
     (^new (^type 's16vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-s16vector-box, host representation not implemented"))))

(define (univ-emit-s16vector-unbox ctx expr)
  (case (univ-s16vector-representation ctx)

    ((class)
     (^member (^cast* 's16vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-s16vector-unbox, host representation not implemented"))))

(define (univ-emit-s16vector? ctx expr)
  (case (univ-s16vector-representation ctx)

    ((class)
     (^instanceof (^type 's16vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-s16vector?, host representation not implemented"))))

(define (univ-emit-s16vector-length ctx expr)
  (^array-length (^s16vector-unbox expr)))

(define (univ-emit-s16vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^s16vector-unbox expr1) expr2))

(define (univ-emit-s16vector-ref ctx expr1 expr2)
  (^array-index (^s16vector-unbox expr1) expr2))

(define (univ-emit-s16vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^s16vector-unbox expr1) expr2) expr3))

(define (univ-emit-s32vector-box ctx expr)
  (case (univ-s32vector-representation ctx)

    ((class)
     (^new (^type 's32vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-s32vector-box, host representation not implemented"))))

(define (univ-emit-s32vector-unbox ctx expr)
  (case (univ-s32vector-representation ctx)

    ((class)
     (^member (^cast* 's32vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-s32vector-unbox, host representation not implemented"))))

(define (univ-emit-s32vector? ctx expr)
  (case (univ-s32vector-representation ctx)

    ((class)
     (^instanceof (^type 's32vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-s32vector?, host representation not implemented"))))

(define (univ-emit-s32vector-length ctx expr)
  (^array-length (^s32vector-unbox expr)))

(define (univ-emit-s32vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^s32vector-unbox expr1) expr2))

(define (univ-emit-s32vector-ref ctx expr1 expr2)
  (^array-index (^s32vector-unbox expr1) expr2))

(define (univ-emit-s32vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^s32vector-unbox expr1) expr2) expr3))

(define (univ-emit-s64vector-box ctx expr)
  (case (univ-s64vector-representation ctx)

    ((class)
     (^new (^type 's64vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-s64vector-box, host representation not implemented"))))

(define (univ-emit-s64vector-unbox ctx expr)
  (case (univ-s64vector-representation ctx)

    ((class)
     (^member (^cast* 's64vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-s64vector-unbox, host representation not implemented"))))

(define (univ-emit-s64vector? ctx expr)
  (case (univ-s64vector-representation ctx)

    ((class)
     (^instanceof (^type 's64vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-s64vector?, host representation not implemented"))))

(define (univ-emit-s64vector-length ctx expr)
  (^array-length (^s64vector-unbox expr)))

(define (univ-emit-s64vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^s64vector-unbox expr1) expr2))

(define (univ-emit-s64vector-ref ctx expr1 expr2)
  (^array-index (^s64vector-unbox expr1) expr2))

(define (univ-emit-s64vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^s64vector-unbox expr1) expr2) expr3))

(define (univ-emit-f32vector-box ctx expr)
  (case (univ-f32vector-representation ctx)

    ((class)
     (^new (^type 'f32vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-f32vector-box, host representation not implemented"))))

(define (univ-emit-f32vector-unbox ctx expr)
  (case (univ-f32vector-representation ctx)

    ((class)
     (^member (^cast* 'f32vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-f32vector-unbox, host representation not implemented"))))

(define (univ-emit-f32vector? ctx expr)
  (case (univ-f32vector-representation ctx)

    ((class)
     (^instanceof (^type 'f32vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-f32vector?, host representation not implemented"))))

(define (univ-emit-f32vector-length ctx expr)
  (^array-length (^f32vector-unbox expr)))

(define (univ-emit-f32vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^f32vector-unbox expr1) expr2))

(define (univ-emit-f32vector-ref ctx expr1 expr2)
  (^array-index (^f32vector-unbox expr1) expr2))

(define (univ-emit-f32vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^f32vector-unbox expr1) expr2) expr3))


(define (univ-emit-f64vector-box ctx expr)
  (case (univ-f64vector-representation ctx)

    ((class)
     (^new (^type 'f64vector) expr))

    (else
     (compiler-internal-error
      "univ-emit-f64vector-box, host representation not implemented"))))

(define (univ-emit-f64vector-unbox ctx expr)
  (case (univ-f64vector-representation ctx)

    ((class)
     (^member (^cast* 'f64vector expr) 'elems))

    (else
     (compiler-internal-error
      "univ-emit-f64vector-unbox, host representation not implemented"))))

(define (univ-emit-f64vector? ctx expr)
  (case (univ-f64vector-representation ctx)

    ((class)
     (^instanceof (^type 'f64vector) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-f64vector?, host representation not implemented"))))

(define (univ-emit-f64vector-length ctx expr)
  (^array-length (^f64vector-unbox expr)))

(define (univ-emit-f64vector-shrink! ctx expr1 expr2)
  (^array-shrink! (^f64vector-unbox expr1) expr2))

(define (univ-emit-f64vector-ref ctx expr1 expr2)
  (^array-index (^f64vector-unbox expr1) expr2))

(define (univ-emit-f64vector-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^f64vector-unbox expr1) expr2) expr3))

(define (univ-emit-structure-box ctx expr)
  (case (univ-structure-representation ctx)

    ((class)
     (^new (^type 'structure) expr))

    (else
     (compiler-internal-error
      "univ-emit-structure-box, host representation not implemented"))))

(define (univ-emit-structure-unbox ctx expr)
  (case (univ-structure-representation ctx)

    ((class)
     (^member (^cast* 'structure expr) 'slots))

    (else
     (compiler-internal-error
      "univ-emit-structure-unbox, host representation not implemented"))))

(define (univ-emit-structure? ctx expr)
  (case (univ-structure-representation ctx)

    ((class)
     (^instanceof (^type 'structure) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-structure?, host representation not implemented"))))

(define (univ-emit-structure-ref ctx expr1 expr2)
  (^array-index (^structure-unbox expr1) expr2))

(define (univ-emit-structure-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (^structure-unbox expr1) expr2) expr3))

(define (univ-emit-str ctx val)
  (univ-constant
   (case (target-name (ctx-target ctx))

     ((js java)
      (cdr (univ-convert-string val #\" #\")))

     ((php)
      (let ((val-utf8
             (list->string
              (map integer->char
                   (u8vector->list
                    (call-with-output-u8vector
                     (list init: '#u8() char-encoding: 'UTF-8)
                     (lambda (port) (univ-display val port))))))))
        (cdr (univ-convert-string val-utf8 #\" #\$))))

     ((python)
      (let ((x (univ-convert-string val #\" #\")))
        (if (car x) (cons "u" (cdr x)) (cdr x))))

     ((ruby)
      (cdr (univ-convert-string val #\" #\#)))

     (else
      (compiler-internal-error
       "univ-emit-str, unknown target")))))

(define (univ-convert-string str delim special)
  (let ((unicode? #f))
    (let loop ((i 0) (j 0) (rev-chunks (list (string delim))))

      (define (done rev-chunks)
        (cons unicode? (reverse (cons (string delim) rev-chunks))))

      (define (add i j)
        (if (= i j)
            rev-chunks
            (cons (substring str i j) rev-chunks)))

      (if (= j (string-length str))
          (done (add i j))
          (let ((next-j (+ j 1))
                (c (string-ref str j)))
            (if (or (char=? c #\\)
                    (char=? c delim)
                    (char=? c special))
                (loop next-j
                      next-j
                      (cons (string #\\ c)
                            (add i j)))
                (let ((n (char->integer c)))
                  (cond ((< n #x100)
                         (if (or (< n 32) (>= n 127))
                             (let ((x (number->string (+ #x100 n) 16)))
                               (loop next-j
                                     next-j
                                     (cons (string-append "\\x"
                                                          (substring x 1 3))
                                           (add i j))))
                             (loop i
                                   (+ j 1)
                                   rev-chunks)))
                        ((< n #x10000)
                         (let ((x (number->string (+ #x10000 n) 16)))
                           (set! unicode? #t)
                           (loop next-j
                                 next-j
                                 (cons (string-append "\\u"
                                                      (substring x 1 5))
                                       (add i j)))))
                        (else
                         (let* ((hi (quotient (- n #x10000) #x400))
                                (lo (modulo n #x400))
                                (hi-x (number->string (+ #xd800 hi) 16))
                                (lo-x (number->string (+ #xdc00 lo) 16)))
                           (set! unicode? #t)
                           (loop next-j
                                 next-j
                                 (cons (string-append "\\u" hi-x "\\u" lo-x)
                                       (add i j)))))))))))))

(define (univ-emit-str-to-codes ctx str)
  (case (univ-string-representation ctx)

    ((class)
     (^call-prim
      (^rts-method-use 'str2codes)
      str))

    (else
     str)))

(define (univ-emit-str-length ctx str)
  (case (target-name (ctx-target ctx))

    ((js ruby)
     (^ str ".length"))

    ((php)
     (^ "strlen(" str ")"))

    ((python)
     (^ "len(" str ")"))

    ((java)
     (^ str ".length()"))

    (else
     (compiler-internal-error
      "univ-emit-str-length, unknown target"))))

(define (univ-emit-str-index-code ctx str i)
  (case (target-name (ctx-target ctx))

    ((js)
     (^call-prim (^member str 'charCodeAt) i))

    ((php)
     (^call-prim "ord" (^call-prim "substr" str i (^int 1))));;TODO fix for unicode characters

    ((python)
     (^call-prim "ord" (^ str "[" i "]")))

    ((ruby)
     (^ str "[" i "]" ".ord"))

    ((java)
     (^call-prim (^member str 'codePointAt) i))

    (else
     (compiler-internal-error
      "univ-emit-str-index-code, unknown target"))))

(define (univ-emit-string-obj ctx obj force-var?)
  (case (univ-string-representation ctx)

    ((class)
     (let ((x
            (^array-literal
             'unicode
             (map (lambda (c) (^int (char->integer c)))
                  (string->list obj)))))
       (univ-obj-use
        ctx
        obj
        force-var?
        (lambda ()
          (^string-box x)))))

    (else
     (^str obj))))

(define (univ-emit-string-box ctx expr)
  (case (univ-string-representation ctx)

    ((class)
     (^new (^type 'string) expr))

    (else
     expr)))

(define (univ-emit-string-unbox ctx expr)
  (case (univ-string-representation ctx)

    ((class)
     (^member (^cast* 'string expr) 'codes))

    (else
     expr)))

(define (univ-emit-string? ctx expr)
  (case (univ-string-representation ctx)

    ((class)
     (^instanceof (^type 'string) (^cast*-scmobj expr)))

    (else
     (^str? expr))))


(define (univ-emit-string-length ctx expr)
  (case (univ-string-representation ctx)

    ((class)
     (^array-length (^string-unbox expr)))

    (else
     (compiler-internal-error
      "univ-emit-string-length, unknown target"))))

(define (univ-emit-string-shrink! ctx expr1 expr2)
  (case (univ-string-representation ctx)

    ((class)
     (^array-shrink! (^string-unbox expr1) expr2))

    (else
     (compiler-internal-error
      "univ-emit-string-shrink!, host representation not implemented"))))

(define (univ-emit-string-ref ctx expr1 expr2)
  (case (univ-string-representation ctx)

    ((class)
     (^array-index expr1 expr2))

    (else
     (^str-index-code expr1 expr2))))

(define (univ-emit-string-set! ctx expr1 expr2 expr3)
  (case (univ-string-representation ctx)

    ((class)
     (^assign (^array-index expr1 expr2) expr3))

    (else
     ;; mutable strings do not exist in js, php, python and ruby
     (compiler-internal-error
      "univ-emit-string-set!, host representation not implemented"))))

(define (univ-emit-symbol-obj ctx obj force-var?)
  (case (univ-symbol-representation ctx)

    ((class)
     (let ((x (^str (symbol->string obj))))
       (univ-box
        (univ-obj-use
         ctx
         obj
         force-var?
         (lambda ()
           (^symbol-box x)))
        x)))

    (else
     (case (target-name (ctx-target ctx))

       ((js php python)
        (^str (symbol->string obj)))

       ((ruby)
        (univ-constant (^ ":" (^str (symbol->string obj)))))

       (else
        (compiler-internal-error
         "univ-emit-symbol-obj, unknown target"))))))

(define (univ-emit-symbol-box ctx name)
  (case (univ-symbol-representation ctx)

    ((class)
     (univ-box
      (^call-prim
       (^rts-method-use 'make_interned_symbol)
       name)
      name))

    (else
     (^symbol-box-uninterned name #f))))

(define (univ-emit-symbol-box-uninterned ctx name hash)
  (case (univ-symbol-representation ctx)

    ((class)
     (univ-box
      (^new (^type 'symbol) name hash)
      name))

    (else
     (case (target-name (ctx-target ctx))

       ((js php python)
        name)

       ((ruby)
        (^ name ".to_sym"))

       (else
        (compiler-internal-error
         "univ-emit-symbol-box-uninterned, unknown target"))))))

(define (univ-emit-symbol-unbox ctx expr)
  (case (univ-symbol-representation ctx)

    ((class)
     (or (univ-unbox expr)
         (^member (^cast* 'symbol expr) 'name)))

    (else
     (case (target-name (ctx-target ctx))

       ((js php python)
        expr)

       ((ruby)
        (^ expr ".to_s"))

       (else
        (compiler-internal-error
         "univ-emit-symbol-unbox, unknown target"))))))

(define (univ-emit-symbol? ctx expr)
  (case (univ-symbol-representation ctx)

    ((class)
     (^instanceof (^type 'symbol) (^cast*-scmobj expr)))

    (else
     (case (target-name (ctx-target ctx))

       ((js)
        (^typeof "string" expr))

       ((php)
        (^call-prim "is_string" expr))

       ((python)
        (^instanceof "str" expr))

       ((ruby)
        (^instanceof "Symbol" expr))

       (else
        (compiler-internal-error
         "univ-emit-symbol?, unknown target"))))))

(define (univ-emit-keyword-obj ctx obj force-var?)
  (case (univ-keyword-representation ctx)

    ((class)
     (let ((x (^str (keyword->string obj))))
       (univ-box
        (univ-obj-use
         ctx
         obj
         force-var?
         (lambda ()
           (^keyword-box x)))
        x)))

    (else
     (compiler-internal-error
      "univ-emit-keyword-box, host representation not implemented"))))

(define (univ-emit-keyword-box ctx name)
  (case (univ-keyword-representation ctx)

    ((class)
     (univ-box
      (^call-prim
       (^rts-method-use 'make_interned_keyword)
       name)
      name))

    (else
     (^keyword-box-uninterned name #f))))

(define (univ-emit-keyword-box-uninterned ctx name hash)
  (case (univ-keyword-representation ctx)

    ((class)
     (univ-box
      (^new (^type 'keyword) name hash)
      name))

    (else
     (case (target-name (ctx-target ctx))

       ((js php python)
        name)

       ((ruby)
        (^ name ".to_sym"))

       (else
        (compiler-internal-error
         "univ-emit-keyword-box-uninterned, unknown target"))))))

(define (univ-emit-keyword-unbox ctx expr)
  (case (univ-keyword-representation ctx)

    ((class)
     (or (univ-unbox expr)
         (^member (^cast* 'keyword expr) 'name)))

    (else
     (compiler-internal-error
      "univ-emit-keyword-unbox, host representation not implemented"))))

(define (univ-emit-keyword? ctx expr)
  (case (univ-keyword-representation ctx)

    ((class)
     (^instanceof (^type 'keyword) (^cast*-scmobj expr)))

    (else
     (compiler-internal-error
      "univ-emit-keyword?, host representation not implemented"))))

(define (univ-emit-frame-box ctx expr)
  (case (univ-frame-representation ctx)

    ((class)
     (univ-box
      (^new (^type 'frame) expr)
      expr))

    (else
     expr)))

(define (univ-emit-frame-unbox ctx expr)
  (case (univ-frame-representation ctx)

    ((class)
     (or (univ-unbox expr)
         (^member (^cast* 'frame expr)
                  'slots)))

    (else
     expr)))

(define (univ-emit-frame-slots ctx expr)
  (case (univ-frame-representation ctx)

    ((class)
     (or (univ-unbox expr)
         (^member expr
                  'slots)))

    (else
     expr)))

(define (univ-emit-frame? ctx expr)
  (case (univ-frame-representation ctx)

    ((class)
     (^instanceof (^type 'frame) (^cast*-scmobj expr)))

    (else
     (^array? expr))))

(define (univ-emit-new-continuation ctx expr1 expr2)
  (^new (^type 'continuation) expr1 expr2))

(define (univ-emit-continuation? ctx expr)
  (^instanceof (^type 'continuation) (^cast*-scmobj expr)))

(define (univ-emit-function? ctx expr)
  (case (target-name (ctx-target ctx))
   ((js)
    (^typeof "function" expr))

   ((php)
    (^call-prim "is_callable" expr))

   ((python)
    (^ "hasattr(" expr ", '__call__')"))

   ((ruby)
    (^instanceof "Proc" expr))

   (else
    (compiler-internal-error
       "univ-emit-function?, unknown target"))))

(define (univ-emit-procedure? ctx expr)
  (case (univ-procedure-representation ctx)

    ((class)
     ;; this accounts for procedure control-points and closures
     (^instanceof (^type 'jumpable) (^cast*-scmobj expr)))

    (else
     (^function? expr))))

(define (univ-emit-return? ctx expr)
  (case (univ-procedure-representation ctx)

    ((class)
     (^instanceof (^type 'returnpt) (^cast*-scmobj expr)))

    (else
     (^bool #f)))) ;;TODO: implement

(define (univ-emit-closure? ctx expr)
  (case (univ-procedure-representation ctx)

    ((class)
     (^instanceof (^type 'closure) (^cast*-scmobj expr)))

    (else
     (case (target-name (ctx-target ctx))

       ((js)
        (^not (^prop-index-exists? expr (^str "id"))))

       ((php)
        (^instanceof (^type 'closure) expr))

       ((python)
        (^not
         (^call-prim
          "hasattr"
          expr
          (^str "id"))))

       ((ruby)
        (^= (^ expr ".instance_variables.length") (^int 0)))

       (else
        (compiler-internal-error
         "univ-emit-closure?, unknown target"))))))

(define (univ-emit-closure-length ctx expr)
  (^array-length (univ-clo-slots ctx expr)))

(define (univ-emit-closure-code ctx expr)
  (^array-index (univ-clo-slots ctx expr) 0))

(define (univ-emit-closure-ref ctx expr1 expr2)
  (^array-index (univ-clo-slots ctx expr1) expr2))

(define (univ-emit-closure-set! ctx expr1 expr2 expr3)
  (^assign (^array-index (univ-clo-slots ctx expr1) expr2) expr3))

(define (univ-emit-new-promise ctx expr)
  (^new (^type 'promise) expr))

(define (univ-emit-promise? ctx expr)
  (^instanceof (^type 'promise) (^cast*-scmobj expr)))

(define (univ-emit-new-will ctx expr1 expr2)
  (^new (^type 'will) expr1 expr2))

(define (univ-emit-will? ctx expr)
  (^instanceof (^type 'will) (^cast*-scmobj expr)))

(define (univ-emit-call-prim ctx expr . params)
  (univ-emit-call-prim-aux ctx expr params))

(define (univ-emit-call-prim-aux ctx expr params)
  (if (and (null? params)
           (eq? (target-name (ctx-target ctx)) 'ruby))
      expr
      (univ-emit-apply-aux ctx expr params "(" ")")))

(define (univ-emit-jump ctx proc . params)
  (case (univ-procedure-representation ctx)

    ((class)
     (univ-emit-call-prim-aux ctx (^member proc 'jump) params))

    (else
     (univ-emit-call-aux ctx proc params))))

(define (univ-emit-call-aux ctx expr params)
  (if (eq? (target-name (ctx-target ctx)) 'ruby)
      (univ-emit-apply-aux ctx expr params "[" "]")
      (univ-emit-apply-aux ctx expr params "(" ")")))

(define (univ-emit-apply ctx expr params)
  (univ-emit-apply-aux ctx expr params "(" ")"))

(define (univ-emit-apply-aux ctx expr params open close)
  (^ expr
     open
     (univ-separated-list "," params)
     close))

(define (univ-emit-this ctx)
  (case (target-name (ctx-target ctx))

    ((js java)
     "this")

    ((php)
     "$this")

    ((python ruby)
     "self")

    (else
     (compiler-internal-error
      "univ-emit-this, unknown target"))))

(define (univ-emit-new ctx class . params)
  (case (target-name (ctx-target ctx))

    ((js php java)
     (^parens-php (^ "new " (^apply class params))))

    ((python)
     (^apply class params))

    ((ruby)
     (^apply (^ class ".new") params))

    (else
     (compiler-internal-error
      "univ-emit-new, unknown target"))))

(define (univ-emit-typeof ctx type expr)
  (case (target-name (ctx-target ctx))

    ((js)
     (^= (^ "typeof " expr) (^str type)))

    (else
     (compiler-internal-error
      "unit-emit-typeof, unknown target"))))

(define (univ-emit-instanceof ctx class expr)
  (case (target-name (ctx-target ctx))

    ((js java)
     (^ expr " instanceof " class))

    ((php)
     ;; PHP raises a syntax error when expr is a constant, so this case
     ;; is handled specially by generating (0?0:expr) which fools the compiler
     (^ (if (univ-box? expr)
            (^if-expr (^int 0) (^int 0) expr)
            expr)
        " instanceof "
        class))

    ((python)
     (^call-prim "isinstance" expr class))

    ((ruby)
     (^ expr ".kind_of?(" class ")"))

    (else
     (compiler-internal-error
      "unit-emit-instanceof, unknown target"))))

(define (univ-throw ctx expr)
  (case (target-name (ctx-target ctx))

    ((js php)
     (^ "throw " expr ";\n"))

    ((python)
     (^ "raise Exception(" expr ")\n"))

    ((ruby)
     (^ "raise " expr "\n"))

    (else
     (compiler-internal-error
      "univ-throw, unknown target"))))

(define (univ-fxquotient ctx expr1 expr2)
  (case (target-name (ctx-target ctx))

    ((js)
     (^ (^parens (^/ expr1 expr2)) " | 0"))

    ((php)
     (^float-toint (^/ expr1 expr2)))

    ((python ruby)
     (^float-toint (^/ (^float-fromint expr1) (^float-fromint expr2))))

    ((java)
     (^/ expr1 expr2))

    (else
     (compiler-internal-error
      "univ-fxquotient, unknown target"))))

(define (univ-fxmodulo ctx expr1 expr2)
  (case (target-name (ctx-target ctx))

    ((js php java)
     (^ (^parens (^ (^parens (^ expr1 " % " expr2)) " + " expr2)) " % " expr2))

    ((python ruby)
     (^ expr1 " % " expr2))

    (else
     (compiler-internal-error
      "univ-fxmodulo, unknown target"))))

(define (univ-fxremainder ctx expr1 expr2)
  (case (target-name (ctx-target ctx))

    ((js php java)
     (^ expr1 " % " expr2))

    ((python)
     (^- expr1
         (^* (^call-prim "int" (^/ (^call-prim "float" expr1)
                                   (^call-prim "float" expr2)))
             expr2)))

    ((ruby)
     (^ expr1 ".remainder(" expr2 ")"))

    (else
     (compiler-internal-error
      "univ-fxremainder, unknown target"))))

(define (univ-define-prim
         name
         proc-safe?
         apply-gen
         #!optional
         (ifjump-gen #f)
         (jump-gen #f))
  (let ((prim (univ-prim-info* (string->canonical-symbol name))))

    (if apply-gen
        (begin

          (proc-obj-inlinable?-set!
           prim
           (lambda (env)
             (or proc-safe?
                 (not (safe? env)))))

          (proc-obj-inline-set! prim apply-gen)))

    (if ifjump-gen
        (begin

          (proc-obj-testable?-set!
           prim
           (lambda (env)
             (or proc-safe?
                 (not (safe? env)))))

          (proc-obj-test-set! prim ifjump-gen)))

    (if jump-gen
        (begin

          (proc-obj-jump-inlinable?-set!
           prim
           (lambda (env)
             #t))

          (proc-obj-jump-inline-set!
           prim
           jump-gen)))))

(define (univ-define-prim-bool name proc-safe? ifjump-gen)
  (univ-define-prim
   name
   proc-safe?
   (lambda (ctx return . opnds)
     (apply ifjump-gen
            (cons ctx
                  (cons (lambda (result) (return (^boolean-box result)))
                        opnds))))
   ifjump-gen))

;; =============================================================================

;;; Primitive procedures

;; TODO move elsewhere
(define (univ-fold-left
         op0
         op1
         op2
         #!optional
         (unbox (lambda (ctx x) x))
         (box (lambda (ctx x) x)))
  (make-translated-operand-generator
   (lambda (ctx return . args)
     (return
      (cond ((null? args)
             (box ctx (op0 ctx)))
            ((null? (cdr args))
             (box ctx (op1 ctx (unbox ctx (car args)))))
            (else
             (let loop ((lst (cddr args))
                        (res (op2 ctx
                                  (unbox ctx (car args))
                                  (unbox ctx (cadr args)))))
               (if (null? lst)
                   (box ctx res)
                   (loop (cdr lst)
                         (op2 ctx
                              (^parens res)
                              (unbox ctx (car lst))))))))))))

(define (univ-fold-left-compare
         op0
         op1
         op2
         #!optional
         (unbox (lambda (ctx x) x))
         (box (lambda (ctx x) x)))
  (make-translated-operand-generator
   (lambda (ctx return . args)
     (return
      (cond ((null? args)
             (box ctx (op0 ctx)))
            ((null? (cdr args))
             (box ctx (op1 ctx (unbox ctx (car args)))))
            (else
             (let loop ((lst (cdr args))
                        (res (op2 ctx
                                  (unbox ctx (car args))
                                  (unbox ctx (cadr args)))))
               (let ((rest (cdr lst)))
                 (if (null? rest)
                     (box ctx res)
                     (loop rest
                           (^&& (^parens res)
                                (op2 ctx
                                     (unbox ctx (car lst))
                                     (unbox ctx (car rest))))))))))))))

(define (make-translated-operand-generator proc)
  (lambda (ctx return opnds)
    (apply proc (cons ctx (cons return (univ-emit-getopnds ctx opnds))))))

;;;============================================================================
