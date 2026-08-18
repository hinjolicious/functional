Red [
	title: "babylonian Spiral"
	author: "hinjolicious"
	note: "Adapted from Python's example, assistance from ChatGPT"
	needs: view
]

#include %../fp.red

two-squares: stream 'code [
	q: copy []  n: 1
	seq: func [/local s xy item a b][
		while [any [empty? q  (n * n) <= q/1/1]][
			append/only q reduce [n * n  n  0]  sort q ; simulate heapq push
			n: n + 1
		]
		s: q/1/1  xy: copy []
		
		while [all [not empty? q  q/1/1 = s]][ ; pop all vectors with same length.
			set [s a b] take q ; heapq pop
			append/only xy reduce [a b]
			if a > b [
				append/only q reduce [(a * a) + ((b + 1) * (b + 1))  a  b + 1]  sort q ; heapq push
			]
		]
		xy
	]
]

gen-dirs: stream 'code [
	d: [0 1]
	seq: func [/local v p a b][
		v: two-squares 1
		; include symmetric vectors
		append v collect [ foreach p v [ a: p/1  b: p/2  if a <> b [keep/only reduce [b        a]] ] ]
		append v collect [ foreach p v [ a: p/1  b: p/2  if b <> 0 [keep/only reduce [a negate b]] ] ]
		append v collect [ foreach p v [ a: p/1  b: p/2  if a <> 0 [keep/only reduce [negate a b]] ] ]

		; filter using dot and cross product
		d: next last sort collect [ foreach p v [ a: p/1  b: p/2  if ((a * d/2) - (b * d/1)) >= 0 [keep/only reduce [(a * d/1) + (b * d/2)  a  b]] ] ]
		d
	]
]

positions: stream 'code [
	p: [0 0]
	seq: func [/local d res][
		d: gen-dirs 1
		res: copy p
		p: reduce [p/1 + d/1  p/2 + d/2]
		to pair! res
	]
]

;probe 
pos: positions 40

drawing: append [scale 0.006 0.006 translate 80000x5000 line-width 50 pen green line] pos
win: view/tight/no-sync/no-wait [ title "babylonian Spiral - Scale (0.008 0.008)"
	canvas: base 1000x1000 black draw drawing
]

while [win/state][
	append drawing positions 200  show canvas
	do-events/no-wait
]
