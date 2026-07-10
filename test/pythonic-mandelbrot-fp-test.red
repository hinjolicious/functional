Red []

#include %../fp.red
#include %etc/complex.red ; a simple complex math library

; NOTE: This demo is using a custom complex number libary, with custom operator for it to mimic how Python do it.
; So, this is not to show the performance of this FP library, but how this library can handle complex 
; computation with nested operations chaining, etc.
	
;== HELPER ==

range: function [n][ collect [repeat i n [keep i]] ]
range2: function [start stop][ collect [i: start while [i <= stop][keep i i: i + 1]]] 
step: function [start step iterations][ ; mimicking ruby's step function
	collect [foreach i range iterations [
		keep start + (i * step) ]] ]

; 1) This is a translation of a Python code from the Rosetta Code which itself is a translation from a Ruby code
print "1)"

mandelbrot: function [a][ 
	(range 50) >- [[z _ 0] z c* z c+ a] ]
	
rows: collect [foreach y step 1 -0.05 41 [
		keep to-string collect [foreach x step -2.0 0.0315 80 [
			keep either (com-abs mandelbrot complex x y) < 2 ["*"]["."]
		]]
	]]

foreach row rows [print row] 

; 2) This is a full functional style using this FP Library
print "2)"

print "Functional Mandelbrot Demo"
print "Note: 'step' mimic Ruby's built-in step function"
print "      'range' a simple Python-like range function"
print "* Demonstrate nested operations"
print "* Operations: |> pipe, ||> map, >- fold, || filter (not used)"
print "* Accessing outer argument from inner operations"
print "* Early termination using 'break'"

(step 1 -0.05 41) ||> [[y] ; level-1
	(step -2.0 0.0315 80) ||> [[x] ; level-2
		either (
			(range 50) >- [[z _ (complex 0 0)] ; level-3: accumulate z using fold, operate on custom complex numbers
				if (com-abs z) > 1000 [break] ; short-circuit, stop iteration early
				z c* z c+ complex x y ; the mandelbrot calculation
			] |> com-abs 
		) < 2 ["*"]["."]
	] |> to-string |> [print it it]
]

; 3) This is translated from a more Pythonic Python code:
print "3)"

; Red's true native literal formats for special float states:
NaN:  1.#NaN ;== 1.#NaN
pINF: 1.#INF ;== 1.#INF
nINF: -1.#INF ;== -1.#INF

mandelbrot: function [z c n][
	unless n [n: 40]
	case  [
		(com-abs z) > 1000 [return complex NaN NaN]
		n > 0 [return mandelbrot  z c* z c+ c  c  n - 1]
    true [return z c* z c+ c]
	]
]

foreach y range2 -20 20 [
	foreach x range2 -80 30 [
		prin either not NaN? com-real mandelbrot 
			complex 0 0 
			(x * 0.02) c+ ((complex 0 1) c* (y * 0.05)) 
			none 
		["#"]["."]
	]
	print ""
]

; 4) Using this FP Library
print "4)"

(range2 -20 20) ||> [* 0.05] ||> [[y]
	(range2 -80 30) ||> [* 0.02] ||> [[x]
		either not NaN? com-real mandelbrot 
			complex 0 0 
			x c+ ((complex 0 1) c* y) 
			none 
		["#"]["."]
	] |> to-string |> [print it it]
]
