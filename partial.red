Red [
	Title: "Partial Function Application in Red"
	Version: 2.4.5
	Author: "hinjolicious"
	Purpose: "Provide easy PFA functionality in Red"
	Features: {
		1. Fixing/closures of multiple arguments at the same time, e.g.: f: partial^ foo [1 2 3]
		2. Skipping arguments using "_" as a placeholders, e.g.: f: partial^ foo [_ _ 3]
		3. Handle refinements, e.g.: f: partial^ foo [_ 1 /ref 1 _ 3]
		4. Do PFA on normal and native functions
		5. Generate docstring for the PFA'd functions, e.g.: f: partial^/doc foo [1]
		6. PFA using the original function or a annonymous copy, e.g.: f: partial^/anon foo [1]
	}
	Usage: {
		1. foo: func [a b c d][a + b + c + d]		; a normal function
		   f: partial^ foo [1 2]					; fixing a & b
		2. f: partial^ foo [_ 2]					; skip a, fix b
		3. f: partial^ bar [1 2 /plus 5 /square]	; refinements support
		4. half: partial^ divide [_ 2]				; PFA a native function
		5. square: partial^/doc power [_ 2]			; generate PFA info
		6. f: partial^/anon bar [1 _ 3]				; using annonymous copy
	}
	Limitation: {
		1. Check your original function before PFA on it.
		2. Error handling is minimal and forwarded to the original functions or Red's own error handling.
		3. This for educational purpose, use at your own risks.
	}
]

PARTIAL: context [

;=== Helper functions (internal only) ===

;-- parse PFA spec
parse-pfa-spec: function [
	"Parse PFA specification and refinements"
	spec [block!]
][
	args: copy []
	refs: make map! []
	current-ref: none
	
	parse spec [
		any [
			; handle refinements
			set refinement refinement! (
				refinement: to-word refinement
				current-ref: refinement
				put refs current-ref copy []
			)
			|
			; handle placeholders (_)
			quote _ (
				either current-ref 
					[ append select refs current-ref '_ ]
					[ append args '_ ]
			)
			|
			; handle literal values
			set value [integer! | float! | string! | word! | block! | path!] (
				either current-ref 
					[ append/only select refs current-ref value ]
					[ append/only args value ]
			)
			|
			skip
		]
	]
	reduce [args refs]
]

;-- parse spec from the original function, and separate into [args] and #[refs_map]
parse-spec: function [
	"Parse function spec, tracking multi-arg refinements"
	spec [block!]
][
	args: copy []
	refs: make map! []
	current-ref: none
	in-local?: false
	in-extern?: false
	
	parse spec [
		any [
			; handle mode switches
			set current-ref refinement! (
				if (to-word current-ref) = 'local  [in-local?:	true]
				if (to-word current-ref) = 'extern [in-extern?: true]
				unless any [in-local? in-extern?] [
					put refs current-ref copy [] ; initialize with empty block
				]
			)
			| 
			; capture arguments (including multi-refinement args)
			if (all [not in-local? not in-extern?]) [
				set arg word! (
					either current-ref 
						[append select refs current-ref arg] ; add to refinement's args
						[append args arg]
				)
			]
			| skip
		]
	]
	reduce [args refs] ; args: [a b], refs: #[/plus [c d] /square []]
]

;=== Public function (exposed) ===

partial^: function [
	{PFA function with multiple arguments closures, skipping arguments, handle refinements.}
	'fn [word!]				"Function name"
	pfa_spec [block!]		"PFA specification with placeholders and refinements [1 _ 3 /plus 4 /min 5]"
	/doc					"Create docstring"
	/anon					"Using function's anonymous copy"
][
	parsed_pfa_spec: parse-pfa-spec pfa_spec ; from parse-pfa-spec
	pfa_args: parsed_pfa_spec/1 ; positional args [1 _ 3]
	pfa_refs: parsed_pfa_spec/2 ; refinements as map #[ add3: [_ 2 3] ]
	
	func_spec: parse-spec spec-of get fn ; spec info of the original function
	func_args: func_spec/1 ; positional args
	func_refs_map: func_spec/2 ; refinements as map #[ /add1 [r1] /add2 [s1 s2] ... ]

; 1. process positional args

	fixed_args: make map! [] ; to store name and val of fixed args
	remaining_args: copy []	 ; open args for the curried function
	pos: 1

	foreach arg func_args [ ; walk thru each pos args
		case [
			pos > length? pfa_args [
				append remaining_args arg ; no more PFA, add to remaining
			]
			pfa_args/:pos = '_ [
				append remaining_args arg ; placeholder, add to remaining
				pos: pos + 1
			]
			true [
				put fixed_args arg pfa_args/:pos ; store fixed arg's name and value
				pos: pos + 1
			]
		]
	]

; 2. process refinements

	applied_ref_args: copy [] ; to store applied refinement args
	ref_string: copy "" ; build refinement string

	foreach [ref_name ref_args] to-block pfa_refs [

		append ref_string rejoin ["/" ref_name] ; add refinement to call string
		original_ref_args: func_refs_map/(to-refinement ref_name) ; get the original refinement's argument names

		foreach arg_name original_ref_args [ ; process each argument of this refinement
			case [
				empty? ref_args [ ; no more args provided
					append remaining_args arg_name
					append applied_ref_args arg_name
				]
				ref_args/1 = '_ [
					append remaining_args arg_name ; placeholder becomes the actual arg name
					append applied_ref_args arg_name
					ref_args: next ref_args
				]
				true [
					append/only applied_ref_args ref_args/1 ; fixed refinement value
					ref_args: next ref_args
				]
			]
		]
	]

; 3. process applied args

	applied-args: collect [
		foreach arg func_args [
			either val: select fixed_args arg [
				keep/only val ; preserves the block structure
			][
				keep arg ; unfixed args remain as words
			]
		]
	]

; 4. docstring generation

	if doc [ ; add docstring
		insert remaining_args rejoin [ "PFA by: partial^^ " (:fn) " " (mold pfa_spec) ] 
	]
	
; 5. PFA function construction:
; /anon to use annonymous copy of the original function

	do compose/deep [ 
		function [(remaining_args)] [ 
			( load rejoin [ (mold either anon [get fn][:fn]) (ref_string) ] ) (applied-args) (applied_ref_args) 
		] 
	]
]
]; end of PFA'ing context

;=== Public API ===

partial^:	:partial/partial^ ; the PFA func
p^:			:partial^ ; short-cut name for it

;=== end of PFA module ===
