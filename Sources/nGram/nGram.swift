//
//  nGram.swift
//  nGram
//
//  Created by Jeff Seibert on 12/27/21.
//

import Foundation

public final class NGram: NGramRepresentable {
    public let collection: NGramCollection<NGram>
    public let size: Int
    public let indices: StringIndices

    public init(collection: NGramCollection<NGram>, size: Int, indices: StringIndices) {
        self.collection = collection
        self.size = size
        self.indices = indices
    }

    // TODO: Technically, this should be " -", "- " to avoid breaking Chambolle-Musigny
    static let SEGMENT_MARKERS = Set<Character>([",", "-", "|", "/"])

    struct Enclosure {
        static let MARKERS: [Character: Character] = [
            "(": ")",
            "[": "]",
            "\"": "\"",
            // TODO: Technically this should be " '": "' " to avoid apostrophes
            "'": "'",
        ]

        static var OPENERS: Set<Character> {
            Set(MARKERS.keys)
        }

        static var CLOSERS: Set<Character> {
            Set(MARKERS.values)
        }

        let start: String.Index
        let seeking: Character?

        func close(text: String, end: String.Index) -> Range<String.Index>? {
            let startIndex = seeking == nil ? start : text.index(start, offsetBy: 1)

            return NGram.validate(text, range: startIndex..<end)
        }
    }

    static func iterate(_ text: String, indices: Range<String.Index>, _ closure: (String.Index, Character) -> Void) {
        var index = indices.lowerBound

        while index != indices.upperBound {
            closure(index, text[index])
            index = text.index(after: index)
        }
    }

    /// Splits the receiver by any character in the given delimiter set
    static func split(_ text: String, indices: Range<String.Index>, delimiters: Set<Character>, includeSelf: Bool = true) -> [Range<String.Index>] {
        var segments = [Range<String.Index>]()
        var segmentStart: String.Index?

        iterate(text, indices: indices) { index, character in
            if delimiters.contains(character) {
                if let start = segmentStart {
                    if let segment = validate(text, range: start..<index) {
                        segments.append(segment)
                    }

                    segmentStart = nil
                }
            } else if segmentStart == nil {
                segmentStart = index
            }
        }

        if let start = segmentStart,
            (includeSelf || start != indices.lowerBound),
            let segment = validate(text, range: start..<indices.upperBound)  {
            segments.append(segment)
        }

        return segments
    }

    static func validate(_ text: String, range: Range<String.Index>) -> Range<String.Index>? {
        if range.isEmpty || text[range].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }

        return range
    }
}
