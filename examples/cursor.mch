def loop $ default-action $ q-action
  >>= . wait-event int 300 $ s
  if = str q s
    q-action
  >> . default-action s
  : loop default-action q-action

def str-create $ s $ n
  def loop $ n
    if = n int 0 []
    [ s . loop . dec n
  . str<list . loop n
def HEIGHT int 8
def WIDTH int 32
def hline ++ : str-create str-space int 2
          ++ : str-create str' '. WIDTH
                       : str-create str-space int 2
def end . str-print str Bye
def print-position $ x $ y
  def make-screen $ n
    if = n HEIGHT str-empty
    if = n y
      ++
        ++ : str-create str-space int 2
        ++ : str-create str' '. x
        ++ str @
        ++ : str-create str' '. - WIDTH + x int 1
        ++ : str-create str-space int 2
        str-newline
      . make-screen . inc n
    ++
      ++ hline str-newline
    . make-screen . inc n
  >> cursor-home
  >> newline
  . str-print . make-screen int 0

def main
  let x int 0
  let y int 0
  $ s
  let do print-position
  if = s str h set x : mod . dec x WIDTH  : do x y
  if = s str j set y : mod . inc y HEIGHT : do x y
  if = s str k set y : mod . dec y HEIGHT : do x y
  if = s str l set x : mod . inc x WIDTH  : do x y
  []
/*
and ; x
    ; y
    ; z
    ;;

and ;; | true
and ; x y | if x and y false

on s
  ; ; n a
  ; ; m b
  ;;

on s ;; | []
on s ; a b | helper s a on s b
helper s ; n a x | if = s n a x

*/

>> clear
: loop main end
