Red [
	title: "Transpose"
	author: "hinjolicious"
	purpose: { Transpose a matrix.
		Expect a perfect rectangular 2D matrices.
		No jagged validation.
		
		IMPORTANT: Be sure to form the matrix correctly! 
			[ a b c ] is not a matrix, but a list / array of three words!
			Do this instead: lists: reduce [ a b c ]
	}
	note: { For zipping multiple data streams as block of blocks with possible 
		jagged rows and auto-filler support, see "zip.red" }
]

TRANSPOSE: function [matrix [block!] "Matrix as a block of blocks"] [
	if empty? matrix [return copy []]
	
	collect [repeat col length? matrix/1 [
		keep/only collect [foreach row matrix [
			keep/only row/:col]]
	]]
]

comment { 
#include %test/etc/misc.red ; contain "demo" helper function

demo ["Test 1: Regular matrix"|
m1: [ [a b c] [1 2 3] [x y z] ]
print mold transpose m1
]

print "" demo ["Test 2: Non-square matrix"|
m2: [ [A B C] [D E F] ]
print mold transpose m2
]

print "" demo ["Test 4: Single row"|
m4: [ [1 2 3 4 5] ]
print mold transpose m4
]

print "" demo ["Test 5: Single column"|
m5: [ [1] [2] [3] [4] ]
print mold transpose m5
]

print "" demo ["Test 6: Empty matrix"|
m6: []
print mold transpose m6
]

} ; /TEST
