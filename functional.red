Red [
	Title: "Functional Programming Library"
	File: "functional.red"
	Author: "hinjolicious"
	Purpose: "Support for functional programming paradigm in Red language."
	Content: {
		* Piping / pipelining	"hello" |> uppercase
		* Mapping 				[1 2 3] ||> [* 2]
		* Filtering 			[1 2 3] || even?
		* Folding (reduce) 		[1 2 3] >- add
	}
	Version: 5
	History: {
		- Dropped automatic flat chunking in 'fold', use 'chunk' (chunk-block).
	}
	Note: {
		* This project contains assistance/insights/references from Gemini AI, Red/Sensei, etc.
		* Main ideas and designs are from myself.
	}
	Tabs: 4
]

;=============
PIPE: function [
;=============
	"Proces value by action(s) (chainable): value |> action1 |> action2 ..." 
	value	"Value: literal, variable, block, etc."
	'action "Action: function, code-block, variable, literal, etc."
][
	case [
		; 1. FUNCTION VALUE
		any-function? :action [:action] ; e.g.: 5 |> :sin ;replace value with sin function value 
		; don't make sense? this is an engine, you're responsible in what you're doing with it!
		
		; 2. WORD: Function or Variable
		word? action [
			either any-function? act: get action [ ; get what it refer to
				; 2.1 Function: call it with the value, e.g.: value |> sin ; sin is called, not assigned! make sense?
				act :value	
			][
				; 2.2 Variable, evaluate it (replace the value), e.g.: value |> "hello" ; again, it's your action!
				act			
			]
		]
		; 3. PATH
		path? action [ 
			do compose [(action) value] ; for direct execution, e.g.: [1 2 3] |> sort/reverse
		]			
		; 4. BLOCK: Simple Code-Block, Complex Code-Block, "It Template", etc.
		block? action [ 
			either empty? action [
				[] ; 4.1 Empty block, just return it, e.g.: value |> [] ; again, your action should make sense for your self!
			][
				case [
					word? arg: action/1 [ ; first element should be the argument(s) or operator
						either op? get arg [ 
							; 4.2 "Simple code-block", e.g.: value |> [* 2] 
							do compose [(value) (action)] 
						][ ; something else?
							act: function [it] action ; 4.3 "It Template" (1): value |> [sin it * 2]
							act value 
						]
					]
					block? arg [ 
						; 4.5 "Complex code-block" construct (full-fledged literal function / lambda)
						act: function arg next action 
						switch/default length? arg [ ; how many arguments?
							0 [act]			; 4.5.a No argument, e.g.:		  value |> [[] pi]
							1 [act value]	; 4.5.b Single argument, e.g.:	  value |> [[x] sin x]
						][apply :act value] ; 4.5.c Multiple arguments, e.g.: value |> [[x y] x + y]
					]
					true [ ; something else?
						act: function [it] action ; 4.6 "It Template" (again), e.g.: [10 * it]
						act value
					]
				]
			]
		]
		; 5. LITERAL 
		true [action] ; Literal: value |> "hello" ; it always back to your intentions!
	]
] ; /pipe

|>: make op! :PIPE ; Pipe Operator: x |> sin |> [* pi] or [10 20] |> [[a b] a * b], etc.

;============
MAP: function [
;============
	"Process each values in a list by action(s) (chainable): list ||> action1 ||> action2 ..."
	list	"List of values: literal, variable, block, etc."
	'action	"Action: function, code-block, variable, literal, etc."	
][
	collect [foreach val list [keep/only pipe val :action]]
]

||>: make op! :MAP ; Mapping operator: [1 2 3] ||> [/ 10] ||> sin ||> [[x] x ** 2 - x] 

;===============
FILTER: function [
;===============
	"Filter a list by condition(s) (chainable): list || cond1 || cond2 ..."
	list [series!] "List of values"
	'cond [block! word! lit-word!]	"Condition"
][
	collect [foreach val list [
		if (pipe val :cond) [keep/only val]
	]]
] ; /filter

||: make op! :FILTER ; Filter operator: 

;=============
FOLD: function [
;=============
	"Fold (reduce) list to values by rules (chainable): list >- rule1 >- rule2 ..."
	list [series!]					"List of values"
	'spec [block! word! lit-word!]	"Speccification block or function [[acc args init] rule]"
][
	safe-init: func [val] [ ; safe init for accumulator
		either any [series? :val map? :val object? :val bitset? :val][copy val][:val] 
	]
	
	; 1. WORD
	if word? spec [
		acc: safe-init first list ; take first item as accumulator initial value
		either any-function? act: get spec [
			foreach val next list [
				acc: act acc :val	; 1.1 Function call, e.g.: [1 2 3] >- add 
			]
		][
			foreach val next list [
				acc: act acc		; 1.2 Variable, replace, e.g.: [1 2 3] >- pi ; you know what you're doing!
			]
		]
		return acc
	]
	
	; 2. SPEC INFO BLOCK: format is [[acc x init] rule] or [[acc [a b c] init] rule]
	acc-name: spec/1/1 ; accumulator name
	arg-spec: spec/1/2 ; argument spec
	
	either (length? spec/1) >= 3 [ ; has init?
		acc: safe-init reduce spec/1/3	; 2.1 has init, evaluate it (literal, block, etc.)
	][
		acc: safe-init first list		; 2.2 no init, use first item as init
		list: next list					; move to next item
	]
	body: next spec						; rule body

	; 3. FOLDING ENGINE
	either word? arg-spec [
		; 3.1 Single Argument: [acc x] or [acc x 100]
		action: function reduce [acc-name arg-spec] body
		foreach val list [
			acc: action acc :val ; e.g.: [1 2 3] >- [[acc x] acc + x]
		]
	][
		; 3.2 Multiple Arguments: Dynamic Chunk Destructuring: [acc [a b c]] or [acc [a b c] [0 0 0]]
		chunk-size: length? arg-spec
		action: function compose [(acc-name) (arg-spec)] body
		; 3.2.1 Smart Matrix Unpacking (Natural Rows)
		foreach row list [
			; Shape Guard: Ensure the nested block matches expected parameters
			if (length? row) <> chunk-size [
				print ["*** Shape Error: Row length doesn't match" chunk-size]
				print ["*** Offending row:" mold row]
				do make error! "Mismatched row shape in matrix fold"
			]
			args: append compose/only [(acc)] row
			acc: apply :action args ; e.g.: [[1 2][3 4]] >- [[acc [a b]] reduce [acc/1 + a acc/2 + b]]
		]			
	]
	acc
] ; /fold

>-: make op! :FOLD ; Fold operator

; OPERATORS (summary)

; |>:	make op! :PIPE		; Pipe Operator: x |> sin |> [* pi] or [10 20] |> [[a b] a * b], etc.
; ||>:	make op! :MAP		; Mapping operator: [1 2 3] ||> [/ 10] ||> sin ||> [[x] x ** 2 - x] 
; ||:	make op! :FILTER	; Filter operator: 
; >-:	make op! :FOLD		; Fold operator

; /functional.red
