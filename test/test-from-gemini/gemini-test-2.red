Red []

#include %../../fp.red
#include %../../support/misc.red

test {
;Test Suite 1: Type Preservation & Edge Cases (|| and >-)

;; 1. Heterogeneous vector vs string preservation

type? "abc" || [it = #"b"] 
} type? "abc"

test {
type? make vector! [1 2 3] || [it > 1]
} type? make vector! [1 2 3]

test {
;; 2. Filter resulting in empty collections (should preserve type)

"abcdef" || [it == #"z"]
} ""

test { 
[1 2 3 4] || [it > 10] 
} []

test {
;; 3. Fold over single-element collection

[42] >- add 
} 42
pause

test {
;Test Suite 2: Irregular Spreading & Matrix Resampling (zip and transpose)

;; 1. Even-spreading zip: Perfect algorithmic distribution
;; Assumes 'zip/spread' or equivalent syntax for your spreading strategy

zip/duplicate [[1 2 3 4] [10 20]]
} [[1 10] [2 10] [3 20] [4 20]]

test { 
;; 2. Transpose non-square (N x M) matrix
;; 2 rows x 3 columns -> should become 3 rows x 2 columns

matrix-2x3: [[1 2 3] [4 5 6]]
matrix-2x3 |> transpose
} [[1 4] [2 5] [3 6]]
pause

test {
;Test Suite 3: Advanced Composition & Juxtaposition (juxt and comp-funcs)

;; 1. Complex parallel evaluations inside juxt 

result: [2 4 6 8] |> [juxt it [
    sum                                    ; Point-free word (20)
    [it >- add]                            ; Funnel fold (20)
    [ ||> [* 10] |> sum ]                  ; Implicit pipeline stub (200)
    [[x] x ||> [it / 2] |> sum]            ; Explicit input block (10)
]]
result
} [20 20 200 10]

test {
;; 2. Multi-function composition pipeline execution
;; f(g(h(x))) logic

add-five:  func [x] [x + 5]
double-it: func [x] [x * 2]
square-it: func [x] [x * x]

pipeline: comp-funcs [add-five double-it square-it]
;; (3 + 5) -> 8 -> * 2 -> 16 -> squared -> 256
pipeline 3 
} 256

