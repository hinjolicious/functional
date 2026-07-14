Red []

#include %../lazy.red
#include %../../statistics/ziggurat.red
#include %../support/misc.red

demo {
; == LAZY STREAMER TEST ==

; == FUNC ==

zig: stream 'func ziggurat/seq ; use a direct generator function
zig 1 ; get one item}
demo {
zig 5 ; get 5 now} pause

demo {
; == BLOCK ==
ran: stream 'block [random 1000] ; a block to evaluate
ran 10
} pause

demo {
; == CYCLER ==
color: stream 'cycler [red green blue] ; any values
color 4
} pause

demo {
; == WALKER ==
walk: stream 'walker [100.0 2.5] ; start, maximum drift
walk 5
} pause

demo {
; == COUNTER ==
counter: stream 'counter [1000 5] ; start, step
counter 4
} pause

demo {
; == CUSTOM CODE - FIBONACCI STREAMER ==

fib: stream 'code [
	a: 0 b: 1
	seq: func [][
		set [a b] reduce [b a + b]
		a
	]
]
fib 5} pause
demo {fib 5} pause

demo {
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
pri 5} pause
demo {pri 5} pause

demo {
; == FILE STREAMER ==

my-file: {The Stream Machine

A single point of raw intake,
A structure born for data's sake.
Through pipe and juxt the currents flow,
Where static blocks awake and grow.

From Ziggurat to shifting sand,
The random walk obeys command.
The cyclic colors spin in place,
While counters mark the bounded space.

Then came the code to break the mold,
Where hidden states are cleanly told.
With make and binding deep inside,
The sequence has no place to hide.

The Fibonacci numbers climb,
The primes step out one at a time.
"Yeah baby!" cries the macro king,
Watch how these lazy streams can sing!}

write %my-file.txt my-file

lines: stream 'code [
	fil: read/lines %my-file.txt
	cur: 0
	seq: func [][
		cur: cur + 1
		pick fil cur
	]
]

foreach l lines 2 [print l]} pause
demo {foreach l lines 5 [print l]} pause

