$ x body  | fn x body                  |
. f x     | ap f x                     |
' x       | sym x                      |
and x y   | let _ x if _ y _           |
or x y    | let _ x if _ _ y           |
let x v e | . $ x e v                  |
>>= x y   | : bind x y                 |
>> x y    | >>= x $ _ y                |
= x y     | : eq? x y                  |
[ x y     | : pair x y                 |
, x y     | [ x y                      |
str x     | . str<sym ' x              |
str' x    | . str<sym' ' x             |
int x     | . int<sym ' x              |
+ x y     | : add x y                  |
- x y     | : sub x y                  |
* x y     | : mul x y                  |
/ x y     | : div x y                  |
= x y     | : eq? x y                  |
< x y     | : lt? x y                  |
> x y     | : gt? x y                  |
<= x y    | : leq? x y                 |
>= x y    | : geq? x y                 |
++ x y    | : append x y               |
delay x   | . memoize $ _ x            |
force x   | . x []                     |
{ x y     | delay [ delay x delay y    |

  : f x y         | .  . f x y         |
 .: f x y z       | .  : f x y z       |
 :: f x y z w     | :  : f x y z w     |
.:: f x y z v w   | . :: f x y z v w   |
::: f x y z u v w | : :: f x y z u v w
