/* Bool */
def false []
def true ' true
def unit? $ p if p [] true
def not unit?

/* List */
def empty? unit?
def rst snd
def ] []

def list? $ lst if . empty? lst true
                and . pair? lst . list? . rst lst

def id $ x x
def comp $ g $ f $ x . g . f x
def flip $ f $ x $ y : f y x

def frst : comp fst rst
def frrst : comp frst rst
def frrrst : comp frrst rst

/* Higher-order functions */
def map $ f $ lst
  if . empty? lst
    lst
    : pair . f . fst lst : map f . rst lst

def foldl $ f $ ini $ lst
  if . empty? lst ini : f ini .: foldl f . fst lst . rst lst
def rev $ lst .: foldl . flip pair [] lst
def foldr $ f $ ini $ lst
  .: foldl . flip f ini . rev lst
def list-append $ x $ y
  .: foldl . flip pair y . rev x
def concat $ lst .: foldl list-append [] lst

def any? $ lst .: foldl $ x $ y  or x y false lst
def all? $ lst .: foldl $ x $ y and x y true lst

def memoize $ f
  def run? false
  def result []
  $ _ if run? result
       set result force f
       set run? true
       result

def add int-add
def sub int-sub
def mul int-mul
def div int-div
def mod int-mod
def both $ p $ x $ y and . p x . p y
def eq? $ x $ y
  if .: both sym? x y
    : sym-eq? x y
  if .: both int? x y
    : int-eq? x y
  if .: both str? x y
    : str-eq? x y
  []
def leq? int-leq?
def geq? int-geq?
def lt? int-lt?
def gt? int-gt?
def dec $ n
  if . int? n : int-sub n int 1
  []
def inc $ n
  if . int? n : int-add n int 1
  []

def fst+ $ s force . fst force s
def rst+ $ s force . rst force s

def map+ $ f $ s
  if . empty? s s
  { . f . fst+ s : map+ f . rst+ s
def zip+ $ lst
  if . any? : map empty? lst []
    { : map fst+ lst
       . zip+ : map rst+ lst

def stream-ref $ s $ n
  if or . not . int? n : lt? n int 0
    false
  if : int-eq? int 0 n
    . fst+ s
  : stream-ref . rst+ s . dec n

def list<-stream $ s $ n
  if : int-leq? n int 0
    []
    [ . fst+ s
      : list<-stream . rst+ s . dec n

def add+ $ s1 $ s2
  : map+ $ p : add . fst p . frst p
        . zip+ [ s1 [ s2 []

def ones { int 1 ones
def nat { int 0 : add+ nat ones
def fib { int 0 { int 1 : add+ fib . rst+ fib

def read-list
  >>= read $ s : s pair []

/* String */

def str<list $ lst
  .: foldl str-append str-empty lst
def list<str $ s
  def loop $ current
    if >= current . str-len s
      []
    [ : str-ref s current
      . loop . inc current
  . loop int 0
def str<sym' $ symbol
  . str<list . rst . list<str . str<sym symbol
/*
def string-w/esc $ symb
  let str . string symb
  let len . str-lengt str
  def loop $ s $ n
*/

def newline . str-print str-newline
def clear . str-print
  : str-append str-esc
  : str-append str [2J
  : str-append str-esc str [H
def cursor-home . str-print
  : str-append str-esc str [H
def append $ x $ y
  if .: both str?  x y : str-append  x y
  if .: both list? x y : list-append x y
  if .: both vec?  x y : vec-append  x y
  []

' loaded
