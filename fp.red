Red []

; handy include files to other files

#include %functional.red			; main functional cores

; Red's Specific Extensions
#include %support/safe-assign.red	; safe left-to-right assignment: val --> var
#include %support/split-block.red	; block chunking, etc.
#include %support/reduce-deep.red	; reduce deeply

; FP Extensions
#include %range.red		; range generator
