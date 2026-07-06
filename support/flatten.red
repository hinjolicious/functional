Red[]

; flatten nested blocks

flatten: function [
	"Flatten a list"
	list "A list to flatten"
	/repeat n "How many times?"
	/all "Flatten all?"
][ 
	either all [load form list][
		loop either repeat [n][1] [
			list: collect [foreach e list [keep e]]
		]
	]
]

comment [
x: [1 [2 [3]] [[[4]]] 5] 
probe mold f: flatten/all x 
probe mold f: flatten x
probe mold f: flatten/repeat x 2
]