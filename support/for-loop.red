Red []
; custom control to allow a c-style for-loop

; do-for loop: 
; usage:
;	do for [<cond>][<while>][<step>][
;		<body>
;	]

for: func [init [block!] cond [block!] step [block!] body [block!]] [
	compose/deep [ (init) while [(cond)] [(body) (step)] ]
]

; while-step loop: 
; usage:
;	<init> while [<cond>] step [<step>] [
;		<body>
;	]

step: func [step [block!] body [block!]] [
	append copy body step
]

comment { 
print "testing do-for & while-step loop:"
foo: func [][
	do for [i: 0][i < 10][i: i + 2][
		j: 10 while [j > 0] step [j: j - 2][
			if j < i [return j]
			print [i j]
		]	
	]
	"ERROR!"
]
probe foo
}
