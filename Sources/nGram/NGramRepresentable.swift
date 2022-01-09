//
//  NGramRepresentable.swift
//  nGram
//
//  Created by Jeff Seibert on 1/2/22.
//

import Foundation

public typealias StringIndices = Range<String.Index>

public protocol NGramRepresentable: Comparable {
    init(collection: NGramCollection<Self>, size: Int, indices: StringIndices)

    var collection: NGramCollection<Self> { get }
    var size: Int { get }
    var indices: StringIndices { get }
}

extension NGramRepresentable {
    public static func collect(_ text: String) -> NGramCollection<Self> {
        return NGramCollection<Self>(text)
    }

    public var text: String {
        collection.materialize(self)
    }

    // MARK: - Comparable Conformance

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.indices.lowerBound == rhs.indices.lowerBound {
            return lhs.size < rhs.size
        }

        return lhs.indices.lowerBound < rhs.indices.lowerBound
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.size == rhs.size && lhs.indices == rhs.indices
    }
}
