Red []
; pass by reference

incr: function ['x][
	case [
		word? x [set x (get x) + 1]
		block? x [
			var: x/1 step: x/2
			set var (get var) + step
		]
	]
]
decr: function ['x][
	case [
		word? x [set x (get x) - 1]
		block? x [
			var: x/1 step: x/2
			set var (get var) - step
		]
	]	
]
increment: :incr
decrement: :decr
++: :incr
--: :decr
set-val: function ['var val][set var :val]

comment {
i: 0
probe incr i
probe decr i
probe ++ i
probe -- i
probe set-val i 100
probe ++ [i 2]
probe -- [i 10]
}


