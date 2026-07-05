Red [
; custom structure to allow a c-style for-loop in Red
]

; do-for loop:

; usage:
;	do for [cond][while][step][
;		body
;	]
; note: must use do, because the for function only return the block
; not directly executing it, so as to get the correct context!
for: function [ 
	_init [block!] ; initialization
	_cond [block!] ; while condition
	_step [block!] ; step operation
	_body [block!] ; function's body
][
; method a: using compose/deep
	compose/deep [(_init) while [(_cond)][(_body) (_step)]]
; method b: using block manipulation
	;_body: head insert tail copy _body _step ; copy _body, insert _step at its tail, return to its head!
	;compose/deep [(_init) while [(_cond)][(_body)]] ; compose the whole stuff
; returned block is like this:
	;	>> for [i: 0][i < 10][i: i + 1][print i]
	;	== [i: 0 while [i < 10][print i i: i + 1]]	
]

; while-step loop:

; usage:
;	init
;	while [cond] step [step] [
;		body
;	]
; note: use while and combined with step function
step: function [
	_step [block!] ; step block
	_body [block!] ; body block
][
	; method a: using compose/deep
	;compose/deep [(_body) (_step)]
	; method b: using block manipulation
	head insert tail copy _body _step ; copy _body, insert _step at its tail
]

#include %increment.red

do for [i: 0][i < 10][++ i][print i]
i: 10 while [i > 0] step [-- i][print i]
