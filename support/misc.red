Red [title: "Miscellaneous" by: "hinjolicious"]

; colorize the console
gui-console-ctx/terminal/color?: yes
gui-console-ctx/terminal/theme: #[
    foreground: [130.187.130]
    background: [0.0.0]
    selected: [128.128.128.128]
	
    string!: [255.255.100]	; works
    integer!: [0.255.0]		; works
    float!: [0.255.0]		; works
    pair!: [255.0.0]
    percent!: [255.128.128]
    datatype!: [255.200.0]	; ?
	
    lit-word!: [150.0.255] ;works
    set-word!: [0.127.255] ; bold] ; works
	
    tuple!: [50.255.50]
    url!: [0.0.255 underline]
    comment!: [128.255.128]
]

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
	; remove the last "^/" if any
	;if #"^/" = pick src length? src [take/last src]
	blk: to block! load src
	print form src
	;try [res: do blk] 
	;if error? :res [res: none]
	;unless none? res [print ["==" mold res]]
	print "=> " 
	res: safe-val safe-do blk
	unless res = "(unset)" [
		;print ["^/==" mold res]
		print [mold res]
	]
]

; this is a simple interactive/visual 'assert' kind of thing
test: func [src chk /local blk res][
	if #"^/" = pick src length? src [take/last src]
	blk: to block! load src
	print form src
	;try/all [res: do blk] 
	;if error? :res [res: none]
	res: mold safe-val safe-do blk
	chk: mold chk
	print ["Output  :" res]
	print ["Expected:" chk]	
	either res = chk [
		print "--> Matched!"
	][
		print "--> NOT matched!"
		cause-error 'user 'message ["Output not matched!"]
	]
]

comment {
demo {10 + 20}
test {print 10} 10
}

