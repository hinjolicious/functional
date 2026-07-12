# Red Functional Programming Library (`functional.red`)

A lightweight, expressive, and zero-dependency functional programming dialect for the **Red Language**. This library introduces native-feeling pipeline, mapping, filtering, and folding operations to make complex data transformation pipelines brief, clean, and highly readable.

Maintained under the author alias `hinjolicious`.

---

## 🚀 Core Operators at a Glance

The library introduces four primary chainable operators using Red's `op!` evaluation mechanics:

| Operator | Function | Description | Example |
| :---: | :--- | :--- | :--- |
| `\|>` | **Pipe** | Processes a value through an action or transformation template. | `5 \|> sin` |
| `\|\|>` | **Map** | Transforms each item in a block or series. | `[1 2 3] \|\|> [* 2]` |
| `\|\|` | **Filter** | Filters elements of a series based on a given condition. | `[1 2 3] \|\| even?` |
| `>-` | **Fold** | Reduces a list to a single value using an accumulator rule. | `[1 2 3] >- add` |

More to come:
* Transpose (fast matrix tanspose) --> done
* Zip (data stream zipping) --> done
* Group (powerful multi-category multi-rule data grouping engine) --> done
  ```red
  [1 2 3 4 5 6] |> [group it [even [even? it] odd [odd? it]]]
  ;#[
  ;  odd: [1 3 5]
  ;  even: [2 4 6]
  ;]
  ```
* Curry (true purist style currying engine) --> done
  ```red
  add10: 'add -> [] -> 10
  add10 5
  ; 15
  'add -> 5 -> 10
  ;15
  ```
* Partial function application (practical real-world PFA) --> done
* List comprehension (powerful LC) --> done
* List chunking --> done
* List flattening --> done
* Range generator --> done
* List and index access in map, filter, fold, group, etc. (if requested!): `list ||> [[a b | lst ix] ...code...]`
* Function Combinators (compose, juxt)
  - compose (comp-func, comp-funcs) --> done
  - juxt --> done
    ```red
    ;; Complex parallel evaluations inside juxt 
	[1 2 3 4 5] |> [juxt it [
		sum							; native sum
		average						; native average
		[it >- add]					; sum fold
 		[>- [[a b] max a b]]		; max-of fold
		[>- [[a b] min a b]]		; min-of fold
		[ ||> [* 10] |> sum ]		; implicit pipeline stub
		[[x] x ||> [it / 2] |> sum] ; complex process
	]]
	;== [15 3 15 5 1 150 7.5]
    ```
  - juxt-map (process a series by multiple actions/functions and produce a summary map) --> done
    ```red
	data |> [juxt-map it [
		'Mean	[|> [mean it] --> m]
		'Min	minimum
		'Max	maximum
		'Range	range
		'Size	count
		'Sum	sum
		'Median median
		'Modes	modes 
		
		'StdDev		[stddev/sm it m]
		'StdDev-pop [stddev/sm/pop it m]
		
		'Variance 		[variance/sm it m]
		'Variance-pop 	[variance/sm/pop it m]
		
		'Mid-Range 		mid-range 
		'Q1 			q1
		'Q2 			q2
		'Q3 			q3
		'IQR 			iqr
		'Upper-Outliers upper-outliers
		'Lower-Outliers lower-outliers
		'Sum-Square 	sum-square
		'MAD 			mad
		'RMS 			rms
		'SE-Mean 		se-mean
		
		'Median-Skewness 		[median-skewness/sm it m]
		
		'Skewness				[skewness/sm it m]
		'Skewness-pop 			[skewness/pop/sm it m]
		'Kurtosis 				[kurtosis/sm it m]
		'Kurtosis-pop 			[kurtosis/pop/sm it m]
		'Kurtosis-excess 		[kurtosis/excess/sm it m]
		'Kurtosis-excess-pop 	[kurtosis/excess/pop/sm it m]
		
		'CV 			coeff-var
		'RSD 			rel-stddev
		'Gini 			gini
		'Freq-Dist 		[freq-dist it 10]
		'Top-10-Freq	[top-freq it 10]
		]]
		|> [ foreach [i j] it [print [i mold j]] ]
    ```
* Infinite & Deferred Generation (lazy / infinite-range)
* Frequency & Distinct Uniqueness (frequencies, distinct)
  top-freq and freq-dist are in https://github.com/hinjolicious/statistics
---

## 🛠️ Detailed Features & Syntax

### 1. The Pipe Operator (`|>`)
The pipe engine is highly versatile and handles multiple types of functional arguments cleanly:
* **Functions / Words:** `value |> sin`. NOTE: Semantically, we call sin, so no :sin here!.
* **Simple Block Contexts:** Evaluates directly as an inline expression. E.g., `value |> [* 2]`.
* **"It" Templates:** Uses an implicit `it` variable for simple expressions. E.g., `[10 * it]`.
* **Complex Blocks / Lambdas:** Full lambda-style blocks with destructuring properties. E.g., `[[1 2][3 4]] |> [[a b] a * b]`.

### 2. Multi-Argument Matrix Folding (`>-`)
The folding engine includes a **Shape Guard** to safely handle multidimensional list/matrix unpacking directly inside the fold context:
```red
; Accumulate matrix rows cleanly with dynamic chunk destructuring
[[1 2][3 4]] >- [[acc [a b]] reduce [acc/1 + a acc/2 + b]]



## 💡 Practical Examples

### Word Frequency Counter

Count the frequency of words in a body of text seamlessly using a hash/map fold accumulator:

```red
text: "The Quick Brown Fox Jumps Over the Lazy Dog but the Dog was Quicker"

text |> [split it space] ||> lowercase ||> trim >- [[f w #[]] 
    extend f make map! compose [(w) (either none? f/:w [1][f/:w + 1])]
]
; Output: #[ 
	"the" 3 
	"quick" 1 
	"brown" 1 
	"fox" 1 
	... ]

```

### Data Transformations & Calculations

Easily perform math adjustments across arrays or objects:

```red
cart: [
    [item: "Book" price: 25] 
    [item: "Pen"  price: 5] 
    [item: "Bag"  price: 50]
]

cart ||> [it/price] ||> [* 1.1] >- add --> total
print ["Total with tax: $" total] ; Total with tax: $ 88.0

```

---

## 🎮 Execution & Control Flow within Chains

You do not lose control over your execution frames inside long pipeline paths. The library handles native control keywords naturally:

* **`return` Early:** Short-circuit an operation block for an item and immediately pass it to the next step.
* **`break` Early:** Terminate an operation sequence midway through processing a block collection.
* **`continue` / Data Skipping:** Easily skip unwanted data rows cleanly:

```red
probe [1 2 3 none "6" 7] 
    ||> [[x] if not number? x [continue] x] 
    ||> negate
; Output: [-1 -2 -3 -7]

```

* **Global Exceptions:** Combine with native `catch`/`throw` blocks to fully abort long chains when corrupt conditions occur.

---

## 🌀 Advanced Demo: Functional Mandelbrot

The library's nested capabilities are robust enough to model complex mathematical algorithms like a Mandelbrot generator. This snippet cascades a structured step pipeline down across multiple levels of processing while tracking customized structures:

```red
(step 1 -0.05 41) ||> [[y]
    (step -2.0 0.0315 80) ||> [[x]
        either (
            (range 50) >- [[z _ (complex 0 0)]
                if (com-abs z) > 1000 [break] ; Early termination optimization
                z c* z c+ complex x y
            ] |> com-abs 
        ) < 2 ["*"]["."]
    ] |> to-string |> [print it it]
]

```

---

## 🏗️ Installation & Usage

1. Clone or download `functional.red` into your project directory tree.
2. Include the library file at the top of your script file:

```red
Red [
    Title: "My Functional Program"
]

#include %fp.red ; includes functional.red, support files, etc.

; Start pipelines right away!
[1 2 3 4 5] ||> [* 10] || [[x] > 25] |> probe

```

---

*Main ideas and engine design by hinjolicious. Project optimized with supplemental architectural insights from Gemini AI, Red/Sensei AI, etc.

```

```
