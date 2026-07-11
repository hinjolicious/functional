Red []

#include %functional.red
;#include %support/misc.red

; Juxt(aposition) is a convenient and powerful tool
; to do multiple parallel data processing in one go.
; 
; data |> [juxt it [
;	process1
;	process2
;	...
; ]

juxt: func [list [series!] actions [block!]][
	collect [ foreach act actions [
		keep/only pipe list :act
	]]
]

comment {
;; Complex parallel evaluations inside juxt 
[1 2 3 4 5] |> [juxt it [
	sum							; native sum
	average						; native average
	[it >- add]					; sum fold
 	[>- [[a b] max a b]]		; max-of fold
	[>- [[a b] min a b]]		; min-of fold
	[ ||> [* 10] |> sum ]		; implicit pipeline stub
	[[x] x ||> [it / 2] |> sum] ; complex process
]]
;== [15 3 15 5 1 150 7.5]
}
