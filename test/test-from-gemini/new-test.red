Red []

#include %../../fp.red
#include %../../support/misc.red

demo {
;; 1. Filter preserves the type (e.g., string stays string)
"abcdefg" || even? |> probe
;== "bdf"
}
demo {
;; 2. Fold morphs into the accumulator's type (e.g., block to integer)
[1 2 3 4] >- add |> probe
;== 10
}
demo {
;; 3. Group transforms the sequence into an associative map!
"abcdefg" |> [group it ['ev [even? it] 'od [odd? it]]] |> probe
;== #(
;    odd: "aceg"
;    even: "bdf"
;)
}
demo {
; other demo:

; map now preserved original types:
"abcdefg" ||> uppercase
;== "ABCDEFG"
"abcdefg" ||> [it + 1] ||> uppercase
;== "BCDEFGH"
"abcdefg" ||> [either even? it [rejoin [it " "]][it]] 
;== "ab cd ef g"
}

demo {
; This is essentiall parallel mapping:
a: [1 2 3]
b: [10 20 30]
c: [100 200 300]
[a b c]|> reduce |> transpose ||> sum
;== [111 222 333]
}
