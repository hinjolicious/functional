Red [ "Compose Two or Any Number of Functions" ]

; compose two functions (left-to-right flow)
; value |> f1 |> f2 

; Usage: 
;	comp-func 'f1 'f2 --> call by names
;	comp-func :f1 :f2 --> embed functions

comp-func: func [f1 [word! any-function!] f2 [word! any-function!]][
	func [x] compose [(:f2) (:f1) x]
] 

; compose any number of functions (left-to-right flow)
; value |> f1 |> f2 |> f3 ...
;
; Usage: 
;	comp-funcs [f1 f2 f3 ...] --> call by names
;	comp-funcs reduce [:f1 :f2 :f3 ...] --> embed functions
;
comp-funcs: func [ff [block!]][
	func [x] compose append collect [foreach e reverse ff [keep (e)]] 'x
] 

comment {
sin-cos: comp-func 'sin 'cos
print sin-cos 0.5 

log-sin-cos: comp-funcs [log-e sin cos]
print log-sin-cos 0.5 
}