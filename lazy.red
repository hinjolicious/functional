Red []

; make new lazy stream from a lazy stream generator with a specified number of how many item to produce
;
; Usage: See example!
;
stream: func ['type 'gen /local ob][
	switch type [
		'func [
			func [n] compose/deep [
				collect [loop n [
					keep (:gen)
				]]
			]	
		]
		'block [
			func [n] compose/deep [
				collect [loop n [
					keep do compose [(gen)]
				]]
			]
		]
		'cycler [
			func [n] bind compose/deep [
				if n = 'reset [reset exit]
				collect [loop n [keep seq]]
			] object [
				list: gen
				pos: list
				seq: func [][
					if tail? pos [pos: list]
					also pos/1 pos: next pos
				]
				reset: func [][pos: list]
			]
		]
		'walker [
			func [n] bind compose/deep [
				if n = 'reset [reset exit]
				collect [loop n [keep seq]]
			] object [
				curr: gen/1
				start: curr
				drift: gen/2
				seq: func [][curr: curr + random (drift * 2) - drift]
				reset: func [][curr: start]
			]
		]
		'counter [
			func [n] bind compose/deep [
				if n = 'reset [reset exit]
				collect [loop n [keep seq]]
			] object [ 
				curr: gen/1 - gen/2		; start
				start: curr
				incr: gen/2				; step
				seq: func[][curr: curr + incr]
				reset: func [][curr: start]
			]	
		]
		'code [
			func [n] bind compose/deep [
				if all [n = 'reset value? 'reset] [reset exit]
				collect [loop n [keep seq]]
			] make object! gen
		]
	]
]

comment {

; == LAZY STREAMER TEST ==

; == FUNC ==
#include %../statistics/ziggurat.red

zig: stream 'func ziggurat/seq ; use a direct generator function
probe zig 5

; == BLOCK ==
ran: stream 'block [random 1000] ; a block to evaluate
probe ran 5
probe zig 3

; == CYCLER ==
color: stream 'cycler [red green blue] ; any values
probe color 4
probe ran 2

; == WALKER ==
walk: stream 'walker [100.0 2.5] ; start, maximum drift
probe walk 5
probe color 2

; == COUNTER ==
counter: stream 'counter [1000 5] ; start, step
probe counter 4
probe walk 3

; == CUSTOM CODE - FIBONACCI STREAMER ==

fib: stream 'code [
	a: 0 b: 1
	seq: func [][
		set [a b] reduce [b a + b]
		a
	]
]
probe fib 5
probe fib 5
probe counter 2

; == PRIME NUMBERS ==

pri: stream 'code [ ; simple lazy prime
	curr: 1
	seq: func [/local is-prime? i][
		until [
			curr: curr + 1
			is-prime?: true
			repeat i (to integer! sqrt curr) [
				if all [i > 1  0 = (modulo curr i)] [
					is-prime?: false
					break
				]
			]
			is-prime?
		]
		curr
	]
]
probe pri 5
probe pri 5
probe fib 2

fib2: stream 'code [
	a: 0 b: 1
	seq: func [][
		set [a b] reduce [b a + b]
		a
	]
	reset: func [][a: 0 b: 1]
]
probe fib2 5
probe fib2 5
fib2 'reset
probe fib 5

; See a better test presentation and the 
; file streamer example in the test folder!
}
