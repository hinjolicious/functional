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

FILLER: function [list][ ; auto-filler helper function
	either empty? list [none] [
		e: list/1  case [
			integer? e	[0]
			float? e	[0.0]
			percent? e	[0%]
			money? e	[$0.00]
			string? e	[""]
			char? e		[#" "]
			logic? e	[false]
			date? e		[1-Jan-1900]
			time? e		[0:00:00]
			tuple? e	[0.0.0]
			image? e	[make image! [0x0]]
			bitset? e	[make bitset! ""]
			block? e	[[]]
			true		[none]
		]
	]
] ; /FILLER

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
					if (length? pad-list) > max-len [
						;take/last pad-list
						clear at pad-list (max-len + 1)
					]
				]
				fill [insert/only/dup tail pad-list value needed]
				true [insert/only/dup tail pad-list (filler mat) needed]
			]
		]
		pad-list
	] |> transpose
] ; /ZIP function
] ; /ZIP context

;== API ==
zip: :zip/zip
; /API

comment { ;== TEST ==

#include %test/etc/misc.red ; contain "demo" helper function

demo ["Test 1: Regular matrix"|
m1: [ [a b c] [1 2 3] [x y z] ]
print mold zip m1
]

demo ["^/Test 2: Non-square matrix"|
m2: [ [A B C] [D E F] ]
print mold zip m2
]

demo ["^/Test 3: Jagged matrix (different row lengths)"| 
m3: [ [1 2 3] [4 5] [6 7 8 9] ]
print mold zip m3
]

demo ["^/Test 4: Single row"|
m4: [ [1 2 3 4 5] ]
print mold zip m4
]

demo ["^/Test 5: Single column"|
m5: [ [1] [2] [3] [4] ]
print mold zip m5
]

demo ["^/Test 6: Empty matrix"|
m6: []
print mold zip m6
]

demo ["^/Cyclic fill test"|
m: [[a b][1 2 3 4]] 
m |> [zip/cyclic it] |> probe
]

demo [|
m: [[a b][1 2 3 4 5]] 
m |> [zip/cyclic it] |> probe
]

demo ["^/Duplicate fill test"|
m: [[a b][1 2 3 4]] 
m |> [zip/duplicate it] |> probe
]

demo [|
m: [[a b][1 2 3 4 5]] 
m |> [zip/duplicate it] |> probe
]

demo ["^/Auto fill test"|
m: [ [10 20] [1 2 3 4 5] [[a][b][c]] ] 
m |> [zip it] |> probe
]

demo [|
m: [["A" "B"][1 2 3 4 5] [a b]] 
m |> [zip it] |> probe
]

} ; /TEST
