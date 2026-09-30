def my-pair $ x $ y $ f : f x y
def my-fst $ p . p $ x $ y x
def my-snd $ p . p $ x $ y y

def foo-bar : my-pair ' foo ' bar

>> . print ' Closure:
if and : sym-eq? . my-fst foo-bar ' foo
       : sym-eq? . my-snd foo-bar ' bar
   . print ' Good
   . print ' Bad

