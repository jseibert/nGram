//
//  NGramCollection.swift
//  nGram
//
//  Created by Jeff Seibert on 1/2/22.
//

import Foundation

public final class NGramCollection<N: NGramRepresentable>: Collection, Sequence {
    public let text: String

    private var grams = [N]()

    init(_ text: String) {
        self.text = text
        self.grams = parse(text).sorted()
    }

    func materialize(_ gram: N) -> String {
        String(text[gram.indices])
    }

    private func parse(_ text: String,
                       subrange: Range<String.Index>? = nil,
                       minLength: Int = 1,
                       maxLength: Int = .max,
                       limit: Int = .max) -> [N] {
        let indices = subrange ?? text.startIndex..<text.endIndex
        var children = [N?]()

        // First, split on enclosures like quotes and parentheses
        var seeking = [NGram.Enclosure]()
        var foundEnclosure = false

        NGram.iterate(text, indices: indices) { index, character in
            if NGram.Enclosure.CLOSERS.contains(character) {
                for (enclosureIndex, enclosure) in seeking.enumerated() {
                    if enclosure.seeking == character {
                        if let child = enclosure.close(text: text, end: index) {
                            children += parse(text, subrange: child)
                            foundEnclosure = true
                        }

                        seeking.removeFirst(enclosureIndex + 1)
                        break
                    }
                }
            } else if seeking.isEmpty || NGram.Enclosure.OPENERS.contains(character) {
                // If the existing enclosure is not seeking a character, close it before opening a new one
                if let enclosure = seeking.first, enclosure.seeking == nil {
                    if let child = enclosure.close(text: text, end: index) {
                        children += parse(text, subrange: child)
                        foundEnclosure = true
                    }

                    seeking.removeFirst()
                }
                seeking.insert(.init(start: index, seeking: NGram.Enclosure.MARKERS[character]), at: 0)
            }
        }

        // Close the last enclosure (because all others failed to close) and recurse, unless it's the entire string
        if let enclosure = seeking.last, enclosure.start != indices.lowerBound {
            if let child = enclosure.close(text: text, end: indices.upperBound) {
                children += parse(text, subrange: child)
                foundEnclosure = true
            }
        }

        // If we found an enclosure, all further processing is done via recursion
        guard !foundEnclosure else {
            return children.compactMap { $0 }
        }

        let segments = NGram.split(text, indices: indices, delimiters: NGram.SEGMENT_MARKERS, includeSelf: false)

        // If we found segments, capture them recursively
        guard segments.isEmpty else {
            children += segments.flatMap { parse(text, subrange: $0) }
            return children.compactMap { $0 }
        }

        // Finally, split into space-delimited tokens, and then combine into N-Grams
        let tokens = NGram.split(text, indices: indices, delimiters: [" "])
        let tokenCount = tokens.count
        let maxLength = Swift.min(maxLength, tokenCount)

        for len in stride(from: maxLength, through: minLength, by: -1) {
            var count = 0
            for start in 0...(tokenCount-len) {
                let tokens = Array(tokens[start..<start+len])
                if let startIndex = tokens.first?.lowerBound,
                   let endIndex = tokens.last?.upperBound,
                   let range = NGram.validate(text, range: startIndex..<endIndex) {
                    children.append(N(collection: self, size: len, indices: range))
                }

                count += 1
                if count >= limit {
                    break
                }
            }
        }

        return children.compactMap { $0 }
    }

    // MARK: - Collection & Sequence Conformance

    public var count: Int {
        grams.count
    }

    public func makeIterator() -> IndexingIterator<[N]> {
        return grams.makeIterator()
    }

    public subscript(position: Int) -> N {
        grams[position]
    }

    public var startIndex: Int {
        grams.startIndex
    }

    public var endIndex: Int {
        grams.endIndex
    }

    public func index(after i: Int) -> Int {
        grams.index(after: i)
    }
}
