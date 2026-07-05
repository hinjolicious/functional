Red []

__words-stash: make map! []

-->: make op! func [value 'word][
    ; Stash original only on first override
    unless find __words-stash word [
        if value? word [
            __words-stash/:word: get/any word
        ]
    ]
    set word :value
    :value
]

restore: func ['word][
    if find __words-stash word [
        set word :__words-stash/:word
        remove/key __words-stash word
    ]
]

restore-all: does [
    foreach [word val] __words-stash [
        set word :val
    ]
    clear __words-stash
]
