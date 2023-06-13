//
//  Array2D.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import Foundation

public struct Array2D<T: Codable>: Codable {
    
    enum Array2DCodingKeys: String, CodingKey {
        case rows, cols, data
    }
    
    var cols: Int
    var rows: Int
    var data: [T]
    
    public init(data: [T], cols: Int, rows: Int) throws {
        if data.count != cols * rows {
            throw Array2DError.wrongDataCount
        }
        self.data = data
        self.cols = cols
        self.rows = rows
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Array2DCodingKeys.self)
        try container.encode(self.rows, forKey: .rows)
        try container.encode(self.cols, forKey: .cols)
        try container.encode(self.data, forKey: .data)
    }
    
    public var shape: (Int, Int) {
        (self.cols, self.rows)
    }
    
    public mutating func reshape(_ cols: Int, _ rows: Int) throws {
        if cols * rows != data.count {
            throw Array2DError.invalidShape
        }
        self.cols = cols
        self.rows = rows
    }
    
    public func column(_ col: Int) -> [T] {
        stride(from: col, to: self.data.count, by: self.cols).map({ self.data[$0] })
    }
    
    public mutating func setValues(_ values: [T], inColumn col: Int) throws {
        if values.count != self.rows {
            throw Array2DError.invalidColumnLength
        }
        var j = 0
        for i in stride(from: col, to: self.data.count, by: self.cols) {
            self.data[i] = values[j]
            j += 1
        }
    }
    
    public func row(_ row: Int) -> [T] {
        let startIndex = row * self.cols
        return Array(self.data[startIndex..<startIndex+self.cols])
    }
    
    public mutating func setValues(_ values: [T], inRow row: Int) throws {
        if values.count != self.cols {
            throw Array2DError.invalidRowLength
        }
        let startIndex = row * self.cols
        self.data.replaceSubrange(Range(uncheckedBounds: (startIndex, startIndex+self.cols)), with: values)
    }
    
    public subscript(col: Int, row: Int) -> T {
        set {
            self.data[row * self.cols + col] = newValue
        }
        get {
            let index = row * self.cols + col
            precondition(index < self.data.count)
            return self.data[index]
        }
    }
    
    public subscript(cols: Range<Int>, rows: Range<Int>) -> Array2D<T>? {
        var data: [T] = []
        for r in rows {
            data.append(contentsOf: self.row(r)[cols])
        }
        if let arr = try? Array2D(data: data, cols: cols.count, rows: rows.count) {
            return arr
        } else {
            return nil
        }
    }
    
    public var array: [[T]] {
        if self.data.isEmpty {
            return []
        }
        var arr: [[T]] = Array(repeating: Array(repeating: self.data[0], count: self.cols), count: self.rows)
        for i in 0..<self.rows {
            arr[i] = self.row(i)
        }
        return arr
    }
}

public enum Array2DError: Int, Error {
    case wrongDataCount, invalidShape, invalidColumnLength, invalidRowLength
}
