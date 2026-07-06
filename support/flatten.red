Red[]

#include %fold.red

; flatten nested blocks

flatten: function [
	"Flatten a list"
	l "A list to flatten"
	/repeat n "How many times?"
	/all "Flatten all?"
][ 
	either all [
		load form l
	][
		loop either repeat [n][1] [
			l: fold/init l [append _a _e] copy [] 
		]
	]
]

;== TEST ==

comment [

#include %mylib.red
#include %pipe-map-clean.red
>>>: function [b][print mold/only b  do :b]

>>> [ x: [1 [2 [3]] [[[4]]] 5] ]
>>> [ x |> [flatten/all _p] |> probe ]
>>> [ x |> flatten |> probe ]
>>> [ x |> [flatten/repeat _p 2] |> probe ]

]