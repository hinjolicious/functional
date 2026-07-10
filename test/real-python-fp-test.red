Red []

#include %../fp.red
#include %../support/misc.red ; contain "demo" helper function

demo {
; How Well Does Red Support Functional Programming?

; 1. Assign a function to a variable:

fun: function [][print "I am a function fun!"]
fun ; I am function fun!

another-name: :fun
another-name ; I am a function fun!
}
pause

demo {
print ["cat" :fun 42] ; print a function 
}
demo {
obj: reduce ["cat" :fun 42] ; put in a list
obj/2
}
demo {
d: #["cat" 1 :fun 2 42 3] ; use it as a map key (just its name)
d/fun
}
;== #[
;    "cat" 1
;    fun: 2
;    42 3
;]
pause

demo {
inner: function [][print "I am a function inner!"]
outer: function [fun][fun] ; outer accept a function and call it inside
outer :inner ; give inner as an argument for outer
}
pause

demo {
; A function passed-in to another function as a 'callback' that can change the outer functions' behavior

animals: ["ferret" "vole" "dog" "gecko"]
sort animals
}
demo {
; Changing how sort behave using a to compare length instead

sort/compare animals func [a b][(length? a) < (length? b)]
}
demo {
; Creating a custom function that reverse the length to sort a list in reversed order

reverse-len: func [s][negate length? s]
sort/compare animals func [a b][(reverse-len a) < (reverse-len b)]
}
pause

demo {
; Using a function as the return value of another function

outer: func [][
	inner: func [][print "I am function inner!"]
	:inner ; return inner
]
fun: outer ; fun=outer()
}
demo {fun ; fun()}
demo {do reduce [outer] ;outer()() }
pause

demo {
; Definining an Anonymous Function With lambda
; (Red's functions are basically a lambda)

func [s][slice [none none -1]]
function? func [s][slice [none none -1]] ; true
}
demo {
; Assigning lambda to a variable

rev: func [s][slice s [none none -1]]
rev "I am a string"
}
pause

demo {
; Using lambda without assigning it to a variable

animals: ["ferret" "vole" "dog" "gecko"]
sort/compare animals func [a b][(negate length? a) < (negate length? b)]
}
pause

demo {
; Applying a Function to an Iterable with map"

; Calling map With a Single Iterable

; NOTE: Instead of a lambda, this FP library has a simpler, cleaner alternatives
; like a direct 'code-block' in several variants

animals: ["cat" "dog" "hedgehog" "gecko"]
iterator: animals ||> [slice it [none none -1]]
probe iterator 

; NOTE: 
;	||> is the map operator
;	[slice it [none none -1]] is simpler lambda, with an automatic argument 'it'
}

demo {
; Combining it all into one line:

["cat" "dog" "hedgehog" "gecko"] ||> [slice it [none none -1]] |> probe 
}
pause

demo {
; Calling map with Multiple Iterable"

; This FP library didn't have a direct mapping with multiple series at the same time,
; but it can be simulated easily with matrix transpose:

; Arrange each series inside a block (like a matrix):
m: [[  1   2   3]  ; series 1
    [ 10  20  30]  ; series 2
    [100 200 300]] ; series 3

; Or, do this:	
ser1: [  1   2   3]  ; series 1
ser2: [ 10  20  30]  ; series 2
ser3: [100 200 300] ; series 3	

m: reduce [ser1 ser2 ser3]

m |> transpose ||> [[a b c] a + b + c] |> probe

; NOTE: 
;	|> is the pipe operator
;	||> is the map operator
;	[[a b c] a + b + c] is the simpler lambda with arguments [a b c]
}
demo {
; Another way using collect/keep:

m |> [[a b c] collect [repeat i length? a [keep reduce [a/:i + b/:i + c/:i]]]] 
}

test {
; Or, it can actually be done simply by this:

m |> transpose ||> sum |> probe 

; NOTE: an even simpler lambda by directly using a function name and it will take its argument 
; from the left side intuitively
} [111 222 333]	
pause

demo {
;Selecting elements from series with filter

[1 111 2 222 3 333] || [> 100] |> probe

; NOTE: 
;	|| is the filter operator
;	[> 100] is another variant of simple lambda that assume operand from the left side
}
pause

demo {
(range 10) || even? |> probe
}
demo {
["cat" "Cat" "CAT" "dog" "Dog" "DOG" "emu" "Emu" "EMU"] 
	|| [it == uppercase copy it] |> probe
; NOTE: mus use 'copy' because 'uppercase' is mutates its operands!
}

demo {
; Reducing an iterable to a single value with fold

[1 2 3 4 5] >- add |> probe			; implicit sum
[1 2 3 4 5] >- [[s x] s + x] |> probe	; explicit s: s + x

; NOTE:
;	>- is the fold operator
;	fold code block has special format [<accumulator> <argument(s)> <initial value>]
}
pause

demo {
;
["cat" "dog" "hedgehog" "gecko"] >- [[f x] rejoin [f x]] |> probe
}
pause

demo {
;Factorial function using fold and range

fold-fact: function [n][ (range n) >- multiply ]
probe fold-fact 4
probe fold-fact 6
}
pause

demo {
; Fiinding maximal value in a list

[23 49 6 32] >- [[f x] either f > x [f][x]]
}
pause

demo {
; Calling fold with an initial value

[1 2 3 4 5] >- [[x y 100] x + y]
}
pause
