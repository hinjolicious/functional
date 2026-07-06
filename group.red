Red []

#include %functional.red

; rule is [category1 cond1 catory2 cond2...]
; catogry: word, string, etc.
; cond: actions (function, code-block, etc.)
group: function [list rule][
	result: copy #[]
	foreach e list [
		foreach [g r] rule [
			if pipe e :r [
				either none? result/:g [
					result/:g: compose [(e)]
				][
					append result/:g e
				]
			]
		]
	]	
	result
]

comment {
probe [1 2 3 4 5 6] |> [group it [even [even? it] odd [odd? it]]]
;#[
;    odd: [1 3 5]
;    even: [2 4 6]
;]
}