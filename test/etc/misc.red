Red [splitted: "Miscellaneous" by: "hinjolicious"]

e.g.: :comment

#include %../../chunk.red

num-gen: function [num /sorted /min mn /max mx][
	unless mn [mn: 0]
	unless mx [mx: num]
	d: collect [loop num [
		keep mn + random (mx - mn)
	]]
	either sorted [sort d][d]
]



DEMO: context [
	halt-it: false
	
demo: function [blk][
	splitted: split-block blk '|
	either 2 <= length? splitted [
		set [title code] splitted
	][	
		title: [] code: splitted/1
	]
	print ["^/==" reduce title "^/"]
	print [mold/only code]
	print "^/Output:"
	do code
	pause
]

pause: does [ask "Press ENTER to continue..." print ""]

; this is a simple interactive/visual 'assert' kind of thing
test: function [blk /local code ex cmt][
	; blk = [code expected comment]
	set [code ex cmt] blk ; this way of setting, didn't respect 'function'. must explicitly made them local!
	print [mold/only code]
	res: do code
	print ["==" m-res: mold res]
	cmt: either cmt [rejoin ["; " cmt]][""]
	print ["; " m-ex: mold ex cmt "-->" either ok: m-res = m-ex ["OK!"]["???"] "^/"]
	if all [not ok halt-it] [halt]
]

display: function [blk /code cmt][
	; blk = [code comment]
	set [code cmt] blk
	cmt: either cmt [rejoin ["; " cmt]][""]
	print [mold/only code cmt "^/"]
	do code
]

];/demo context

comment { == USAGE ==
test:  :demo/test    ; "as" it to whatever make sense
say:   :demo/display ; ditto
pause: :demo/pause
demo/halt-it: true ; halt, when output didn't matched expected value

say [ [x: 10] "x is a variable" ]
;x: 10 ; x is a variable 
;
test [ [x + 20] 30 "must be 30" ]
;== 30
;;  30  ; must be 30 --> OK! 
}