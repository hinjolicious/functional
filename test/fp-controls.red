Red []

; Ways to control executions while using FP Library

#include %../fp.red

print "== Ways to control FP executions ==^/"
	
range: function [n][ collect [repeat i n [keep i]] ]

print "Return early with a value and continue with next operation:"
probe [1 2 3 4 5 6 7 8 9 10] 
	||> [[x] if x > 5 [return x * 10] x]	; return early with a value
	||> negate 								; continue with next operation
;[-1 -2 -3 -4 -5 -60 -70 -80 -90 -100]

print "^/Break early: skip current loop, but continue with the operation:"
probe [1 2 3 4 stop 6 7 8 9 10] 
	||> [[x] if x = 'stop [break] x] 		; break early, 
	||> [* 2] 								; but continue
;[2 4 6 8]

print "^/Skip bad data and continue:"
probe [1 2 3 (cos pi) none "6" 7 8 9 10] 
	||> [[x] if not number? x [continue] x]	; skip bad data
	||> negate
;[-1 -2 -3 -7 -8 -9 -10]

print "^/Skip bad data and continue, (cos pi) is evaluated:"
probe (reduce [1 2 3 (cos pi) none "6" 7 8 9 10]) 
	||> [[x] if not number? x [continue] x]	; skip bad data (evaluated)
	||> negate
;[-1 -2 -3 1.0 -7 -8 -9 -10]

print "^/Using catch/throw to cancel the whole chain of operations:"
if val: catch [
	total: 0
	[1 2 3 pi none "6" 7 8 9 10]
		||> [[x] if not number? x [throw x] x] ; cancel other operations when non-number found 
		|> sum --> total ; not executed
][
	print "Catched!"
	print ["val:" mold val] ; catched val
	print ["total:" total] ; total still 0
]
;Catched!
;val: pi
;total: 0

print "^/Same as above, but 'none' is evaluated to a value (using named throw):"
if val: catch/name [
	total: 0
	(reduce [1 2 3 pi none "6" 7 8 9 10])
		||> [[x] if not number? x [throw/name reduce [x] 'error] x] ; throw can't directly use none! value
		|> sum --> total ; not executed
] 'error [
	print "Catched!"
	print ["val:" mold val] ; catched val
	print ["total:" total] ; total still 0
]
;Catched!
;val: [none]
;total: 0
