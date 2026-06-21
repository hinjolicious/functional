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
	"Pass a value through an action: value |> action"
	value	[any-type!]	"Value (literal, variable, block, etc.)"
	'action [any-type!]	"Action (function, 'code-block', variable, literal, etc.)"
][
	; list of operators used for the "Simple Code-Block" construct: [* 2]
	ops: [
		+ - * / ** // % << >> >>> 			; arith, math
		= == < > <= >= <> =? and or xor not ; comparison, logic
		in 									; series, context
	]

	case [
		; == WORD: Function or Variable
		word? action [
			either any-function? act: get action [ ; get what it refer to
				act value ; 1. Function, call it with the value: value |> sin
			][
				act		  ; 2. Variable, evaluate it (replace the value): value |> "hello"
			]
		]
		; == BLOCK: Simple Code-Block, Complex Code-Block, "It Template", etc.
		block? action [ 
			either empty? action [
				[] ; 1. Empty block, just return it: value |> []
			][
				case [
					word? arg: action/1 [ ; first element should be the argument(s) or operator
						either find ops arg [ 
							do compose [(value) (action)] ; 2. "Simple code-block": value |> [* 2] 
						][ ; something else?
							act: function [it] action	  ; 3. "It Template" (1): value |> [sin it * 2]
							act value 
						]
					]
					block? arg [ 
						act: function arg next action ; 5. "Complex Code-Block" construct
						switch/default length? arg [ ; how many arguments?
							0 [act] 		; 5.a No argument:		  value |> [[] pi]
							1 [act value] 	; 5.b Single argument:	  value |> [[x] sin x]
						][apply :act value] ; 5.c Multiple arguments: value |> [[x y] x + y]
					]
					true [ ; something else?
						act: function [it] action ; 6. "It Template" (2): [10 * it]
						act value
					]
				]
			]
		]
		true [action] ; 7. Literal: value |> "hello"
	]
] ; /pipe

; == MAP ==

MAP: function [
	"Pass list of values through an action: list ||> action"
	list	[any-type!]	"List of values (literal, variable, block, etc.)"
	'action [any-type!]	"Action (function, 'code-block', variable, literal, etc.)"
][
	collect [foreach val list [keep/only val |> :action]]
]

; == FILTER ==

FILTER: function [
	"Filter a list with an condition: list || [[x] even? x]"
	list [series!] "List of values"
	cond [block!]  "Condition"
][
	arg: cond/1 ; must at least has one argument
	act: function arg next cond ; construct a function
	
	either (length? arg) = 1 [	; 1. One argument: [1 2 3 4] || [[x] even? x]
		collect [foreach val list [
			if act val [keep/only val]
		]]
	][ 							; 2. Multiple arguments: [[3 2][1 4]] || [[a b] a > b] 
		collect [foreach val list [
			if apply :act val [keep/only val]
		]]
	]
] ; /filter

; == FOLD ==

FOLD: function [
	"Reduces a list to a value according to specified rule."
	list [series!]				"List of values"
	spec [block! any-function!]	"Speccification block or function [[acc args init] rule]"
][
	; == FUNCTION ==
	
	if any-function? :spec [ ; user or native function: x >- :add
		acc: first list
		foreach val next list [acc: spec acc val]
		return acc
	]

	; == SPEC INFO ==
	
	acc-name: spec/1/1 ; accumulator name
	arg-spec: spec/1/2 ; argument spec
	
	either 3 <= length? spec [	; has initial value of accumulator?
		acc: reduce spec/1/3	; evaluate it (literal, block, etc.)
	][
		acc: first list	; take first item as accumulator's initial value
		list: next list	; move to next item
	]
	body: next spec		; rule body

	; == FOLDING ENGINE ==
	
	either word? arg-spec [
	
		; == A: Single Element Mapping: [acc x] or [acc x 100]
		action: function reduce [acc-name arg-spec] body
		foreach val list [acc: action acc val]
	][
		; == B: Dynamic Chunk Destructuring: [acc [a b c]] or [acc [a b c] [0 0 0]]
		
		chunk-size: length? arg-spec
		action: function compose [(acc-name) (arg-spec)] body

		either block? first list [
		
			; == B1: Smart Matrix Unpacking (Natural Rows)
            foreach row list [
			
                ; Shape Guard: Ensure the nested block matches expected parameters
                if (length? row) <> chunk-size [
                    print ["*** Shape Error: Row length doesn't match" chunk-size]
                    print ["*** Offending row:" mold row]
                    do make error! "Mismatched row shape in matrix fold"
                ]
				
                args: append compose/only [(acc)] row
                acc: apply :action args
            ]			
		][	
			; == B2: Flat Chunking
			while [not tail? list] [
				chunk: copy/part list chunk-size
				
				; Shape Guard: Ensure the flat remainder isn't partial
                if (length? chunk) < chunk-size [
                    print ["*** Shape Error: Flat remainder doesn't fill chunk size" chunk-size]
                    print ["*** Offending remainder:" mold chunk]
                    do make error! "Mismatched data shape in flat fold chunking"
                ]
				
				; Build evaluation arguments: accumulator followed by chunk items
				args: append compose/only [(acc)] chunk
				acc: apply :action args
				list: skip list chunk-size
			]
		]	
	]
	acc
] ; /fold

; == OPERATORS ==

|>:	 	make op! :PIPE	 ; Pipe Operator: x |> sin |> [* pi] or [10 20] |> [[a b] a * b], etc.
!:	 	:|>				 ; Alias for pipe operator
||>: 	make op! :MAP	 ; Mapping operator: [1 2 3] ||> [/ 10] ||> sin ||> [[x] x ** 2 - x] 
||:	 	make op! :FILTER ; Filter operator: 
fold>:	make op! :FOLD	 ; Fold operator
>-:		:fold>			 ; Alias for fold operator

; /functional.red
