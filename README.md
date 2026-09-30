# Mucha Programming Language

**Mucha is a functional programming language without parentheses, designed to be freely extensible from a small core.**
Programs are written as flat sequences of whitespace-separated tokens, without parentheses or indentation-based grouping. Expression structure is determined by the arity of each syntactic form.

```mucha
def fact $ n
  if = int 0 n
     int 1
     * n . fact . dec n
. fact int 3
```


## A Small Core

Mucha has only six core syntactic forms:

```mucha
def  set  if  fn  ap  sym
```

At its center are `fn` and `ap`, for function abstraction and application. The remaining forms provide conditionals, symbols, and the creation and mutation of bindings.
Functions are first-class values with lexical scoping and closures. Bindings can also be mutated with `set`; Mucha is not intended to restrict the programmer to a purely functional style.
Even literals such as integers and strings are not part of the core syntax. Instead, they are constructed from symbols, with macros providing convenient notation:

```mucha
int 42
str hello
```


## Macros

On top of the core syntax, Mucha provides a customizable macro system.
For example, some of the standard macros are defined as:

```mucha
$ x body  | fn x body |
. f x     | ap f x    |
' x       | sym x     |
...
```

Thus,

```mucha
def id fn x x
ap id sym foo
```

can be written as:

```mucha
def id $ x x
. id ' foo
```

Macros are defined in `macros.mch` and can be freely added or modified by the user.


## Actions Are Values

Mucha represents side effects such as I/O as **action values**.
Actions can be passed around like ordinary values, composed with `bind`, and executed when required.

```mucha
>> . print ' hello
   . print ' world
```


## Building in the Language

Before adding a feature to the core, Mucha asks whether it can instead be expressed in Mucha itself.
The standard library implements, among other things:

- lists and higher-order list operations
- `map`, `foldl`, and `foldr`
- delayed computation
- memoization
- lazy lists and infinite streams

For example, infinite sequences of natural numbers and Fibonacci numbers can be defined directly in Mucha:

```mucha
def ones { int 1 ones
def nat  { int 0 : add+ nat ones
def fib  { int 0 { int 1 : add+ fib . rst+ fib
...
```


## Implementation

The interpreter is implemented in CHICKEN Scheme.
The core implementation is kept relatively small and currently includes:

- tokenizer
- arity-driven parser
- macro expansion
- evaluator
- lexical environment and store
- mark-and-sweep garbage collector
- action-based I/O
- REPL

The implementation is designed to remain extensible without significantly modifying the core. For example, additional primitive data types can register their own tracers with the garbage collector.
Mucha is not intended to provide a large set of features out of the box. Instead, its goal is to provide **a small implementation that can be understood, hacked, and extended by its users**.


## Build

Mucha is currently developed on Ubuntu.
The following is the current development setup:

### Requirements

- CHICKEN Scheme 5
- GNU Make
- a C compiler such as GCC

On Ubuntu, CHICKEN can be installed with:

```sh
sudo apt update
sudo apt install chicken-bin make
```

Make sure that the CHICKEN compiler driver is available as `csc`:

```sh
csc -version
```

Then clone the repository and build Mucha:

```sh
git clone https://github.com/knjnszk/mucha/
cd mucha
make
```

This builds:

```text
mucha-core
mucha
mucha-full
```

When Mucha is run from the repository root, `MUCHA_PATH` is not required. To run it from another directory, first set `MUCHA_PATH` to the repository root:

```sh
cd /path/to/mucha
. ./setup.sh
```

Then start the standard interpreter:

```sh
./mucha
```


## Try it

A small interactive example is included in `examples/`.

```sh
./mucha-full examples/cursor.mch
```

Use `h`, `j`, `k`, and `l` to move the `@` character around the screen.
Press `q` to quit.

Previously tested on Ubuntu and WSL.
This example uses raw terminal input and may depend on terminal behavior.


## Status

Mucha is an experimental programming language.
The language specification, libraries, and macro system are subject to change.
