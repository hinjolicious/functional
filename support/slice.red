Red [Title: "Block Manipulation"]

#include %../../dev.red
#include %../fp.red

; == BLOCK SLICING ==
;
; This block slicing function largely mimic Python's array slicing mechanism, but using one-base index
; semantic.
; 
; Usage: slice blk [start stop step]
; 
; Step can be negative and it will reverse the list traversing direction.
; Index and stop can also negative, and they will means len - start, len - stop, respectively.

slice: function [
    "1-based inclusive slice that preserves the input series type"
    blk  [series!] 
    rule [block!] "rule: [start stop step]"
][
    if empty? rule [return copy blk]
    
    len: length? blk
    r-rule: reduce rule
    
    ; Parse arguments safely
    set [start stop step] case [
		1 = length? rule [append (append r-rule r-rule) 1]
        2 = length? rule [append r-rule 1]
        3 = length? rule [r-rule]
        true             [cause-error 'script 'invalid-arg "Slice rule must have 1 to 3 elements!"]
    ]
    
	step: any [step 1] ; default step is 1
    unless integer? step [cause-error 'script 'invalid-arg "Slice step must be integer!"]
    if step = 0          [cause-error 'script 'invalid-arg "Slice step cannot be zero!" ]

    ; Establish defaults for none values based on step direction
    either step > 0 [ ; for positive step...
		start: min len any [start 1  ] ; default: start=1, stop=len, all capped at len, negatives will be handled later...
        stop:  min len any [stop  len] 
	][ ; for negative step...
		start: min len any [start len] ; default: start=len, stop=1
        stop:  min len any [stop  1  ] 
	]

	; all negatives are normalized to len - start and len - stop, all caped at 1
	if start <= 0 [start: max 1 len + start] ; zero index are equal to len-0 = len, cyclic behavior!
	if stop  <= 0 [stop:  max 1 len + stop ] 
	
	print [start stop step]	
	
	; fast paths for common steps
	switch step [
	 1 [ if start > stop [return make blk 0]
		 return copy/part at blk start (stop - start + 1) ]
		 
	-1 [ if start < stop [return make blk 0]
		 return reverse copy/part at blk stop (start - stop + 1) ]
	]
    ; Create an empty series of the EXACT same type as the input (string, block, vector, etc.)
    result: make blk 0
    
    i: start
    either step > 0 [
        while [i <= stop][ append/only result pick blk i  i: i + step ]
    ][
        while [i >= stop][ append/only result pick blk i  i: i + step ]
    ]
    result
]

; BLOCK SPLICING  ==
;
; This block splicing function is using the slicing mechanism above, but with a replacement block involved.
;
; Usage: splice blk [start stop step] replacement
;
; Splicing with empty replacement block will removed the sliced elements.
; The provided replacement block will replace and fill cycilically the sliced elements.
; This will also works on negative step and start / stop indices.

splice: function [
    "Pure, non-mutating splice: returns a new series with the slice replaced/removed"
    blk  [series!]
    rule [block!]  "rule: [start stop step]"
    rep  [series!]  "Elements to insert; empty [] removes the slice"
][
    len: length? blk
    r-rule: reduce rule
    
    set [start stop step] case [
        empty? rule      [reduce [1 len 1]]
		1 = length? rule [append (append r-rule r-rule) 1]
        2 = length? rule [append r-rule 1]
        3 = length? rule [r-rule]
        true             [cause-error 'script 'invalid-arg "Splice rule must be 2 or 3 elements!"]
    ]
    step: any [step 1]
    unless integer? step [cause-error 'script 'invalid-arg "Slice step must be integer!"]
    if step = 0          [cause-error 'script 'invalid-arg "Slice step cannot be zero!"]

    ; 2. Establish 1-based inclusive defaults
    either step > 0 [
        start: min len any [start 1  ]
        stop:  min len any [stop  len]
    ][
        start: min len any [start len]
        stop:  min len any [stop  1  ]
    ]
	
	 if start <= 0 [start: max 1 len + start] ; zero index are equal to len-0 = len, cyclic behavior!
	 if stop  <= 0 [stop:  max 1 len + stop ] 
	 
    ; 4. Construct the NEW series sequentially
    result: make blk 0
    rep-len: length? rep
    rep-count: 0
	
	print [start stop step]	

    either step > 0 [
		i: 1 
		j: start
        while [i <= len][
			either all [i = j j <= stop][
				if rep-len > 0 [
					rep-count: rep-count + 1
					item-idx: 1 + modulo (rep-count - 1) rep-len
					append/only result pick rep item-idx
				]
				j: j + step
			][
				append/only result pick blk i
			]
        i: i + 1
        ]
    ][
		i: len
		j: start
        while [i >= 1][
			either all [i = j j >= stop][
				if rep-len > 0 [
					rep-count: rep-count + 1
					item-idx: 1 + modulo (rep-count - 1) rep-len
					append/only result pick rep item-idx
				]
				j: j + step
			][
				append/only result pick blk i
			]
        i: i - 1
        ]
    ]
    result
]

comment {
#include %../test/etc/misc.red ; contain "demo" helper function
test:  :demo/test    ; "as" it to whatever make sense
say:   :demo/display ; ditto
pause: :demo/pause
demo/halt-it: true ; halt, when output didn't matched expected value

print "SLICING DEMO ==^/"

say [[
	b: [1 2 3 4 5 6 7 8 9 10]
	s: "Programmability"
]]

test [[slice b []]				[1 2 3 4 5 6 7 8 9 10] "no change"]
test [[slice b [none none -1]]	[10 9 8 7 6 5 4 3 2 1] "reversed"]

test [[slice b [none none 2] ]	[1 3 5 7 9]		"odds"]
test [[slice b [none none -2]]	[10 8 6 4 2]	"evens, backward"]
pause

test [[slice b [none 8 3]]	[1 4 7]		 "from start to 8, step 3"]
test [[slice b [3 none 4]]	[3 7]		 "from 3 to end, step 4"]
test [[slice b [8 3 -1]] 	[8 7 6 5 4 3] "from 8 to 3, step -1"]
test [[slice b [8 3 -2]]	[8 6 4]		 "from 8 to 3, step -2"]

test [[slice b [4 6]]	[4 5 6] ]
test [[slice b [5 5]]	[5]		"1-based behavior"]
pause

test [[slice s [none none -1]] "ytilibammargorP" "reversed"]
test [[slice s [none none -3]] "ylaao"]
test [[slice s [none 5]		 ] "Progr" "from start to 5"]
test [[slice s [5 100 3] 	 ] "rmit" "clamped to actual length, safe!"]
pause

print "SPLICING DEMO ==^/"

test [[splice b [] []] [] "all gone"]
test [[splice b [none 5] [A B]] [A B A B A 6 7 8 9 10] "from start to 5 replace with [A B], cyclic!"]

; etc...

}
