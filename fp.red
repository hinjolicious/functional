Red []

; handy include files to other files

#include %functional.red			; main functional cores

; Red's Specific Extensions
#include %support/increment.red		; ++ i, -- i, incr i, decr i, etc.
#include %support/for-loop.red		; c-style for loop (do-for, while-step)
#include %support/safe-assign.red	; safe left-to-right assignment: val --> var
#include %support/reduce-deep.red	; reduce deeply

; FP Extensions
#include %range.red		; range generator
#include %chunk.red		; block chunking, etc.
