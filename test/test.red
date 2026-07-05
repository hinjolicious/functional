Red []

#include %../fp.red
#include %etc/misc.red

double: function [x][x * 2]

demo[{
=== Functional Programming Library for Red ===

== Design Features

= In-place vs. copy?

* By-design, operands are immutable (copied):
}|
x: [1 2 3]
probe x ||> negate
probe x "; not changed!"

]demo[{
= Function vs. block body?

* Using function as an action is semantically calling it 
  with the given value. So, no get-word here!
* Simple code-block use implicit operand or "it" template
* Complex code-block use custom argument names 
}|
probe [1 2 3] ||> negate "; calling negate, not assigning its value"
probe [1 2 3] ||> [* 2] ||> [1 / it] "; simple code-block"
probe [1 2 3] ||> [[x] x * 2] "; complex code-block (inline function/lambda)"

]demo[{
= Filter semantics for non-bool?
}|
probe [1 2 3 4] || even? ||> [* 10] 
probe [1 2 3 4] || [[x] even? x] ||> [* 10] "; same above"
probe [1 2 3 4] ||> [[x] either even? x [x * 10][x]] "; only on evens"

]demo[{
= Early termination?

* Use catch/throw!
}|
if val: catch/name [ 
    list: [1 2 -3 4 5 6]
    result: none "; init value"
    result: list
        ||> [[x] either x < 0 [throw/name x 'STOP][x]] "; stop on negative"
        ||> probe 
] 'STOP [
    print ["Stopped! Wrong data found:" val]
]
probe list "; should not be changed"
probe result "; not changed!"

]demo[{
= Pipeline: thread-first or thread-last?

* Left-to-right flow is natural, easier to follow.
}|
double: function [x][x * 2]
[1 2 3 4 5] || even? ||> double |> sum |> probe "; easy to follow!"
probe sum map (filter [1 2 3 4 5] even?) double "; ??"

]demo[{
= Pipe/pipelining Features/Considerations

1. Implicit argument & "it" template

* Implicit argument [* 2] are meant for a quick simple math
* The same way, "it" template are for such situation: [sort it]
}|
randoms: collect [loop 100 [keep random 100]]
probe randoms ||> [* 2] |> sum "; implicit argument"
probe randoms ||> [either even? it [it * 10][it]] |> [sort/reverse it] "; it template"

]demo[{
2. Any operators including user-defined can be used in a simple code-block:
}|
probe [1 2 3 4 5] ||> [[x]x |> double |> negate] ||> [* 10] |> sum
probe [1 2 3 4 5] ||> [|> double |> negate] ||> [* 10] |> sum "; implict operand"

]demo[{
3. "Word" action branch

* Names are semantically called not assigned, i.e.: the function are called with the value.
* get-word, can still be used, but that's means replacing the value with that function value.
* Using variable or literal as an action means replacing the value as well.
* This way, the semantic is logically consistent.
}|
probe 0.5 |> sin    "; 0.5 replaced with sin 0.5"
probe 0.5 |> pi     "; 0.5 replaced with pi"
probe 0.5 |> :sin   "; 0.5 replace with function sin"
probe 0.5 |> [:sin] "; same as above"
probe 0.5 |> 'sin   "; this replace it with a word 'sin"
probe :sin --> f    "; assign function sin to f"
probe :sin |> type? "; check the type?"
"; sin |> type? ; error! trying to call a function without argument"

]demo[{
4. Using fold to accumulate a value over a list of functions:
}|
"; a list of function values"
funcs: reduce [:sin :cos :sqrt] "; contains funcs"
acc: 0.1 
foreach f funcs [acc: acc + f acc]
probe acc
;== 2.266180320258807

; same as above using fold
funcs: reduce [:sin :cos :sqrt] ;contains funcs
funcs >- [[acc f 0.1] acc + f acc] |> probe ; fold over functions!
;== 2.266180320258807

]demo[{
TRICK: Using first element as initial value
} |
(reduce [pi :sin :cos :sqrt]) >- [[acc f]acc + f acc] |> probe
;== 3.60501079396861

]