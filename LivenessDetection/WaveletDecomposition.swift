//
//  WaveletDecomposition.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import Foundation

class WaveletDecomposition {
    
    let width: Int = 500
    let height: Int = 375
    let depth: Int = 1
    
    func haarTransformArray(_ array: Array2D<UInt8>) throws -> ([Float], [Float], [Float], [Float]) {
        let dwt2d = try self.fwdHaarDWT2D(array)
        var (cA, cH, cV, cD): ([Float],[Float],[Float],[Float]) = try self.splitFreqBands(dwt2d)
        try self.scaleData(&cA, min: 0, max: 1)
        try self.scaleData(&cH, min: -1, max: 1)
        try self.scaleData(&cV, min: -1, max: 1)
        try self.scaleData(&cD, min: -1, max: 1)
        return (cA, cH, cV, cD)
    }
    
    func scaleData(_ data: inout [Float], min: Float, max: Float) throws {
        let scaler = MinMaxScaler(min: min, max: max)
        try scaler.fitTransform(&data)
    }
    
    func haarDWT1D(_ data: [Float], length: Int) -> [Float] {
        var temp = [Float](repeating: 0, count: data.count)
        let avg0: Float = 0.5
        let avg1: Float = 0.5
        let dif0: Float = 0.5
        let dif1: Float = -0.5
        let h = length / 2
        DispatchQueue.concurrentPerform(iterations: h) { i in
            let k = i * 2
            temp[i] = data[k] * avg0 + data[k + 1] * avg1
            temp[i + h] = data[k] * dif0 + data[k + 1] * dif1
        }
        return temp
    }
    
    func fwdHaarDWT2D(_ data: Array2D<UInt8>) throws -> Array2D<Float> {
        let levCols = data.cols
        let levRows = data.rows
        var output = try Array2D<Float>(data: [Float](repeating: 0, count: levRows * levCols), cols: levCols, rows: levRows)
        let outputWriteQueue = OperationQueue()
        outputWriteQueue.maxConcurrentOperationCount = 1
        DispatchQueue.concurrentPerform(iterations: levRows) { i in
            let row = self.haarDWT1D(data.row(i).map({ Float($0) }), length: levCols)
            outputWriteQueue.addOperation {
                do {
                    try output.setValues(row, inRow: i)
                } catch {}
            }
        }
        outputWriteQueue.waitUntilAllOperationsAreFinished()
        var cols = [[Float]](repeating: [Float](repeating: 0, count: levRows), count: levCols)
        DispatchQueue.concurrentPerform(iterations: levCols) { i in
            cols[i] = self.haarDWT1D(output.column(i), length: levRows)
        }
        for i in 0..<cols.count {
            try output.setValues(cols[i], inColumn: i)
        }
        return output
    }
    
    func splitFreqBands(_ data: Array2D<Float>) throws -> ([Float], [Float], [Float], [Float]) {
        let levCols = data.cols
        let levRows = data.rows
        let halfRow = levRows / 2
        let halfCol = levCols / 2
        
        guard let LL = data[0..<halfCol, 0..<halfRow]?.data else {
            throw WaveletDecompositionError.failedToSplitBands
        }
        guard let LH = data[0..<halfCol, halfRow..<levRows]?.data else {
            throw WaveletDecompositionError.failedToSplitBands
        }
        guard let HL = data[halfCol..<levCols, 0..<halfRow]?.data else {
            throw WaveletDecompositionError.failedToSplitBands
        }
        guard let HH = data[halfCol..<levCols, halfRow..<levRows]?.data else {
            throw WaveletDecompositionError.failedToSplitBands
        }
        
        return (LL, LH, HL, HH)
    }
}

fileprivate extension UInt8 {
    
    var doubleValue: Double {
        return Double(self)
    }
    
    var floatValue: Float {
        return Float(self)
    }
}

fileprivate class ArrayUtils {
    
    class func setRow<T>(_ row: Int, of array: inout Array<Array<T>>, to values: Array<T>) {
        for i in values.indices {
            array[row][i] = values[i]
        }
    }
    
    class func setColumn<T>(_ column: Int, of array: inout Array<Array<T>>, to values: Array<T>) {
        for row in array.indices {
            array[row][column] = values[row]
        }
    }
    
    class func valuesInColumn<T>(_ column: Int, of array: Array<Array<T>>) -> Array<T> {
        var output = Array<T>(repeating: array[0][0], count: array.count)
        for row in array.indices {
            output[row] = array[row][column]
        }
        return output
    }
    
    class func rangeOfValues<T>(_ array: Array<Array<T>>, cols: Range<Int>, rows: Range<Int>) -> Array<T> {
        if array.isEmpty || array[0].isEmpty {
            return []
        }
        var output = Array<T>(repeating: array[0][0], count: rows.count*cols.count)
        var i = 0
        for r in rows {
            for c in cols {
                output[i] = array[r][c]
                i += 1
            }
        }
        return output
    }
}

class MinMaxScaler {
    
    let min: Float
    let max: Float
    
    init(min: Float, max: Float) {
        self.min = min
        self.max = max
    }
    
    func fitTransform(_ input: inout [Float]) throws {
        if input.isEmpty {
            throw MinMaxScalerError.emptyInputArray
        }
        guard let min = input.min(), let max = input.max() else {
            throw MinMaxScalerError.minMaxOutOfRange
        }
        DispatchQueue.concurrentPerform(iterations: input.count) { i in
            var std = (input[i] - min) / (max - min)
            if std.isNaN {
                std = 0.0
            }
            input[i] = std * (self.max - self.min) + self.min
        }
    }
    
    func fitTransform(_ input: [[Float]]) throws -> [[Float]] {
        var min: Float = .greatestFiniteMagnitude
        var max: Float = 0 - .greatestFiniteMagnitude
        if input.isEmpty {
            throw MinMaxScalerError.emptyInputArray
        }
        for sub in input {
            if sub.isEmpty {
                throw MinMaxScalerError.emptyInputArray
            }
            guard let subMin = sub.min(), let subMax = sub.max() else {
                throw MinMaxScalerError.minMaxOutOfRange
            }
            min = Swift.min(subMin, min)
            max = Swift.max(subMax, max)
        }
        return input.map { sub in
            return sub.map {
                var std = ($0 - min) / (max - min)
                if std.isNaN {
                    std = 0.0
                }
                return std * (self.max - self.min) + self.min
            }
        }
    }
}

enum MinMaxScalerError: Int, Error {
    case minMaxOutOfRange, emptyInputArray
}

enum WaveletDecompositionError: Int, Error {
    case failedToSplitBands
}
