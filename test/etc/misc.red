Red [title: "Miscellaneous" by: "hinjolicious"]

e.g.: :comment

num-gen: function [num /sorted /min mn /max mx][
	unless mn [mn: 0]
	unless mx [mx: num]
	d: collect [loop num [
		keep mn + random (mx - mn)
	]]
	either sorted [sort d][d]
]

pause: does [ ask "^/Press ENTER to continue...^/" ]

demo: function [b][
	sb: split-block b '|
	either (length? sb) > 1 
		[t: sb/1 c: sb/2]
		[t: [] c: sb/1]
	print [reduce t]
	print [mold/only c]
	print "^/Output:"
	do c
	pause
]
