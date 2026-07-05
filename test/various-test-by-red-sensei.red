Red []

#include %../fp.red

; fold with function
x: [1 2 3 4 5] >- add ; 15

; fold with code-block
x: [1 2 3 4 5] >- [[acc x] acc + x] ; 15

; fold with destructuring, with chunking
x: [1 2 3 4 5 6 7 8 9 10] 
	|> [chunk it 2] 
	>- [[acc [a b] 0] acc + (a * b)]
;== 190

; fold to a block
x: [1 2 3 4 5 6 7 8 9 10] 
	|> [chunk it 2] 
	>- [[acc [a b] [0 0]] reduce [acc/1 + a acc/2 + b]]
;== [25 30]

; Edge cases:

; fold on empty block
[] >- add ;== none

; fold on a single element
[42] >- add ;== 42

; mapping

[1 2 3 4 5 6 7 8 9 10] ||> [[x] x * x] 
;== [1 4 9 16 25 36 49 64 81 100]

; map, filter, fold
[1 2 3 4 5 6 7 8 9 10] 
	||> [[x] x * x] 
	|| [[x] x > 20] 
	>- [[acc x 0] acc + x]
;== 355

; string

"hello" |> uppercase           ; obviously: uppercase "hello"
;== "HELLO"

"hello" |> [[s] reverse s]      ; lambda block
; "olleh"

"hello" |> [append it "!"]           ; ← what about this? add as first arg?
;== "hello!"

[1 2 3] |> rejoin     ; nd9600 style
; "123"

"ABC"   |> lowercase  ; official mezz style
; "abc"


[1 2 3 4 5 6 7 8 9 0] |> [filter it [even? it]]         ; way nicer than [[x] filter x :even?]
;== [2 4 6 8 0]

"hi" |> [append it "!"]
;== "hi!"

; 1. 
;"hello" |> [it |> [append it "!"]] ; unnecessary, it produce error!
"hello" |> [|> [append it "!"]] ; use this way!
;== "hello!"

; 2. it locality
it: "ambient"
; "ambient"
"x" |> [append it "y"]              ; uses ambient `it` or pipe's `it`?
; "xy"

; 3. it in map lambdas too?
[1 2 3] ||> [it * it]               ; would be lovely if this worked
;== [1 4 9]

; 4. fold + it? --> it didn't work in fold, fold use explicit argument names!

;[1 2 3 4 5] >- [acc + it]           ; didn't worked
[1 2 3 4 5] >- [[acc it] acc + it]   ; use explicit naming to whatever you want
; 15

[1 2 3] |> [filter it [it > 1]]
;[2 3]

; edge cases

[] ||> [it * 2]    
; []

[] || [even? it]  
; []

[] |> length?    
; 0


"abc" ||> [uppercase form it]   
; ["A" "B" "C"]

#{0102} ||> [it + 1]   
; [2 3]

[1 2 3] ||> [print it  it * 2]         ; does print fire 3 times?
;1
;2
;3
;== [2 4 6]

[[1 2][3 4]] ||> [it ||> [it * 10]]    ; → [[10 20][30 40]]?
; [[10 20] [30 40]]

;none |> uppercase ; ERROR!

;[1 2 3] ||> nothing ; ERROR!

[1 2 3] ||> [it: it * 2 it + 1]
; [3 5 7]

;map-each x [a b c] [uppercase form x] 
;; ["A" "B" "C"]
[a b c] ||> form ||> uppercase
; ["A" "B" "C"]

;map-each x [1 + 2 * 3] [type? x]
;; [integer! word! integer! word! integer!]
[1 + 2 * 3] ||> type?
; [integer! word! integer! word! integer!]

; ; more test

double: func [x][x * 2]
;== func [x][x * 2]
b: 2
;== 2
[1 b pi] ||> [* 2]
;== [2 4 6.283185307179586]
10 |> negate ; -10
;== -10
10 |> [[x] x * 2] ; 20
;== 20
10 |> [* 3] ; 30
;== 30
10 |> [[v] either v > 5 ["Big"]["Small"]] ; "Big"
;== "Big"
[10 20] |> [[a b] a + b]
;== 30

; ; matrix manipulation example

[1 2 3 4] ||> [[x] x ** 2]
; [1 4 9 16]
[[1 2][3 4][5 6]] ||> [[a b] a + b]
; [3 7 11]

; re-arrange elements in each row
[ [1 2 3 4] [5 6 7 8] ] ||> [[a b c d] reduce-deep [a c b d]]
; [[1 3 2 4] [5 7 6 8]]

; re-arrange elements and put it into deeper sub-block 
[ [1 2 3 4] [5 6 7 8] ] ||> [[a b c d] reduce-deep [[a c][b d]]]
; [[[1 3] [2 4]] [[5 7] [6 8]]]

; simple matrix transpose
[ [1 2 3] [4 5 6] ] |> [[a b] reduce-deep [[a/1 b/1][a/2 b/2][a/3 b/3]]]
; [[1 4] [2 5] [3 6]]

mat: [ [1  2  3  4] 
	   [5  6  7  8] 
	   [9 10 11 12] ] 
	   
mat |> [[a b c] 
	collect [repeat i length? a [
		keep/only reduce [a/:i b/:i c/:i]
	]]
] 
; [[1 5 9] [2 6 10] [3 7 11] [4 8 12]]
mat |> [[m] 
	collect [repeat i length? m/1 [
		keep/only collect [repeat j length? m [
			keep reduce [m/:j/:i]
		]]	
	]]
]
; [[1 5 9] [2 6 10] [3 7 11] [4 8 12]]


;; FOLD ==
 
[1 2 3 4 5] >- add 
;== 15

[1 2 3 4 5] >- [[acc x 100] acc + x]
;== 115

[1 2 3 4 5 6] |> [chunk it 3] >- [
	[acc [a b c] []] 
		append/only acc reduce [a + b + c]
]
;; [[6] [15]]

; No flat chunking, use 'chunk'
[1 2 3 4 5 6] |> [chunk it 2] >- [[acc [a b] 0] acc + (a * b)]
; 44  ; (1*2) + (3*4) + (5*6) -> 2 + 12 + 30

[[1 2] [3 4] [5 6]] >- [[acc [a b] 0] acc + (a * b)]
;== 44
