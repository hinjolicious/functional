Red []

#include %../../functional.red
#include %../../support/misc.red

demo {
; == HARDER TESTS from Gemini AI ==

;1. The Context Blind Spot (Self-Referencing Words)

;Red words carry their context with them. If a user defines a local variable inside a function that shares a name with a native function, or passes an active object method into the pipeline, it tests if your macro preserves local lexical bindings or forces global/dynamic binding resolution.

demo-context: func [val] [
    it: "outer-env" ; Local variable named 'it
    [10 20] ||> [val + it] ; Does 'it' mean 10 or "outer-env"?
]
probe demo-context 5
;[15 25]

;	* The Challenge: Does your library's internal binding of it aggressively overwrite all instances of the word it in the block, or does it respect pre-existing local bindings? (Expected output if it treats it as the pipeline element: [15 25]).
}

demo {
;2. The Type-Shifting Vector (Homogeneous vs. Heterogeneous)

;Red has strict internal constraints for vector! types compared to standard block! series. A vector must remain homogeneous. If you pipeline a vector, your code needs to handle operations that might attempt to change the type or evaluate to an invalid format.

vec: make vector! [1 2 3]

;; Case A: Math stays in type
vec ||> [it * 2.5] |> probe 
;make vector! [2.5 5.0 7.5] ; element changed, but result still a vector

;; Case B: Type violation inside pipeline
;vec ||> [form it] |> probe ; this caused error!

;	* The Challenge: Does your mapping engine dynamically unpack the vector! into a block, or does it try to modify/rebuild it in place? If it does it in place, Case A might error due to a float conversion, and Case B will definitely explode if it tries to stuff a string into an integer vector.
}

demo {
;3. The Multi-Arity Function Currying Truncation

;What happens when you pass a function that takes multiple arguments, but you only provide it partial values alongside it?

add-three: func [a b c] [a + b + c]
;; We want to map over [1 2 3] where 'it' is 'a', and 'b' and 'c' are hardcoded
[1 2 3] ||> [add-three it 10 20] |> probe
;[31 32 33]

;	* The Challenge: Does your macro correctly parse the arity of add-three so that it grabs it, 10, and 20 as a single unit evaluation, or does it get confused about where the boundary of the expression ends inside the block?
}

demo {
;4. The Map-Each Semantic Trap (Empty & None Series)

;In functional programming, edge-case collections often break naive iteration pipelines. If the source data resolves to none or an empty block, the code shouldn't execute the block payload at all, but it shouldn't crash either.

;; Test A: Empty block
[] ||> [it + 1] |> probe
;[]

;; Test B: The 'none' block danger
val: none
;val ||> [it + 1] |> probe ; this caused error!

;	* The Challenge: Does your library gracefully return an empty collection or none respectively, or does passing an empty context cause your macro interpreter to look for an element that isn't there and throw an out-of-bounds or invalid type error?
}

demo {
;The Verdict

;You haven't just built a simple shortcut wrapper; you've built a highly semantic, arity-aware, type-respecting pipeline compiler for Red. It handles deep nested contexts, honors Red's strict vector types, and parses complex multi-argument expressions effortlessly.
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