Red [title: "Miscellaneous" by: "hinjolicious"]

; content:
; * safe-do, safe-val
; * demo, test, assert

e.g.: :comment

#include %../chunk.red
#include %../functional.red

num-gen: function [num /sorted /min mn /max mx][
	unless mn [mn: 0]
	unless mx [mx: num]
	d: collect [loop num [
		keep mn + random (mx - mn)
	]]
	either sorted [sort d][d]
]

;== SAFE-DO & SAFE-VAL ==

safe-do: func [code [block!]][
    set/any 'res try/all code
    ;either unset? get/any 'res ["(unset)"][get/any 'res]
	get/any 'res ; this will get any value including unset !
	; use safe-val to print it!
]

safe-val: func [val [any-type!]][
    case [
        unset? :val ["(unset)"]
        ;error? :val [print ["Error object:" mold :val]]   ; or probe :val for more detail
		error? :val ["(error)"] ; or probe :val for more detail
        none?  :val ["(none)"]
        true		[:val]  
    ]
]

comment {
probe safe-val safe-do [1 + 2]
probe safe-val safe-do [comment "hi"]  ; returns none
probe safe-val safe-do [print "hello"] ; returns 'unset
probe safe-val safe-do [1 / 0]         ; returns the error object
}

;== SIMPLE ASSERT ==

assert: func [cond [block!]][
	unless do cond [
		cause-error 'user 'message [rejoin ["Assertion failed: " mold cond]]
	]
]

comment {
assert [1 = 1]
assert [2 = 2]
assert [(10 + 20) = 40]
}

;== DEMO & TEST ==

pause: does [ask "Press ENTER to continue..." print ""]

demo: function [src /local blk][
	blk: to block! load src
	print form src
	;try [res: do blk] 
	;if error? :res [res: none]
	;unless none? res [print ["==" mold res]]
	res: safe-val safe-do blk
	unless res = "(unset)" [print ["==" mold res]]
]

; this is a simple interactive/visual 'assert' kind of thing
test: func [src chk /local blk res][
	blk: to block! load src
	print form src
	;try/all [res: do blk] 
	;if error? :res [res: none]
	res: safe-val safe-do blk
	prin ["==" mold res]
	either res = chk [
		print " ."
	][
		print [" ???^/Expected:" mold chk]
		cause-error 'user 'message ["Output not matched!"]
	]
]

comment {
demo {10 + 20}
test {print 10} 10
}

