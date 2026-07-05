Red []

split-block: function [ ; ACTUALLY FASTER THAN THE PARSE VERSION!
	"Splits a block into sub-blocks using a delimiter word/value."
	blk [block!]
	dlm [any-type!] "The delimiter to split on, e.g. '|"
][
	collect [
		current: copy []
		foreach item blk [
			either item = :dlm [
				keep/only current
				current: copy []
			][
				append/only current item
			]
		]
		keep/only current
	]
]

chunk-block: func [ 
	blk [block! string!] ; chunk block or string
	size [integer!]
	/local result chunk
][
	result: copy []
	parse blk [
		any [
			; Copy 'size' number of elements into 'chunk'
			copy chunk size skip (append/only result chunk)
		]
		; Catch any remaining elements that don't fill a whole chunk
		copy chunk to end (if not empty? chunk [append/only result chunk])
	]
	result
]
chunk: :chunk-block ; alias

comment [
; --- Example Usage ---
data: [1 2 3 4 5 6 7]
probe chunk data 2
; Output: [[1 2] [3 4] [5 6] [7]]
]

; parse version
split-block2: function [blk [block!] sep][
    collect [
        chunk: copy []
        parse blk [
            any [
                set val skip (
                    either :val = :sep [
                        keep/only chunk
                        chunk: copy []
                    ][
                        append/only chunk :val
                    ]
                )
            ]
        ]
        keep/only chunk
    ]
]

;clock/times [split-block  [1 2 | 3 4 | 5] '|] 100000
;clock/times [split-block2 [1 2 | 3 4 | 5] '|] 100000
;clock/times [chunk-block  [1 2 3 4 5] 2] 100000
