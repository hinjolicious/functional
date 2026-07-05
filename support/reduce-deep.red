Red []

reduce-deep: function [value [any-type!]] [
    either block? :value [
        collect [foreach item value [
			keep/only reduce-deep :item
		]]
    ][
        ; If it's a bound word or expression, evaluate it; otherwise return as-is
        ;either word? :value [get/any value][:value]
		get/any value
    ]
]
