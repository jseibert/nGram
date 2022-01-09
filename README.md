# nGram

nGram is a Swift implementation to generate N-grams (all word combinations) from an input string.

nGram includes support for advanced functionality such as enclosure and segment detection.

## Usage

```swift
let grams = NGram.collect("1979 Petaluma - Coonawarra Proprietary Red (shiraz/cab Blend) (750ml)")
XCTAssertEqual(grams.count, 14)
print(grams.map { $0.text })
```

```
["1979", "1979 Petaluma", "Petaluma", "Coonawarra", "Coonawarra Proprietary", "Coonawarra Proprietary Red", "Proprietary", "Proprietary Red", "Red", "shiraz", "cab", "cab Blend", "Blend", "750ml"]
```
