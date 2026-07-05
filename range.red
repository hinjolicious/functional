Red []

range: function [
	"Generate a series of numbers based on an integer or a spec block"
	rng [number! block!]
][
	case [
		number? rng [ collect [repeat i rng [keep i]] ]
		block? rng [
			case [ 
				(length? rng) = 1 [ collect [repeat i rng/1 [keep i]] ]
				(length? rng) = 2 [
					start: rng/1 stop: rng/2 
					either start > stop 
						[collect [i: start while [i >= stop][keep i i: i - 1]]]
						[collect [i: start while [i <= stop][keep i i: i + 1]]]
				]
				(length? rng) >= 3 [
					start: rng/1 stop: rng/2 step: rng/3
					
					; Guard against 0 step causing an infinite loop
					if step = 0 [ do make error! "Step cannot be zero" ]
					
					collect [
						i: start
						either step > 0 [
							while [i <= stop][
								; round to match step precision if it's a decimal
								keep either float? step [round/to i step][i]
								i: i + step
							]
						][
							; Handle negative steps gracefully (descending range)
							while [i >= stop][
								keep either float? step [round/to i step][i]
								i: i + step
							]
						]
					]
				]
			]
		]
		true [
			print ["*** Range Error: " mold rng]
			do make error! "Wrong argument!"
		]
	]
]

comment {
probe range 10			; [1 2 3 4 5 6 7 8 9 10]
probe range [10]		; [1 2 3 4 5 6 7 8 9 10]
probe range [5 10]		; [5 6 7 8 9 10]
probe range [0 1 0.1]	; [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
probe range [5 -5]		; [5 4 3 2 1 0 -1 -2 -3 -4 -5]
probe range [2 -2 -0.5]	; [2.0 1.5 1.0 0.5 0.0 -0.5 -1.0 -1.5 -2.0]
foreach i range [-2 2 0.5][print i]
; -2.0
; -1.5
; -1.0
; -0.5
; 0.0
; 0.5
; 1.0
; 1.5
; 2.0
}