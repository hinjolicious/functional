Red [
	title: "Babylonian Spiral"
	author: "hinjolicious"
	note: "Adapted from Python's example, assistance from ChatGPT + Gemini"
	needs: view
]

; using lazy-stream generator function
#include %../fp.red ; https://github.com/hinjolicious/functional

two-squares: stream 'code [
	q: copy []	n: 1
	seq: func [/local s xy item a b][
		while [any [empty? q  (n * n) <= q/1/1]][
			append/only q reduce [n * n	 n	0]	sort q
			n: n + 1
		]
		s: q/1/1  xy: copy []
		
		while [all [not empty? q  q/1/1 = s]][
			set [s a b] take q
			append/only xy reduce [a b]
			if a > b [
				append/only q reduce [(a * a) + ((b + 1) * (b + 1))	 a	b + 1]	sort q
			]
		]
		xy
	]
]

gen-dirs: stream 'code [
	d: [0 1]
	seq: func [/local v p a b][
		v: two-squares 1
		append v collect [ foreach p v [ a: p/1	 b: p/2	 if a <> b [keep/only reduce [b a]] ] ]
		append v collect [ foreach p v [ a: p/1	 b: p/2	 if b <> 0 [keep/only reduce [a negate b]] ] ]
		append v collect [ foreach p v [ a: p/1	 b: p/2	 if a <> 0 [keep/only reduce [negate a b]] ] ]

		d: next last sort collect [ 
			foreach p v [ 
				a: p/1	b: p/2	
				if ((a * d/2) - (b * d/1)) >= 0 [
					keep/only reduce [(a * d/1) + (b * d/2)	 a	b]
				] 
			] 
		]
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

; output first 40 points
pos: positions 40

win: view/tight/no-sync/no-wait [ 
	title "Babylonian Spiral"
	canvas: base 1500x1000 black draw []
]

while [win/state][
	append pos positions 1000 ; burst 1000 points
	
	min-x: max-x: pos/1/x
	min-y: max-y: pos/1/y
	foreach pt pos [
		if pt/x < min-x [min-x: pt/x]
		if pt/x > max-x [max-x: pt/x]
		if pt/y < min-y [min-y: pt/y]
		if pt/y > max-y [max-y: pt/y]
	]
	
	w: max 1 (max-x - min-x)
	h: max 1 (max-y - min-y)
	sc: min (1400.0 / w) (900.0 / h)

	canvas/draw: compose/deep [
		push [ pen white
			text 10x10 (rejoin ["width: " w " height: " h " scale: " sc])
		]
		translate 750x500 scale (sc) (sc)
		translate (as-pair (0 - ((min-x + max-x) / 2)) (0 - ((min-y + max-y) / 2)))
		line-width (.5 / sc)
		pen green line (pos)
	]
	show canvas
	do-events/no-wait
]