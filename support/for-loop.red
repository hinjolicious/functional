Red [
; custom structure to allow a c-style for-loop in Red
]

;-----------------------------------------------------------------------
; do-for loop: 
;
; usage:
;
;	do for [<cond>][<while>][<step>][
;		<body>
;	]
;
; note: must use do, because the for function only return the block,
; not directly executing it, so as to get the correct context!

for: func [init [block!] cond [block!] step [block!] body [block!]][
	compose/deep [(init) while [(cond)] [(body) (step)]]
]

;--------------------------------------------------------------------------
; while-step loop: 
;
; usage:
;
;	<init>
;	while [<cond>] step [<step>] [
;		<body>
;	]
;
; note: use while and combine it with step function

step: func [step [block!] body [block!]][
	append copy body step
]

;------------------------------------------------------------------------
comment { 

#include %increment.red
#include %misc.red

demo {
do for [i: 0][i < 10][++ i][
	print i
]
}

demo {
i: 10 while [i > 0] step [-- i][
	print i
]
}

demo {
do for [i: 0] [i < 10] [i: i + 1] [
	if i = 3 [i: i + 1 continue]
	print i
]
}

demo {
i: 0 while [i < 10] step [i: i + 1] [
	if i = 3 [i: i + 1 continue]
	print i
]
}

demo {
do for [i: 0] [i < 10] [i: i + 1] [
	if i = 3 [break]
	print i
]
}

demo {
i: 0 while [i < 10] step [i: i + 1] [
	if i = 3 [break]
	print i
]
}

}
