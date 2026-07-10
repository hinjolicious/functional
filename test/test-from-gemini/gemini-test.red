Red []

#include %../../functional.red
#include %../../support/misc.red

demo {
;== Some test from Gemini AI ==

;1. The Matrix Collision (Nested it Scopes)

;If you nest a pipeline inside another pipeline, the inner block will likely want to use it for its own elements. This tests if your library handles lexical scoping or if the inner it accidentally overrides the outer one.

;; Expected output: [[5 6] [6 7]]
;; The outer 'it' is the sub-vector: [1 2]
;; The inner 'it' is the individual integer: 1, 2

[[1 2] [2 3]] ||> [it ||> [it + 4]] |> probe
;[[5 6] [6 7]]

;	* The Challenge: Does the inner it break the outer context, or do you have a mechanism to stack or isolate environments?
}

demo {
;2. The Mutating Evaluation (Side Effects in the Pipeline)

;Red handles series by reference. If a function inside your pipeline modifies the series in-place while another part relies on the original structure or length, things can get weird.

;; Testing a self-referencing, mutating pipeline

blk: [1 2 3 4 5]
blk |> [take it] |> [append blk it] |> probe
;[3 4 5 2]

;	* The Challenge: Does ||> operate on a deep copy of the block, or does it pass references? If it passes references, changing blk mid-stream can cause unexpected memory offsets or infinite loops if the dialect isn't careful about stream termination.
}

demo {
;3. Red's Native Non-Evaluating Types (Lit-Words & Lit-Paths)

;Red uses literal types like 'foo (lit-word) or 'foo/bar (lit-path) which suppress evaluation until explicitly requested. If your pipeline preprocesses the block to look for it, it might accidentally evaluate or strip these literal types.

;; Expected output: ['a 'b 'c] or similar literal manipulations

['a 'b 'c] ||> [type? it] |> probe
;[lit-word! lit-word! lit-word!]

;	* The Challenge: Does your macro/parser leave lit-word! or lit-path! types intact as literals, or does the pipeline force-evaluate them early into standard word! types?
}

demo {
;4. The Short-Circuiting Control Flow

;What happens if someone passes an error, a break, or a return through the pipeline? If your code is wrapping the execution in an anonymous function or a dynamic bind under the hood, a return might try to return from your library's internal function instead of the user's outer function.

my-func: func [] [
    [1 2 3] ||> [if it = 1 [return "Escaped!"]] ; ERROR: can't do this!!!
    "Failed to escape"
]
;probe my-func

;	* The Challenge: Does it print "Escaped!" or "Failed to escape"? In Rebol/Red derivation dialects, handling dynamic local returns without breaking the outer calling function's scope is historically one of the hardest edge cases to solve.

;SOLUTION:
my-func: func [] [
    [1 2 3] ||> [if it = 1 [throw "Escaped!"]] ; ERROR: can't do this!!!
    "Failed to escape"
]
probe catch [my-func]
;"Escaped!"
}

demo {
;The Breakdown

;    Case 1 (Nested Scopes): Passed Perfectly. [[5 6] [6 7]] proves your macro/evaluator is pushing and popping scopes correctly. The inner it didn't stomp on the outer it. That is remarkably robust.

;    Case 2 (Mutation): Passed. [3 4 5 2] shows it tracks the series references exactly as a Red developer would expect, without losing its place mid-pipeline.

;    Case 3 (Literal Types): Passed Perfectly. Preserving lit-word! instead of aggressively force-evaluating them means your parser respects Red's deep evaluation rules.
	
;Why your fix is great: Using throw and catch completely bypasses the function call-stack limitations. It creates a global exception highway, allowing you to instantly break out of the pipeline and the parent function simultaneously.	
}
