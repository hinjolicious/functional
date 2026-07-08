Red [
title: "Zip"
author: "hinjolicious"
purpose: { 
	
Zipping data streams from multiple sources like a list of names, score, age 
that might have some missing records, i.e.: like a jagged matrix.
A list of lists with different lengths.
This essentially zipping related lists into a more contextual records.

e.g.: 
	names: ["john" "jane" "bob"]
	score: [80 60 90]
	age: [30 25]

IMPORTANT: before inputting to zip func, be sure to form the matrix 
	correctly! [ names score age ] is not a matrix, but a list of three words!
	do this instead: lists: reduce [ names score age ] 
	then input it as: zip lists
   the result would be: [ ["john" 80 30] ["jane" 60 25] ["bob" 90 0] ]

 NOTE: missing element are filled with relevant empty values, or according to refinements 

}
note: { zip can be used to transpose matrix, transpose is a specialized function 
	build for a strict rectangular matrices. }
]
	
#include %functional.red
#include %transpose.red
#include %support/safe-assign.red

ZIP: context [

; filler values
filler-map: make map! [
	integer!    0
	float!      0.0
	percent!    0%
	money!      $0.00
	string!     ""
	char!       #"^@"
	logic!      false
	date!       1-Jan-1900
	time!       0:00:00
	tuple!      0.0.0
	pair!       0x0
	block!      []
]
	
ZIP: function [
	"Transposes/zip a matrix (list of lists) - Auto-fill shorter lists"
	matrix [block!] "Matrix as a block of blocks"
	/cyclic "Fill shorter list by repeating it cyclically (R-like)"
	/duplicate "Fill shorter list by duplicating each element"
	/fill value "Fill shorter list by a value"
] [
	if empty? matrix [return copy []]
	matrix ||> length? >- max --> max-len
	matrix ||> [[mat]
		pad-list: copy mat
		needed: max-len - length? mat
		if needed > 0 [
			case [
				cyclic [ ; Repeat the shorter list (R-like behavior)
					cycle-length: length? mat
					repeat i needed [
						append/only pad-list pick mat (i - 1 % cycle-length) + 1
					]
				]
				duplicate [
					clear pad-list
					n: to-integer round/ceiling (max-len / (length? mat))
					repeat i (length? mat) [
						append/only/dup pad-list mat/:i n
					]
					if max-len < length? pad-list [
						;take/last pad-list
						clear at pad-list (max-len + 1)
					]
				]
				fill [insert/only/dup tail pad-list value needed]
				true [insert/only/dup tail pad-list (filler-map/(to word! type? mat/1)) needed]
			]
		]
		pad-list
	] |> transpose
] ; /ZIP function
] ; /ZIP context

;API ==
zip: :zip/zip
; /API

comment { == TEST ==

#include %test/etc/misc.red ; contain "demo" helper function
demo: :demo/demo

demo ["Test 1: Regular matrix"|
m1: [ [a b c] [1 2 3] [x y z] ]
probe zip m1
]
demo ["Test 2: Non-square matrix"|
m2: [ [A B C] [D E F] ]
probe zip m2
]
demo ["Test 3: Jagged matrix (different row lengths)"| 
m3: [ [1 2 3] [4 5] [6 7 8 9] ]
probe zip m3
]
demo ["Test 4: Single row"|
m4: [ [1 2 3 4 5] ]
probe zip m4
]
demo ["Test 5: Single column"|
m5: [ [1] [2] [3] [4] ]
probe zip m5
]
demo ["Test 6: Empty matrix"|
m6: []
probe zip m6
]
demo ["Cyclic fill test"|
m: [[a b][1 2 3 4]] 
m |> zip/cyclic |> probe
]
demo [
m: [[a b][1 2 3 4 5]] 
m |> zip/cyclic |> probe
]
demo ["Duplicate fill test"|
m: [[a b][1 2 3 4]] 
m |> zip/duplicate |> probe
]
demo [
m: [[a b][1 2 3 4 5]] 
m |> zip/duplicate |> probe
]
demo ["Auto fill test"|
m: [ [10 20] [1 2 3 4 5] [[a][b][c]] ] 
m |> zip |> probe
]
demo [
m: [["A" "B"][1 2 3 4 5] [a b]] 
m |> zip |> probe
]

} ; /TEST
