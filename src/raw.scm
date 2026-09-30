(import 
  (chicken foreign)
  (chicken io)
  (chicken time)
  (chicken process-context))

  (foreign-declare "
                   #include <termios.h>
                   #include <unistd.h>
                   #include <string.h>
                   ")

(define (with-raw-mode thunk)
  (define tcgetattr
    (foreign-lambda int "tcgetattr" int (c-pointer "struct termios")))

  (define tcsetattr
    (foreign-lambda int "tcsetattr" int int (c-pointer "struct termios")))

  (define make-termios-struct
    (foreign-lambda (c-pointer "struct termios") "malloc" unsigned-long))

  (define free-termios
    (foreign-lambda void "free" (c-pointer "void")))

  (define cfmakeraw
    (foreign-lambda void "cfmakeraw" (c-pointer "struct termios")))

  (define STDIN 0)
  (define TCSANOW 0)

  (let* ((orig (make-termios-struct (foreign-value "sizeof(struct termios)" unsigned-long)))
         (raw  (make-termios-struct (foreign-value "sizeof(struct termios)" unsigned-long))))
    (dynamic-wind
      (lambda ()
        (tcgetattr STDIN orig)
        ((foreign-lambda void "memcpy"
                         (c-pointer "void")
                         (c-pointer "void")
                         unsigned-long)
         raw orig (foreign-value "sizeof(struct termios)" unsigned-long))
        (cfmakeraw raw)
        (tcsetattr STDIN TCSANOW raw))
      thunk
      (lambda ()
        (tcsetattr STDIN TCSANOW orig)
        (free-termios orig)
        (free-termios raw)))))

(define (read-char-raw)
  (with-raw-mode (lambda () (read-char (current-input-port)))))

(foreign-declare "#include <time.h>")
(define sleep-ms
  (foreign-lambda* void ((unsigned-int ms))
    "struct timespec ts;"
    "ts.tv_sec = ms / 1000;"
    "ts.tv_nsec = (ms % 1000) * 1000000;"
    "nanosleep(&ts, NULL);"))
(define (wait ms) (sleep-ms ms))
(define (current-ms) (current-process-milliseconds))

(define wait-event
  (let ((last-tick-ms #f))
    (lambda (interval-ms)
      (with-raw-mode
       (lambda ()
         (let* ((clock-ms 16)
                (now (current-ms)))
           (if (or (not last-tick-ms)
                   (>= now (+ last-tick-ms interval-ms)))
             (set! last-tick-ms now))
           (let ((deadline (+ last-tick-ms interval-ms)))
             (let loop ()
               (cond ((char-ready?)
                      (make-str (list->string (list (read-char)))))
                     ((>= (current-ms) deadline)
                      (set! last-tick-ms (current-ms)) unit)
                     (else (wait clock-ms) (loop)))))))))))
(define (wait-event-action args)
  (let ((interval-ms (car args)))
    (if (int? interval-ms)
      (wait-event (int-content interval-ms))
      (err (list "integer expected" interval-ms)))))


(define raw-primitives
  (list (cons 'wait-event (make-action 1 'wait-event))))

(set! more-actions
  (lambda (type args)
    (cond ((eq? type 'wait-event) (wait-event-action args))
          (else (err-unknown-action)))))

(set! primitives
  (append primitives
          raw-primitives))
