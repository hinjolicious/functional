Red []

;== COMPLEX DATA TYPE ==

complex!: object [r: 0.0 i: 0.0 type: 'complex]

com-real: function [c][c/r]
com-imag: function [c][c/i]

complex: func [real imag][make complex! compose [r: (real) i: (imag)]]

com-add: func [c1 c2][complex (c1/r + c2/r) (c1/i + c2/i)]
com-sub: func [c1 c2][complex (c1/r - c2/r) (c1/i - c2/i)]
com-neg: func [c][complex (0 - c/r) (0 - c/i)]

com-mul: func [c1 c2] [
    ; Using the FOIL formula: (a*c - b*d) + (b*c + a*d)i
    complex
		(c1/r * c2/r) - (c1/i * c2/i) 
		(c1/i * c2/r) + (c1/r * c2/i)
]

com-div: func [c1 c2 /local denom][
	; Local variables to hold the denominator sum of squares
    denom: (c2/r * c2/r) + (c2/i * c2/i)
    
    ; Check for division by zero
    if denom = 0.0 [print "Error: Division by zero!" exit]
    
    ; Apply the complex division formula
    complex 
        ((c1/r * c2/r) + (c1/i * c2/i)) / denom
        ((c1/i * c2/r) - (c1/r * c2/i)) / denom
]

com-abs: func [c] [
    ; Pythagorean theorem for magnitude: sqrt(r^2 + i^2)
    sqrt (c/r * c/r) + (c/i * c/i)]
	
c-add: make op! function [a b][
    either any [all [object? a a/type = 'complex] all [object? b b/type = 'complex]][
        com-add either object? a [a][complex a 0.0] either object? b [b][complex b 0.0]
    ][add a b]
]
c+: :c-add

c-mul: make op! function [a b][
    either any [all [object? a a/type = 'complex] all [object? b b/type = 'complex]][
        com-mul either object? a [a][complex a 0.0] either object? b [b][complex b 0.0]
    ][multiply a b]
]
c*: :c-mul

c-sub: make op! function [a b][
    either any [all [object? a a/type = 'complex] all [object? b b/type = 'complex]][
        com-sub either object? a [a][complex a 0.0] either object? b [b][complex b 0.0]
    ][subtract a b]
]
c-: :c-sub

c-div: make op! function [a b][
    either any [all [object? a a/type = 'complex] all [object? b b/type = 'complex]][
        com-div either object? a [a][complex a 0.0] either object? b [b][complex b 0.0]
    ][divide a b]
]
cdiv: :c-div
	
