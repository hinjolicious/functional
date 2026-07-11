Red []

#include %../fp.red
#include %../support/misc.red
#include %etc/complex.red ; a simple complex math library

demo {
; NOTE: This demo is using a custom complex number library, with custom operator for it to mimic how Python do it.
; So, this is not to show the performance of this FP library, but how this library can handle complex 
; computation with nested operations chaining, etc.
	
;== HELPER ==

step: function [start step iterations][ ; mimicking ruby's step function
	collect [foreach i range iterations [
		keep start + (i * step) ]] ]

; 1) This is a translation of a Python code from the Rosetta Code which itself is a translation from a Ruby code

mandelbrot: function [a][ 
	(range 50) >- [[z _ 0] z c* z c+ a] ]
	
rows: collect [foreach y step 1 -0.05 41 [
		keep to-string collect [foreach x step -2.0 0.0315 80 [
			keep either (com-abs mandelbrot complex x y) < 2 ["*"]["."]
		]]
	]]

foreach row rows [print row]
} pause

demo {
; 2) This is a full functional style using this FP Library

; Functional Mandelbrot Demo
; Note: 'step' mimic Ruby's built-in step function
;       'range' a simple Python-like range function
; * Demonstrate nested operations
; * Operations: |> pipe, ||> map, >- fold, || filter (not used)
; * Accessing outer argument from inner operations
; * Early termination using 'break'

(step 1 -0.05 41) ||> [[y] ; level-1
	(step -2.0 0.0315 80) ||> [[x] ; level-2
		either (
			(range 50) >- [[z _ (complex 0 0)] ; level-3: accumulate z using fold, operate on custom complex numbers
				if (com-abs z) > 1000 [break] ; short-circuit, stop iteration early
				z c* z c+ complex x y ; the mandelbrot calculation
			] |> com-abs 
		) < 2 ["*"]["."]
	] |> to-string |> [append it newline] 
] |> print 
} pause

demo {
; 3) This is translated from a more Pythonic Python code:

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

foreach y range [-20 20] [
	foreach x range [-80 30] [
		prin either not NaN? com-real mandelbrot 
			complex 0 0 
			(x * 0.02) c+ ((complex 0 1) c* (y * 0.05)) 
			none 
		["#"]["."]
	]
	print ""
]
} pause

demo {
; 4) Using this FP Library

(range [-20 20]) ||> [* 0.05] ||> [[y]
	(range [-80 30]) ||> [* 0.02] ||> [[x]
		either not NaN? com-real mandelbrot 
			complex 0 0 
			x c+ ((complex 0 1) c* y) 
			none 
		["#"]["."] 
	] |> to-string |> [append it newline]
] |> print
}
