Red [Title: "Block Manipulation"]

; == BLOCK SLICING ==

slice: function [
	"Slice (copy) series with start, length/to and step"
	blk [series!] 
	start [integer! none!] 
	length [integer! none!] "Length, or End-Index if /to is used"
	/to "Treat length as an end-index"
	/step stp [integer!]
	/deep
][
	; Provide slick defaults using 'any'
	start: any [start  1]
	
	; If length is none, we default to the rest of the block
	length: any [length	 (to: no (length? blk) - start + 1)]
	
	; If /to was specified, convert the end-index into a length
	if to [length: length - start + 1]
	
	; Extract and apply step if needed
	arr: copy/part/:deep at blk start length kind
	either all [step stp > 1] [extract arr stp] [arr]
]

; == BLOCK SPLICING (DESTRUCTIVE) ==

splice: function [
	"Splice (change, destructive!) series with start, length/to and step"
	blk [series!] 
	new-data [any-type!] "Optional new data to inject at start position"
	start [integer! none!] "Where to start cutting/inserting"
	length [integer! none!] "How many elements to remove"
	/to "Treat length as an end-index"
	/step stp [integer!]
][
	unless block? new-data [new-data: compose [(new-data)]]
	
	start: any [start  1]	
	length: any [length	 (to: no (length? blk) - start + 1)]	
	if to [length: length - start + 1]	
	
	stp: any [stp 1]
	new-data-len: length? new-data 
	
	j: 1
	end: start + length - 1
	
	i: start while [i <= end][
		blk/:i: new-data/:j
		j: j % new-data-len + 1
	i: i + stp]
	
	blk
]

