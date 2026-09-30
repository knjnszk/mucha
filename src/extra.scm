;;; Extra primitives
;;; Integer
(define (int? obj) (tagged? obj 'int))
(define (sym->int sym)
  (define (int-list? cs)
    (define (all lst) (foldl (lambda (x y) (and x y)) #t lst))
    (define (digit? c) (memq c (string->list "0123456789")))
    (and (pair? cs) (let ((cs (if (char=? (car cs) #\-) (cdr cs) cs)))
                      (and (pair? cs) (all (map digit? cs))))))
  (let ((str (symbol->string (sym-content sym))))
    (if (int-list? (string->list str))
      (make-int (string->number str))
      (err (list "Improper obj to convert to int" sym)))))
(define (int-content n) (cdr n))
(define (make-int n) (cons 'int n))
(define (int-compare f)
  (lambda (x y)
    (if (and (int? x) (int? y) (f (int-content x) (int-content y)))
      x
      unit)))
(define (int-op f)
  (lambda (x y) (if (and (int? x) (int? y))
                  (make-int (f (int-content x) (int-content y)))
                  unit)))
(define int-primitives
  (list (cons 'int? (make-pred int?))
        (cons 'int<sym (make-fn 1 sym->int))
        (cons 'int-eq? (make-fn 2 (int-compare =)))
        (cons 'int-geq? (make-fn 2 (int-compare >=)))
        (cons 'int-leq? (make-fn 2 (int-compare <=)))
        (cons 'int-gt? (make-fn 2 (int-compare >)))
        (cons 'int-lt? (make-fn 2 (int-compare <)))
        (cons 'int-add (make-fn 2 (int-op +)))
        (cons 'int-sub (make-fn 2 (int-op -)))
        (cons 'int-mul (make-fn 2 (int-op *)))
        (cons 'int-div (make-fn 2 (int-op /)))
        (cons 'int-mod (make-fn 2 (int-op modulo)))))

;;; String
(define (str? obj) (tagged? obj 'str))
(define (sym->str sym) (if (sym? sym)
                         (make-str (symbol->string (sym-content sym)))
                         (err (list "symbol expected " sym))))
(define (str->sym str) (if (str? str)
                         (make-sym (string->symbol (str-content str)))
                         (err (list "string expected " str))))
(define (int->str int) (if (int? int)
                         (make-str (number->string (int-content int)))
                         (err (list "integer expected " int))))
(define (str-content str) (cdr str))
(define (str-eq? x y)
  (if (and (str? x) (str? y) (string=? (str-content x) (str-content y))) x unit))
(define (str-length str) (if (str? str)
                           (make-int (string-length (str-content str)))
                           (err (list "string expected" str))))
(define (make-str str) (cons 'str str))
(define (str-ref str x)
  (if (and (str? str) (int? x))
    (let ((n (int-content x)))
      (if (or (>= n (int-content (str-length str))) (< n 0))
        (err (list "invalid index" str n))
        (make-str (list->string (list (string-ref (str-content str) n))))))
    (err (list "invalid type " str x))))
(define (str-join s t)
  (if (and (str? s) (str? t))
    (make-str (string-append (str-content s) (str-content t)))
    (err (list "not string " s t))))
(define str-primitives
  (list (cons 'str? (make-pred str?))
        (cons 'str<sym (make-fn 1 sym->str))
        (cons 'sym<str (make-fn 1 str->sym))
        (cons 'str<int (make-fn 1 int->str))
        (cons 'str-len (make-fn 1 str-length))
        (cons 'str-append (make-fn 2 str-join))
        (cons 'str-space (make-str " "))
        (cons 'str-esc (make-str "\x1b"))
        (cons 'str-empty (make-str ""))
        (cons 'str-tab (make-str "\t"))
        (cons 'str-newline (make-str "\n"))
        (cons 'str-eq? (make-fn 2 str-eq?))
        (cons 'str-ref (make-fn 2 str-ref))))

;;; Pair
(define (pair-obj? obj) (tagged? obj 'pair))
(define (make-pair x y) (cons 'pair (list x y)))
(define (pair-fst obj) (if (pair-obj? obj) (car (cdr obj)) (err (list "Not a pair:" obj))))
(define (pair-snd obj) (if (pair-obj? obj) (cadr (cdr obj)) (err (list "Not a pair:" obj))))
(define pair-primitives
  (list (cons 'pair? (make-pred pair-obj?))
        (cons 'pair (make-fn 2 make-pair))
        (cons 'fst (make-fn 1 pair-fst))
        (cons 'snd (make-fn 1 pair-snd))))

;;; Vector
(define (make-vec n x) (if (int? n)
                         (cons 'vec (make-vector (int-content n) x))
                         (err (list "integer required for vec:" n))))
(define (vec? obj) (tagged? obj 'vec))
(define (vec-content vec) (cdr vec))
(define (vec-length vec)
  (if (vec? vec)
    (vector-length (vec-content vec))
    (err (list "vector expected" vec))))
(define (vec-ref vec x)
  (if (and (vec? vec) (int? x))
    (let ((n (int-content x)))
      (if (or (< n 0) (>= n (vec-length vec)))
        (err (list "invalid index" vec n))
        (vector-ref (vec-content vec) n)))
    (err (list "invalid type" vec x))))
(define (vec-set! vec x val)
  (if (and (vec? vec) (int? x))
    (let ((n (int-content x)))
      (if (or (< n 0) (>= n (vec-length vec)))
        (err (list "invalid index" vec n))
        (begin
          (vector-set! (vec-content vec) n val)
          unit)))
    (err (list "invalid type" vec x))))
(define vec-primitives
  (list (cons 'vector (make-fn 2 make-vec))
        (cons 'vec? (make-pred vec?))
        (cons 'vec-len (make-fn 1 vec-length))
        (cons 'vec-ref (make-fn 2 vec-ref))
        (cons 'vec-set! (make-fn 3 vec-set!))))

;;; File IO
(import (chicken file posix)); for set-file-position!, file-size
(define (io-error name args) (err (cons name args)))
(define (str-write args)
  (let ((filename (car args))
        (offset (cadr args))
        (str (caddr args)))
    (if (not (and (sym? filename) (int? offset) (str? str)))
      (err (list "str-write: expected symbol integer string"
                 filename offset str))
      (let* ((path (symbol->string (sym-content filename)))
             (pos (int-content offset))
             (data (str-content str)))
        (cond ((< pos 0) (err (list "offset < 0" filename)))
              ((file-exists? path)
               (let ((size (file-size path)))
                 (if (> pos size)
                   (err (list "offset > filesize" filename))
                   (handle-exceptions
                     exn
                     (io-error "str-write:" (list filename offset str))
                     (let ((fd (file-open path (+ open/rdwr open/binary))))
                       (set-file-position! fd pos)
                       (file-write fd data)
                       (file-close fd)
                       unit)))))
              ((> pos 0) (err (list "offset > filesize" filename)))
              (else (handle-exceptions
                      exn
                      (io-error "str-write:" (list filename offset str))
                      (let ((fd (file-open path (+ open/rdwr open/creat open/binary))))
                        (file-write fd data)
                        (file-close fd)
                      unit))))))))
(define (str-read args)
  (let ((filename (car args))
        (offset (cadr args))
        (len (caddr args)))
    (if (not (and (sym? filename) (int? offset) (int? len)))
        (err (list "str-read: expected symbol integer integer"
                   filename offset len))
        (let* ((path (symbol->string (sym-content filename)))
               (pos (int-content offset))
               (n (int-content len)))
          (cond
            ((< pos 0)
             (err (list "str-read: offset < 0"
                        filename offset len)))
            ((< n 0)
             (err (list "str-read: len < 0"
                        filename offset len)))
            ((not (file-exists? path))
             (err (list "str-read: file not found"
                        filename)))
            (else
             (let ((size (file-size path)))
               (if (> (+ pos n) size)
                   (err (list "str-read: offset + len > filesize"
                              filename offset len))
                   (handle-exceptions exn
                     (io-error "str-read:" (list filename offset len))
                     (let ((port (open-input-file path #:binary)))
                       (set-file-position! port pos)
                       (let ((str (read-string n port)))
                         (close-input-port port)
                         (make-str str))))))))))))
(define (file-length args)
  (let ((filename (car args)))
    (if (sym? filename)
      (handle-exceptions exn
        (io-error "file-length:" (list filename))
        (make-int (file-size (symbol->string (sym-content filename)))))
      (err (list "file-length: expected symbol" filename)))))
(define (str-print args)
  (let ((str (car args)))
    (if (str? str)
      (begin (display (str-content str)) (flush-output) unit)
      (err (list "str-print: Not a string" str)))))
(define io-primitives
  (list (cons 'str-write (make-action 3 'str-write))
        (cons 'str-read (make-action 3 'str-read))
        (cons 'file-len (make-action 1 'file-length))
        (cons 'str-print (make-action 1 'str-print))
        (cons 'str-input (make-action 0 'str-input))
        (cons 'clear (make-action 0 'clear))
        (cons 'cursor-home (make-action 0 'cursor-home))
        (cons 'mucha-path (make-action 0 'mucha-path))))

;;; Add
(set! additional-actions
  (lambda (type args)
    (cond ((eq? type 'str-write) (str-write args))
          ((eq? type 'str-read) (str-read args))
          ((eq? type 'str-print) (str-print args))
          ((eq? type 'str-input) (make-str (read-line)))
          ((eq? type 'file-length) (file-length args))
          ((eq? type 'mucha-path) (mucha-path))
          (else (more-actions type args)))))
(define (more-actions type args) (err-unknown-action))

(register-gc-tracer!
  pair-obj?
  (lambda (obj visit) (visit (pair-fst obj)) (visit (pair-snd obj))))

(register-gc-tracer!
  vec?
  (lambda (obj visit)
    (let ((v (vec-content obj)))
      (let loop ((i 0))
        (if (< i (vector-length v))
          (begin (visit (vector-ref v i)) (loop (+ i 1))))))))

(set! primitives
  (append primitives
          int-primitives
          str-primitives
          pair-primitives
          vec-primitives
          io-primitives))

(define (run-prelude) (if (err? (run (from-mucha-path "boot/prelude.mch")))
                        (begin (display "Prelude not run") (newline))))
