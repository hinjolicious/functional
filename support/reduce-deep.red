Red []

; reduce deeply
; NOTE: to evaluate an expression as one unit,
; you have to enclose it in paren!
; e.g.: reduce-deep [[pi]]
;		reduce-deep [[(sin pi)]] --> this will evaluate (sin pi) together!

reduce-deep: function [value [any-type!]] [
    either block? :value [
        collect [foreach item value [
			keep/only reduce-deep :item
		]]
    ][
        ; If it's a bound word or expression, evaluate it; otherwise return as-is
        ;either word? :value [get/any value][:value]
		;get/any value
		reduce value
    ]
]
