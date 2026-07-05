Red [
	title: "Challenge 20: We all scream for Ice Cream!"
	author: "hinjo"
]

#include %../../fp.red

; Using normal Red code:

scream: function [desc scen][
	; read data, strip ":", load into block
	dat: load replace/all read (to-file scen) ":" ""

	; display data, do calculations
	scoops: copy #[] ; aggregate each flavors total scoops
	flav: copy [] ; keep track what flavors

	foreach [n g f] dat [
		s: (g + 1) * 1.5 ; total scoope of each guests + volunteers
		either none? scoops/:f [ ; add a flavor and scoops if not there yet
			append flav f ; keep track flavors
			scoops/:f: s  
		][ ; add more scoops into existing flavor
			scoops/:f: scoops/:f + s 
		]
	]

	; how many tubs for each flavors?
	tubs: copy scoops
	foreach f flav [
		tubs/:f: to-integer round/ceiling (tubs/:f / 9) 1
	]
	print rejoin ["^/Scenario " desc ":^/"]
	foreach f flav [
		print rejoin ["	* " f ": " tubs/:f " tubs"]
	]
]

; Using FP lib - with unnecessarily long-chains of operations ;)

scream-fp: function [desc scen][
	scen 
		|> to-file						; change to file type
		|> read							; read it
		|> [replace/all it ":" ""]		; strip ":"
		|> [replace/all it "^/" " "]	; strip new-line
		|> load							; load into block
		|> [chunk-block it 3]			; chunk into [name group flavor]
		||> [['name group 'flavor] reduce [flavor (group + 1) * 1.5]] ; form into [flavor scoops]
		>- [[freq ['flavor scoops] #[]] ; fold into [flavor (total scoops)]
				either none? freq/:flavor [
					freq/:flavor: scoops
				][
					freq/:flavor: freq/:flavor + scoops
				]
				freq
			] 
		|> to-block						; change into block to iterate it
		|> [print ["^/Scenario" desc "^/"] it]	; print heading
		||> [[elem] 
				either set-word? elem [
					prin ["^-*" pad elem 15]	; flavor
					elem 
				][
					print [to-integer round/ceiling elem / 9 "tubs"]	; total tubs
					to-integer round/ceiling elem / 9
				]
				elem
			]
		|> [print "^/" it]
]

scream "one"   "challenge_20_s1.txt"
scream-fp "one"   "challenge_20_s1.txt"

scream "two"   "challenge_20_s2.txt"
scream-fp "two"   "challenge_20_s2.txt"

scream "three" "challenge_20_s3.txt"
scream-fp "three" "challenge_20_s3.txt"

