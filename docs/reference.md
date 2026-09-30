# Mucha Reference

## Syntax

### Token Separation

Every syntactic object is separated with one or more separators.
Separators include not only whitespaces, but also linebreaks and tabs.
Hence, indentation is insignificant.

### Comment
Comment is specified as the internal region of the following:
```mucha
/* */
```
No nesting is allowed.

### Parsing

Parsing is driven by arities.
Arities of special forms and macros are used to convert the source code into AST.


## Special Forms

### Symbol: `sym` or `'`
```mucha
sym foo
' foo
```
Create a symbol object `foo`.

### Closure: `fn` or `$`
```mucha
fn x expr
$ x expr
```
Create a closure with the formal parameter `x` and the body expression `expr`.

### Application: `ap` or `.`
```mucha
ap f x
. f x
```
Apply the function `f` to the argument `x`.
Two- or three-fold application can be writen like this:
```mucha
ap ap f x y
: f x y

ap ap ap f x y z
.: f x y z
```

### Unit: `[]`
```mucha
[]
```
Unit object. Used as the only false value.

### Conditional: `if`
```mucha
if p x y
```
If `p` is `[]` then evaluate `y`.
Otherwise, evaluate `x`.

### Definition: `def`
```mucha
def x ' foo expr
```
Add binding `(x . ' foo)` and evaluate succeeding expression `expr`.

### Mutation: `set`
```mucha
set x ' bar expr
```
Update binding value of `x` to `' bar`.
If there is no binding of `x`, produce error.


## Macro

Macros are defined in `macros.mch`.
Syntax is the following:

```mucha
and x y | if x y [] |
or x y | if x x y
```
Each block is separated by `|`.
First block specifies macro syntax, while the next block specify into which the macro is expanded.
Multiple definition of macros are also separated with `|`.

## Primitive functions
### Styles of function name

- `type-function`, e.g. `str-len`.
- `type2<type1`; For conversion, e.g. `str<int`.
- `fulltypename`; Type constructor, e.g. `string`.
- `pred?`; Predicate. Return either `[]` or another value, e.g. `int?`.
- `destructive!`; Destructive operation. Often used with `set`, e.g. `vec-set!`.
- `verb-noun`; General name, e.g. `wait-event`

### Types

    unit
    proc
    sym
    int
    str
    pair
    vec
    list
    strm
    file

### Functions

    /* IO */
    input
    print
    read
    write

    /* Equality */
    eq?
    neq?

    /* Data structure */
    set!

    /* Comparator */
    geq?
    leq?
    gt?
    lt?

    /* Arithmetics */
    add
    sub
    mul
    div
    mod

    /* List-like */
    len
    append
    map
    concat

    /* Misc */
    bind
    join
    transpose


## List of all primitives

    proc?
    act?
    sym?
    //*
    *//
    sym-eq?
    bind
    input
    run
    read
    print
    write
    int?
    integer
    int-eq?
    int-geq?
    int-leq?
    int-gt?
    int-lt?
    int-add
    int-sub
    int-mul
    int-div
    int-mod
    str?
    string
    str->sym
    str-len
    str-append
    str-space
    str-tab
    str-newline
    str-eq?
    str-ref
    pair?
    pair
    fst
    snd
    vector
    vec?
    vec-len
    vec-ref
    vec-set!
    str-write
    str-read
    file-len
    str-print
    str-input
    clear
    mucha-path
    wait-event
