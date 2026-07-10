Red []

; handy include files to other files

#include %functional.red			; main functional cores

; Red's Specific Extensions
#include %support/increment.red		; ++ i, -- i, incr i, decr i, etc.
#include %support/for-loop.red		; c-style for loop (do-for, while-step)
#include %support/safe-assign.red	; safe left-to-right assignment: val --> var
#include %support/reduce-deep.red	; reduce deeply
#include %support/flatten.red		; flatten nested block
#include %support/slice.red			; slice / splice block

; FP Extensions
#include %range.red		; range generator
#include %chunk.red		; block chunking, etc.
#include %curry.red		; curry
#include %partial.red	; PFA
#include %transpose.red	; transpose a matrix
#include %zip.red		; zip data stream, auto-filled
#include %lc.red		; list comprehension
#include %group.red		; grouping engine
#include %comp-func.red ; functional compositions (functions chaining)
