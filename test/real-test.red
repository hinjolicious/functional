Red []

#include %../fp.red
#include %../support/misc.red

demo {
;== SOME REAL TESTS ==

;* Factorial using fold

[1 2 3 4 5 6 7 8 9 10] >- multiply ; factorial
}
demo {
[1 2 3 4 5 6 7 8 9 10] >- [[fac n] fac * n] ; factorial too
} ; 3628800"

demo {
;1. Word frequency counter using fold:

text: {The Quick Brown Fox Jumps Over the Lazy Dog but the Dog was Quicker}
text |> [split it space] ||> lowercase ||> trim 
    >- [[f w #[]] extend f ; [accumulator arg init]
            make map! compose [(w) ; compose a map
                (either none? f/:w [1][f/:w + 1]) ; first or accumulate
            ]
    ]
}
;Output:
;#[
;    "the" 3
;    "quick" 1
;    "brown" 1
;    "fox" 1
;    "jumps" 1
;    "over" 1
;    "lazy" 1
;    "dog" 2
;    "but" 1
;    "was" 1
;    "quicker" 1
;]

demo {
;2. Count vowels and consonants using fold (different approach):

text |> lowercase >- [[f c #[]]
    cat: either find "aiueo" to-string c ['vowels]['consonants] ; category (vowel / consonant)
    f/:cat: either none? f/:cat [f/:cat: 1][f/:cat + 1] ; accumulate based on category
    f ; keep the map
]
}
;Output:
;#[
;    consonants: 49
;    vowels: 18
;]

demo {
;3. Student Grade Analyzer

students: [
    [name: "Alice" grade: 85]
    [name: "Bob"   grade: 42]
    [name: "Carol" grade: 91]
    [name: "Dave"  grade: 67]
]

; Only passing students, extract names, count them"
students 
    || [[a b] b >= 60] ; destructuring
    |> length? --> count
    
print ["Passed:" count "out of" length? students]
} ; Passed: 3 out of 4

demo {
;4. FizzBuzz as data

range: [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]
range 
    ||> [case [
            0 = mod it 15 ["FizzBuzz"] 
            0 = mod it 3 ["Fizz"] 
            0 = mod it 5 ["Buzz"] 
            true [it]
        ]]
    --> results
    ||> [form it]
    >- [[out s ""] append out rejoin [s " "]] --> out

print out
} ; 1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz 

demo {
;5. Shopping Cart

cart: [
    [item: "Book" price: 25] 
    [item: "Pen" price: 5] 
    [item: "Bag" price: 50]
]

cart 
    ||> [it/price]
    ||> [* 1.1] ; add 10% tax
    >- add
    --> total

print ["Total with tax: $" total]
} ; Total with tax: $ 88.0
