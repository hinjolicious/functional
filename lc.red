Red [ 
	title: "List Comprehensions" 
	author: "hinjolicoius" 
	notes: {
		lc function by maximvl (originaly by steveGit). 
		Link: https://gist.github.com/maximvl/640aa095ab13792d21032a9e171c77bd
		I changed the code a bit to directly generate the result and optionally 
		the generator function itself.
	}
]

; list comprehension 
lc: function [rule /code] [
	parse rule [
		some [
			s: word! 'in skip
				(in: last reduce/into ['foreach s/1 s/3 make block! 4] in)
			| 'if skip
				(in: last reduce/into ['if to-paren s/2 make block! 4] in)
			| skip '|
				(res: s/1 fun: in: make block! 4)
			| (reduce/into ['reduce/into res 'tail 'out] in) break
		]
	]
	f: has [out] compose [out: make block! 10 (fun) out]
	either code [:f][f]
]

comment {
#include %transpose.red
#include %range.red

print "rosetta code task: pythagorean triples"
probe sort lc [[reduce [a b c]] | 
	a in (range [1 20]) 
	b in (range [1 20]) 
	c in (range [1 20]) 
	if [all [(a ** 2) + (b ** 2) = (c ** 2)	 a < b	b < c]]
]
; [[3 4 5] [5 12 13] [6 8 10] [8 15 17] [9 12 15] [12 16 20]]

; generated code:
comment {
f: func [/local out][
	out: make block! 10 
	foreach a (range 1 20) [
		foreach b (range 1 20) [
			foreach c (range 1 20) [
				if (all [(a ** 2) + (b ** 2) = (c ** 2) a < b b < c]) [
					reduce/into [reduce [a b c]] tail out
				]
			]
		]
	] 
	out
]
}

print "^/nested list comprehension example"
probe lc [ [lc [[x] | x in [1 2 3 4 5]]] | j in [1 2 3 4 5]]
;== [[1 2 3 4 5] [1 2 3 4 5] [1 2 3 4 5] [1 2 3 4 5] [1 2 3 4 5]]

; code:
comment {
func [/local out][
	out: make block! 10 
	foreach j [1 2 3 4 5] [
		reduce/into [
			lc [[x] | x in [1 2 3 4 5]]
		]
		tail out
	] 
	out
]
}

print "^/nested lc to do matrix element-wise operations:"
m1: [[1 2][3 4]]
m2: [[5 6][7 8]]
m: reduce [m1 m2] ; combine the matrix

; add
m3: lc [ [lc [[e/1 + e/2] | e in (transpose r)]] | r in (transpose m)]
probe m3 ; [[6 8] [10 12]]

; subtract
m3: lc [ [lc [[e/1 - e/2] | e in (transpose r)]] | r in (transpose m)]
probe m3 ; [[-4 -4] [-4 -4]]

; code:
comment {
func [/local out][
	out: make block! 10 
	foreach r (transpose m) [
		reduce/into [
			lc [[e/1 + e/2] | e in (transpose r)]
		] 
		tail out
	] 
	out
]
}

print "^/1. data transformation"

nums: [1 2 3 4 5 6 7 8 9 10]

print "^/double every number in a list"
probe lc [[n * 2] | n in nums]
;== [2 4 6 8 10]

print "^/2. filtering data"

probe lc [[n] | n in (range [1 10]) if [even? n]]
;== [2 4 6 8 10]

print "^/3. combining multiple lists (cartesian product)"

probe lc [[as-pair x y] | x in [1 3] y in [10 20]]
;== [1x10 1x20 2x10 2x20 3x10 3x20]

print "^/4. complex data processing"

print "^/combine transformation and filtering in as single operation"
probe lc [[n * n] | n in nums if [odd? n]]
;== [1 9 25 49 81]

list: ["the" "quick" "brown" "fox"]
probe lc [ [uppercase x] | x in list if [x <> "the"] ]
;== ["QUICK" "BROWN" "FOX"]

print "^/5. flattening and extracting data"

; process nested data structures
; Extract all names from a table of records
users: [
	[name "John" age 30]
	[name "Jane" age 25]
	[name "Bob" age 40]
]

probe names: lc [[user/2] | user in users] ; Extract the 2nd element (name) from each sub-block
; Result: ["John" "Jane" "Bob"]

print "^/using more than two lists"
xset: [1 2]
yset: [10 20]
zset: [100 200]
probe lc [ [x + y + z] | x in xset y in yset z in zset]
;== [111 211 121 221 112 212 122 222]

print "^/Test with FOUR lists and a filter"
a-set: [1 2]
b-set: [3 4] 
c-set: [5 6]
d-set: [7 8]

print "^/Only include combinations where the sum of a and b is even"
result: lc [[a * b * c * d] | a in a-set b in b-set c in c-set d in d-set if [even? (a + b)]]
print ["Result with 4 lists + condition:" result]

; ! NOTE: can't handle matrix transpose!!!
}