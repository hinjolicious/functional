Red [
	Title: "Functional Cores"
	Author: "hinjolicious"
	Purpose: "Add functional programming paradigms to the Red language"
	Credits: "Gemini AI"
	Tabs: 4
	Content: {
		* Piping / pipelining suport
		* Mapping support
		* Filtering support
		* Folding support
	}
]

; == PIPE ==

PIPE: function [
	x  [any-type!]	"Value or values (literal, variable, block, etc.)"
	'f [any-type!]	"Actions (function, 'code-block', variable, literal, etc.)"
][
	; list of operators used for the "Simple Code-Block" construct: [* 2]
	ops: [
		+ - * / ** // % << >> >>> 			; arith, math
		= == < > <= >= <> =? and or xor not ; comparison, logic
		in 									; series, context
	]

	case [
		; == WORD: Function or Variable
		word? f [
			ff: get f
			either any-function? :ff [
				ff x ; 1. Function, call it with the value: x |> sin
			][
				ff	 ; 2. Variable, evaluate it (replace the value): x |> "hello"
			]
		]
		; == BLOCK: Simple Code-Block, Complex Code-Block, "It Template", etc.
		block? f [ 
			either empty? f [
				[] ; 1. Empty block, just return it: x |> []
			][
				a: f/1 ; first element should be the argument(s) or operator
				case [
					word? a [ 
						either find ops a [ 
							do compose [(x) (f)] ; 2. "Simple code-block": x |> [* 2] 
						][ ; something else?
							ff: function [it] f  ; 3. "It Template" (1): x |> [sin it * 2]
							ff x 
						]
					]
					block? a [ 
						la: length? a ; how many arguments?
						ff: function a next f ; 5. "Complex Code-Block" construct
						switch/default la [
							0 [ff] 		; 5.a No argument:		  x |> [[] pi]
							1 [ff x] 	; 5.b Single argument:	  x |> [[x] sin x]
						][apply :ff x] 	; 5.c Multiple arguments: x |> [[x y] x + y]
					]
					true [ ; something else?
						ff: function [it] f ; 6. "It Template" (2): [10 * it]
						ff x
					]
				]
			]
		]
		true [f] ; 7. Literal: x |> "hello"
	]
] ; /pipe

; == MAP ==

MAP: function [
	x  [any-type!] 
	'f [any-type!]
][
	collect [foreach e x [keep/only e |> :f]]
]

; == FILTER ==

FILTER: function [
	x [series!] 
	f [block!]
][
	a: f/1 ; arguments must be present and at least has one
	ff: function a next f ; construct a func
	
	either (length? a) = 1 [	; 1. One argument: [1 2 3 4] || [[x] even? x]
		collect [foreach e x [
			if ff e [keep/only e]
		]]
	][ 							; 2. Multiple arguments: [[3 2][1 4]] || [[a b] a > b] 
		collect [foreach e x [
			if apply :ff e [keep/only e]
		]]
	]
]

; == OPERATORS ==

|>:	 make op! :PIPE	  ; Pipe Operator: x |> sin |> [* pi] or [10 20] |> [[a b] a * b], etc.
!:	 :|>			  ; Alias for pipe operator
||>: make op! :MAP	  ; Mapping operator: [1 2 3] ||> [/ 10] ||> sin ||> [[x] x ** 2 - x] 
||:	 make op! :FILTER ; Filter operator: 

; /functional.red