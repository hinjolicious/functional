Red []

; make new lazy stream from a lazy stream generator with a specified number of how many item to produce
;
; Usage: See example!
;
stream: func ['type 'gen][
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
			ob: object [
				list: gen
				pos: list
				seq: func[][
					if tail? pos [pos: list]
					also pos/1 pos: next pos
				]
			]
			func [n] compose/deep [
				collect [loop n [
					keep ob/seq
				]]
			]
		]
		'walker [
			ob: object [
				current: gen/1
				max-drift: gen/2
				seq: func[][
					current: current + random (max-drift * 2) - max-drift
				]
			]
			func [n] compose/deep [
				collect [loop n [
					keep ob/seq
				]]
			]
		]
		'counter [
			ob: object [ 
				current: gen/1 - gen/2	; start
				increment: gen/2		; step
				seq: func[][
					current: current + increment
				]
			]
			func [n] compose/deep [
				collect [loop n [
					keep ob/seq
				]]
			]		
		]
		'code [
			ob: make object! gen
			func [n] compose/deep [
				collect [loop n [
					keep ob/seq
				]]
			]
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
probe ran 10

; == CYCLER ==
color: stream 'cycler [red green blue] ; any values
probe color 4

; == WALKER ==
walk: stream 'walker [100.0 2.5] ; start, maximum drift
probe walk 5

; == COUNTER ==
counter: stream 'counter [1000 5] ; start, step
probe counter 4

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

; See a better test presentation and the 
; file streamer example in the test folder!
}
