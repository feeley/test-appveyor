;;;============================================================================

;;; File: "_back.scm"

;;; Copyright (c) 1994-2015 by Marc Feeley, All Rights Reserved.

(include "fixnum.scm")

(include-adt "_envadt.scm")
(include-adt "_gvmadt.scm")
(include-adt "_ptreeadt.scm")
(include-adt "_sourceadt.scm")

;;;----------------------------------------------------------------------------

;;;; Interface to back ends

;; This file defines the interface to all the target machine implementations.
;; Target machine implementations define (among other things):
;;
;;   - how Scheme objects are represented in the target machine
;;   - how GVM instructions are translated into target machine instructions
;;   - what is known about some of the Scheme primitives (e.g. which are
;;     defined, what their calling pattern is, which can be open-coded, etc.)
;;
;; When a given target machine module is loaded, a 'target' description
;; object is created and added to the list of available back ends (the
;; procedure 'target-add' should be used for this).
;;
;; Target description objects contain the following fields:
;;
;; field        value
;; -----        ------
;;
;; file-extensions  The file extensions for generated files (the first
;;                  is the preferred file extension).
;;
;; options      The options allowed for this target.
;;
;; begin!       Procedure (lambda (info-port) ...)
;;              This procedure must be called to initialize the module
;;              before any of the other fields are referenced.
;;              If 'info-port' is not #f, it is used to display
;;              user-related information.
;;
;; end!         Procedure (lambda () ...)
;;              This procedure must be called to do final 'cleanup'.
;;              References to the other fields in the module should thus
;;              happen inside calls to 'begin!' and 'end!'.
;;
;; dump         Procedure (lambda (procs output c-intf script-line
;;                                 options) ...)
;;              This procedure takes a list of 'procedure objects' and dumps
;;              the corresponding loader-compatible object file to the
;;              specified file.  The first procedure in 'procs', which must
;;              be a 0 argument procedure, will be called once when
;;              the program it is linked into is started up.  'options'
;;              is a list of back-end specific symbols passed by the
;;              front end of the compiler.  'c-intf' is a c-intf structure
;;              containing the C declarations, procedures, and initialization
;;              code contained in the source file.  It is the responsibility
;;              of the back-end (and loader) to create one Scheme primitive
;;              for each C procedure in the c-intf structure and to provide
;;              the linking between the two.  If the entries of the 'c-intf'
;;              structure are replaced with the empty list, the front-end
;;              will NOT produce the C interface file automatically as is
;;              normally the case (this is useful in the case of a back-end
;;              generating C that will itself be creating this file).
;;              The 'output' argument specifies the file name of the file
;;              to produce.  The 'script-line' argument indicates the text
;;              on the first line of the source file (after the #! or @;)
;;              if the source file is a script or #f if it is not a script.
;;
;; link-info    Procedure (lambda (file) ...)
;;              This procedure opens the file and extracts the linking meta
;;              data that is in the file.  If the file is not in the format
;;              generated by dump, #f is returned.
;;
;; link         Procedure (lambda (extension? inputs output warnings?) ...)
;;              Generates a link file from the list of linking meta data
;;              that was extracted from the files to link.
;;
;; nb-regs      Integer denoting the maximum number of GVM registers
;;              that should be used when generating GVM code for this
;;              target machine.
;;
;; prim-info    Procedure (lambda (name) ...)
;;              This procedure is used to get information about the
;;              Scheme primitive procedures built into the system (not
;;              necessarily standard procedures).  The procedure returns
;;              a 'procedure object' describing the named procedure if it
;;              exists and #f if it doesn't.
;;
;; label-info   Procedure (lambda (nb-parms nb-opts nb-keys rest? closed?) ...)
;;              This procedure returns information describing where
;;              parameters are located immediately following a procedure
;;              'label' instruction with the given parameters.  The locations
;;              can be registers or stack slots.
;;
;; jump-info    Procedure (lambda (nb-args) ...)
;;              This procedure returns information describing where
;;              arguments are expected to be immediately following a 'jump'
;;              instruction that passes 'nb-args' arguments.  The
;;              locations can be registers or stack slots.
;;
;; frame-constraints  Frame constraints structure
;;              The frame constraints structure indicates the frame alignment
;;              constraints.
;;
;; proc-result  GVM location.
;;              This value is the GVM register where the result of a
;;              procedure and task is returned.
;;
;; task-return  GVM location.
;;              This value is the GVM register where the task's return address
;;              is passed.
;;
;; switch-testable?  Function.
;;              This function tests whether an object can be tested
;;              in a GVM "switch" instruction.
;;
;; eq-testable?  Function.
;;              This function tests whether an object tested to another
;;              with eq? is equivalent to testing it with equal?.
;;
;; object-type  Function.
;;              This function returns a symbol indicating the type of its
;;              argument.  For exact integers the return value is
;;              either fixnum, bignum, or bigfixnum (when the integer
;;              could be a fixnum or bignum).

;;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;;;; Target description object manipulation

(define (make-target version name file-extensions options extra)

  (define current-target-version 11) ;; number for this version of the module

  (if (not (= version current-target-version))
      (compiler-internal-error
       "make-target, version of target module is not current" name))

  (let ((x (make-vector (+ 19 extra))))
    (vector-set! x 0 'target)
    (vector-set! x 1 name)
    (vector-set! x 2 file-extensions)
    (vector-set! x 3 options)
    x))

(define (target-name x)                     (vector-ref x 1))
(define (target-file-extensions x)          (vector-ref x 2))
(define (target-options x)                  (vector-ref x 3))

(define (target-begin! x)                   (vector-ref x 4))
(define (target-begin!-set! x y)            (vector-set! x 4 y))
(define (target-end! x)                     (vector-ref x 5))
(define (target-end!-set! x y)              (vector-set! x 5 y))

(define (target-dump x)                     (vector-ref x 6))
(define (target-dump-set! x y)              (vector-set! x 6 y))
(define (target-link-info x)                (vector-ref x 7))
(define (target-link-info-set! x y)         (vector-set! x 7 y))
(define (target-link x)                     (vector-ref x 8))
(define (target-link-set! x y)              (vector-set! x 8 y))
(define (target-nb-regs x)                  (vector-ref x 9))
(define (target-nb-regs-set! x y)           (vector-set! x 9 y))
(define (target-prim-info x)                (vector-ref x 10))
(define (target-prim-info-set! x y)         (vector-set! x 10 y))
(define (target-label-info x)               (vector-ref x 11))
(define (target-label-info-set! x y)        (vector-set! x 11 y))
(define (target-jump-info x)                (vector-ref x 12))
(define (target-jump-info-set! x y)         (vector-set! x 12 y))
(define (target-frame-constraints x)        (vector-ref x 13))
(define (target-frame-constraints-set! x y) (vector-set! x 13 y))
(define (target-proc-result x)              (vector-ref x 14))
(define (target-proc-result-set! x y)       (vector-set! x 14 y))
(define (target-task-return x)              (vector-ref x 15))
(define (target-task-return-set! x y)       (vector-set! x 15 y))
(define (target-switch-testable? x)         (vector-ref x 16))
(define (target-switch-testable?-set! x y)  (vector-set! x 16 y))
(define (target-eq-testable? x)             (vector-ref x 17))
(define (target-eq-testable?-set! x y)      (vector-set! x 17 y))
(define (target-object-type x)              (vector-ref x 18))
(define (target-object-type-set! x y)       (vector-set! x 18 y))

;;;; Frame constraints structure

(define (make-frame-constraints reserve align) (vector reserve align))
(define (frame-constraints-reserve fc)         (vector-ref fc 0))
(define (frame-constraints-align fc)           (vector-ref fc 1))

;;;; Database of all target modules loaded

(define targets-alist '())

(define (target-get name)
  (let ((x (assq name targets-alist)))
    (if x
        (cdr x)
        (compiler-error
         "Target module is not available:" name))))

(define (targets-loaded)
  (map cdr targets-alist))

(define (target-add targ)
  (let* ((name (target-name targ))
         (x (assq name targets-alist)))
    (if x
        (set-cdr! x targ)
        (set! targets-alist (cons (cons name targ) targets-alist)))
    #f))

(define (default-target)
  (if (null? targets-alist)
      (compiler-error "No target module is available")
      (car (car targets-alist))))

;;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;;;; Target machine selection

(define (target-select! name info-port)

  (set! target (target-get name))

  ((target-begin! target) info-port)

  (setup-prims target)

  (set! target.dump              (target-dump target))
  (set! target.nb-regs           (target-nb-regs target))
  (set! target.prim-info         (target-prim-info target))
  (set! target.label-info        (target-label-info target))
  (set! target.jump-info         (target-jump-info target))
  (set! target.frame-constraints (target-frame-constraints target))
  (set! target.proc-result       (target-proc-result target))
  (set! target.task-return       (target-task-return target))
  (set! target.switch-testable?  (target-switch-testable? target))
  (set! target.eq-testable?      (target-eq-testable? target))
  (set! target.object-type       (target-object-type target))
  (set! target.file-extensions   (target-file-extensions target))

  (set! **not-proc-obj
        (target.prim-info **not-sym))

  (set! **eq?-proc-obj
        (target.prim-info **eq?-sym))

  (set! **quasi-append-proc-obj
        (target.prim-info **quasi-append-sym))

  (set! **quasi-list-proc-obj
        (target.prim-info **quasi-list-sym))

  (set! **quasi-cons-proc-obj
        (target.prim-info **quasi-cons-sym))

  (set! **quasi-list->vector-proc-obj
        (target.prim-info **quasi-list->vector-sym))

  (set! **quasi-vector-proc-obj
        (target.prim-info **quasi-vector-sym))

  (set! **case-memv-proc-obj
        (target.prim-info **case-memv-sym))

  #f)

(define (target-unselect!)

  (set! **not-proc-obj                #f)
  (set! **eq?-proc-obj                #f)
  (set! **quasi-append-proc-obj       #f)
  (set! **quasi-list-proc-obj         #f)
  (set! **quasi-cons-proc-obj         #f)
  (set! **quasi-list->vector-proc-obj #f)
  (set! **quasi-vector-proc-obj       #f)
  (set! **case-memv-proc-obj          #f)

  ((target-end! target))

  #f)

(define target                   #f)
(define target.dump              #f)
(define target.nb-regs           #f)
(define target.prim-info         #f)
(define target.label-info        #f)
(define target.jump-info         #f)
(define target.frame-constraints #f)
(define target.proc-result       #f)
(define target.task-return       #f)
(define target.switch-testable?  #f)
(define target.eq-testable?      #f)
(define target.object-type       #f)
(define target.file-extensions   #f)

;; procedures defined in back-end:

(define **not-proc-obj                #f)  ;; ##not
(define **eq?-proc-obj                #f)  ;; ##eq?
(define **quasi-append-proc-obj       #f)  ;; ##quasi-append
(define **quasi-list-proc-obj         #f)  ;; ##quasi-list
(define **quasi-cons-proc-obj         #f)  ;; ##quasi-cons
(define **quasi-list->vector-proc-obj #f)  ;; ##quasi-list->vector
(define **quasi-vector-proc-obj       #f)  ;; ##quasi-vector
(define **case-memv-proc-obj          #f)  ;; ##case-memv

;;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;;;; Declarations relevant to back end

;; Arithmetic related declarations:
;;
;; (generic)                         all arithmetic is done on generic numbers
;; (generic <var1> ...)              apply only to primitives specified
;;
;; (fixnum)                          all arithmetic is done on fixnums
;; (fixnum <var1> ...)               apply only to primitives specified
;;
;; (flonum)                          all arithmetic is done on flonums
;; (flonum <var1> ...)               apply only to primitives specified
;;
;; (mostly-generic)                  generic arithmetic is frequent
;; (mostly-generic <var1> ...)       apply only to primitives specified
;;
;; (mostly-fixnum)                   fixnum arithmetic is frequent
;; (mostly-fixnum <var1> ...)        apply only to primitives specified
;;
;; (mostly-flonum)                   flonum arithmetic is frequent
;; (mostly-flonum <var1> ...)        apply only to primitives specified
;;
;; (mostly-fixnum-flonum)            fixnum and flonum arithmetic is frequent
;; (mostly-fixnum-flonum <var1> ...) apply only to primitives specified
;;
;; (mostly-flonum-fixnum)            flonum and fixnum arithmetic is frequent
;; (mostly-flonum-fixnum <var1> ...) apply only to primitives specified

(define-namable-decl generic-sym 'arith)
(define-namable-decl fixnum-sym  'arith)
(define-namable-decl flonum-sym  'arith)

(define (arith-implementation name env)
  (declaration-value 'arith name generic-sym env))

(define-namable-decl mostly-generic-sym       'mostly-arith)
(define-namable-decl mostly-fixnum-sym        'mostly-arith)
(define-namable-decl mostly-flonum-sym        'mostly-arith)
(define-namable-decl mostly-fixnum-flonum-sym 'mostly-arith)
(define-namable-decl mostly-flonum-fixnum-sym 'mostly-arith)

(define (mostly-arith-implementation name env)
  (declaration-value 'mostly-arith name mostly-fixnum-flonum-sym env))

;;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(define (link-modules extension? inputs output warnings?)
  (with-exception-handling
    (lambda ()
      (let* ((expanded-output
              (path-normalize output))
             (output-is-directory?
              (not (equal? expanded-output
                           (path-strip-trailing-directory-separator
                            expanded-output))))
             (rev-inputs
              (reverse inputs))
             (root
              (if output-is-directory?
                  (path-expand
                   (path-strip-directory
                    (string-append
                     (path-strip-extension (car (car rev-inputs)))
                     "_"))
                   expanded-output)
                  (path-strip-extension expanded-output)))
             (selected-target
              #f)
             (files-and-flags-and-link-infos
              (let loop ((lst rev-inputs) (result '()))
                (if (pair? lst)
                    (let* ((x (car lst))
                           (name (car x))
                           (flags (cdr x))
                           (y (get-link-info name selected-target)))
                      (if (not y)
                          (compiler-error
                           "missing or invalid linking information for module"
                           name)
                          (let* ((file (car y))
                                 (info (cadr y))
                                 (targ (caddr y)))
                            ;; ensure that all modules were generated
                            ;; with the same backend
                            (if (and selected-target
                                     (not (eq? selected-target targ)))
                                (compiler-error
                                 "modules to link were generated with different backends:"
                                 (target-name selected-target)
                                 "and"
                                 (target-name targ))
                                (begin
                                  (set! selected-target targ)
                                  (loop (cdr lst)
                                        (cons (list file flags info)
                                              result)))))))
                    result))))
        ((target-begin! selected-target) #f)
        (let* ((output-file
                (if output-is-directory?
                    (string-append
                     root
                     (caar (target-file-extensions selected-target)))
                    expanded-output))
               (result
                ((target-link selected-target)
                 extension?
                 files-and-flags-and-link-infos
                 output-file
                 warnings?)))
          ((target-end! selected-target))
          result)))))

(define (get-link-info name force-target)

  ;; name may be a filename or a module name (in which case the file
  ;; extension will automatically be added)

  (let ((ext (path-extension name)))
    (let loop1 ((targs
                 (if force-target
                     (list force-target)
                     (targets-loaded))))
      (if (pair? targs)
          (let* ((targ (car targs))
                 (allowed-extensions (target-file-extensions targ)))

            (define (got-link-info file info)
              (list file info targ))

            ((target-begin! targ) #f)
            (if (not (string=? ext ""))
                (if (not (assoc ext allowed-extensions))
                    (begin
                      ((target-end! targ))
                      (loop1 (cdr targs)))
                    (let ((info ((target-link-info targ) name)))
                      ((target-end! targ))
                      (if info
                          (got-link-info name info)
                          (loop1 (cdr targs)))))
                (let loop2 ((exts allowed-extensions))
                  (if (pair? exts)
                      (let* ((ext (car (car exts)))
                             (file (string-append name ext))
                             (info ((target-link-info targ) file)))
                        (if info
                            (begin
                              ((target-end! targ))
                              (got-link-info file info))
                            (loop2 (cdr exts))))
                      (begin
                        ((target-end! targ))
                        (loop1 (cdr targs)))))))
          #f))))

;;;============================================================================