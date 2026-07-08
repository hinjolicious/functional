Red []

; Generates 'range' for use in foreach loop (or other purposes)
;
; e.g.: foreach i range [-5 5 0.5] [ print i ]

range: function [
	"Generate a series of numbers based on an integer or a spec block"
	rng [number! block!]
	/local start stop step
][
	make vector! case [
		number? rng [ collect [repeat i rng [keep i]] ]
		block? rng [
			foreach e rng [
				if not number? e [ 
					print "ERROR! range: start, stop and step must be a number!"
					;invalid-arg: ["invalid argument:" :arg1]
					cause-error 'script 'invalid-arg [rng]
				]
			]	
			case [ 
				1 = length? rng [ collect [repeat i rng/1 [keep i]] ]
				2 = length? rng [
					set [start stop] rng 
					either start > stop [
						collect [i: start while [i >= stop][keep i i: i - 1]]
					][
						collect [i: start while [i <= stop][keep i i: i + 1]]
					]
				]
				3 <= length? rng [
					set [start stop step] rng
					if step = 0 [
						print "ERROR! range: step must be non-zero!"
						;invalid-arg: ["invalid argument:" :arg1]
						cause-error 'script 'invalid-arg [rng]						
					]
					collect [
						i: start
						either step > 0 [
							while [i <= stop][
								; round to match step precision if it's a decimal
								keep either float? step [round/to i step][i]
							i: i + step
							]
						][
							while [i >= stop][
								keep either float? step [round/to i step][i]
							i: i + step
							]
						]
					]
				]
			]
		]
	]
]

comment {

range [1 0 -0.1]
;== make vector! [1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0.0]

foreach i range [-1 1 0.25][prin [i ""]]
;-1.0 -0.75 -0.5 -0.25 0.0 0.25 0.5 0.75 1.0 >> 

}