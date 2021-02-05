<h1 align="center">Lambda Calculus Interpreter</h1>

## Installation
To use this lambda calculus interpreter, just execute the *make* command from the root directory of the project, where the Makefile file is located. This will make the program compile and run, allowing you to interact with it. After finishing its execution, all the files generated during the compilation will be deleted. Depending on the version of OCaml installed, an error may occur when compiling the interpreter. This should be fixed by running the following command:
```
export OCAMLPARAM="safe-string=0,_"
```
**ATTENTION: This interpreter uses the rlwrap command in its execution, so it must be installed on the system for its correct operation.**

## Types
### 2.1 Unit
The unit type is the most basic that we can use. It has a single value and can be used as follows:
```
# ();
- () : Unit
# unit;
- () : Unit
```

### 2.2 Boolean
The next type to take into account would be the boolean, to be able to represent the true and false values. These two values are already implemented by the reserved words *true* and *false*.
```
# true;
- true : Bool
# false;
- false : Bool
```
This type allows us to introduce control structures, as *if-then-else*. As you might expect, the guardian expression must be of type boolean and the two branches of the conditional must return the same type. An example of this structure is shown below:
```
# if true then true else false;
- true : Bool
# if 0 then true else false;
Error: if was expected a guard of type Bool
# if true then "true" else false;
Error: if was expected a result of the same type
```

### 2.3 Natural
In order to represent the natural numbers, the Nat type has been implemented. These are based on the value 0 and the rest are obtained from the primitive *succ*. This way of representing the naturals in lambda calculus is the [Church's definition of numbers](https://en.wikipedia.org/wiki/Church_encoding). As an alternative to facilitate its use, any other natural is allowed as input, as well as making use of it and the primitives *succ* and *pred* to obtain other naturals.
```
# 0;
- 0 : Nat
# succ(0);
- 1 : Nat
# pred(5);
- 4 : Nat
```

### 2.4 Float
In addition to the naturals, floating numbers have also been implemented (only positive ones). To build them, just write the integer part first, followed by a dot and the decimal part.
```
# 1.0;
- 1. : Float
# 3.14;
- 3.14 : Float
```
NOTE: No functionality has been implemented that uses this type, but it is available to you in case you want to use it.

### 2.5 String
Lastly, the string type has been implemented to represent character strings bounded by double quotes. If these quotes are not closed or if there is some non-representable character between them, an error message will be thrown.
```
# "hello world!"
- "hello world!" : String
# "esternocl;
Error: String not terminated
# "\t";
- " " : String
# "\\";
- "\" : String
# "\"";
- """ : String
# "\034";
- """ : String
# "\256";
Error: Illegal character constant
```

## 3 Primitives
### 3.1 lambda
It is used to make the abstractions. It can be written as "lambda", "L" or "λ".
```
# lambda x:Nat. x;
- λx:Nat. x : Nat -> Nat
# L x:Nat. x;
- λx:Nat. x : Nat -> Nat
# λx:Nat. x;
- λx:Nat. x : Nat -> Nat
```

### 3.2 if-then-else
As seen previously, this primitive allows us to structure our expressions based on a boolean conditional.
```
# if true then true else false;
- true : Bool
# if false then true else false;
- false : Bool
```

### 3.3 succ
Returns the natural immediately following a natural given.
```
# succ(0);
- 1 : Nat
# succ(4);
- 5 : Nat
```

### 3.4 pred
Returns the natural immediately before a natural given.
```
# pred(0);
- 0 : Nat
# pred(2);
- 1 : Nat
```

### 3.5 iszero
Returns true if a given natural is zero or false otherwise.
```
# iszero(0);
- true : Bool
# iszero(3);
- false : Bool
```

### 3.6 let-in
Although this primitive does not add any new functionality, since it does the same as "(lambda x. T) v", it is useful for writing more complex expressions.
```
# let a = 0 in iszero(a);
- true : Bool
# (lambda a:Nat. iszero(a)) 0;
- true : Bool
```

### 3.7 fix
Implementation of the [fix operator](https://en.wikipedia.org/wiki/Fixed-point_combinator) to be able to emulate recursion in lambda calculus.
```
# let sumaux = lambda f:Nat->Nat->Nat. lambda n:Nat. lambda m:Nat.
if iszero n
then m
else succ (f (pred n) m) in
let sum = fix sumaux in
sum 40 2;
- 42 : Nat
```

### 3.8 letrec
Similar to *let-in*, this primitive already incorporates the fix operator, to simplify expressions that would be more complex.
```
# letrec sum:Nat->Nat->Nat = lambda n:Nat. lambda m:Nat.
if iszero n
then m
else succ (sum (pred n) m)
in sum 40 2;
- 42 : Nat
```

## 4 Miscellany
Here we talk about some more tangential aspects of the interpreter.
- Close: To exit from the interactive mode, you can use the reserved word *exit* (followed by the semicolon required to close any expression) or press the keys *Ctrl+D*. To close the interpreter in any other way does not ensure that the files generated when compiling will be deleted. In this situation, these files can be deleted using the following command:
    ```
    make clean
    ```
- Expression history: You can press the upper and lower direction arrows to browse the history of expressions already used.
- Reading files: If you use the reserved word *open* a file with a *lambda* extension can be opened. From this all the expressions will be read and evaluated in the order in which they are declared. For example, consider a file called "test.lambda" with the following expressions:
    ```
    id_nat = lambda x:Nat. x;
    id_nat 14;
    ```
    Using the *open* command we will obtain the following output:
    ```
    # open test;
    - id_nat : Nat -> Nat
    - 14 : Nat
    ```
- Multiline expressions: It is possible to write an expression in more than one line, to facilitate its reading and writing.
    ```
    # if iszero(0)
    then true
    else false
    ;
    - true : Bool
    ```
- Lines with multiple expressions: If there is a line in which more than one expression is written (each one with its final semicolon), only the first one will be evaluated, regardless of whether the following is well built or not.
    ```
    # true; "error;
    - true : Bool
    ```
    NOTE: This behavior is only applicable to the interactive mode. All expressions obtained from a file are evaluated until reaching the end of the file.
- Free variables: These are expressions that allow the association of names of free variables with values in a context to be used later in other expressions.
    ```
    # id_nat = lambda x:Nat.x;
    - id_nat : Nat -> Nat
    # id_bool = lambda x:Bool.x;
    - id_bool : Bool -> Bool
    ```
- Comments: It is possible to add comments as long as they are between "(\ *" and "\ *)", ignoring everything that is inside in the evaluation.