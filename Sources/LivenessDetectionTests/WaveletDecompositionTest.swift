//
//  WaveletDecompositionTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
@testable import LivenessDetection

final class WaveletDecompositionTest: BaseTest {

    let waveletDecomposition = WaveletDecomposition()
    
    let intToUInt8: (Int) -> UInt8 = { UInt8(clamping: $0) }
    
    func test_haarDWT1D() throws {
        let w = 6
        let h = 4
        let count = w * h
        let data: [Float] = (0..<count).map({ Float($0) })
        let a2d = try Array2D(data: data, cols: w, rows: h)
        let expectedRows: [[Float]] = [
            [ 0.0,  1.0,  2.0,  3.0,  4.0,  5.0],
            [ 6.0,  7.0,  8.0,  9.0, 10.0, 11.0],
            [12.0, 13.0, 14.0, 15.0, 16.0, 17.0],
            [18.0, 19.0, 20.0, 21.0, 22.0, 23.0]
        ]
        let expectedCols: [[Float]] = [
            [ 0.0,  6.0, 12.0, 18.0],
            [ 1.0,  7.0, 13.0, 19.0],
            [ 2.0,  8.0, 14.0, 20.0],
            [ 3.0,  9.0, 15.0, 21.0],
            [ 4.0, 10.0, 16.0, 22.0],
            [ 5.0, 11.0, 17.0, 23.0]
        ]
        let expectedRowResults: [[Float]] = [
            [ 0.5,  2.5,  4.5, -0.5, -0.5, -0.5],
            [ 6.5,  8.5, 10.5, -0.5, -0.5, -0.5],
            [12.5, 14.5, 16.5, -0.5, -0.5, -0.5],
            [18.5, 20.5, 22.5, -0.5, -0.5, -0.5]
        ]
        let expectedColResults: [[Float]] = [
            [ 3.0, 15.0, -3.0, -3.0],
            [ 4.0, 16.0, -3.0, -3.0],
            [ 5.0, 17.0, -3.0, -3.0],
            [ 6.0, 18.0, -3.0, -3.0],
            [ 7.0, 19.0, -3.0, -3.0],
            [ 8.0, 20.0, -3.0, -3.0]
        ]
        for i in 0..<a2d.rows {
            XCTAssertEqual(expectedRows[i], a2d.row(i))
        }
        for i in 0..<a2d.cols {
            XCTAssertEqual(expectedCols[i], a2d.column(i))
        }
        for i in 0..<a2d.rows {
            var row = a2d.row(i)
            row = waveletDecomposition.haarDWT1D(row, length: w)
            XCTAssertEqual(row, expectedRowResults[i])
        }
        for i in 0..<a2d.cols {
            var col = a2d.column(i)
            col = waveletDecomposition.haarDWT1D(col, length: h)
            XCTAssertEqual(col, expectedColResults[i])
        }
    }
    
    func test_array2dFunctions() throws {
        let w = 6
        let h = 4
        let count = w * h
        var a2d: Array2D<UInt8> = try Array2D(data: (0..<count).map(intToUInt8), cols: w, rows: h)
        XCTAssertEqual(a2d.row(0), (0..<w).map(intToUInt8))
        XCTAssertEqual(a2d.column(0), stride(from: 0, to: count, by: w).map(intToUInt8))
        var testVal: UInt8 = 32
        let newRow = [UInt8](repeating: testVal, count: w)
        try a2d.setValues(newRow, inRow: 1)
        XCTAssertEqual(a2d.row(1), newRow)
        XCTAssertEqual(a2d[0,1], testVal)
        testVal = 50
        let newCol = [UInt8](repeating: testVal, count: h)
        try a2d.setValues(newCol, inColumn: 1)
        XCTAssertEqual(a2d.column(1), newCol)
        XCTAssertEqual(a2d[1,0], testVal)
    }
    
    func test_fwdHaarDWT2D() throws {
        let w = 6
        let h = 4
        let count = w * h
        let data: Array2D<UInt8> = try Array2D(data: (0..<count).map(intToUInt8), cols: w, rows: h)
        let expectedInput: [[UInt8]] = [
            [ 0,  1,  2,  3,  4,  5],
            [ 6,  7,  8,  9, 10, 11],
            [12, 13, 14, 15, 16, 17],
            [18, 19, 20, 21, 22, 23]
        ]
        XCTAssertEqual(data.array, expectedInput)
        let computed = try waveletDecomposition.fwdHaarDWT2D(data)
        let expected: [[Float]] = [
            [ 3.5,  5.5,  7.5, -0.5, -0.5, -0.5],
            [15.5, 17.5, 19.5, -0.5, -0.5, -0.5],
            [-3.0, -3.0, -3.0,  0.0,  0.0,  0.0],
            [-3.0, -3.0, -3.0,  0.0,  0.0,  0.0]
        ]
        XCTAssertEqual(computed.array, expected)
    }
    
    func test_scaling() throws {
        var (cA, cH, cV, cD): ([Float],[Float],[Float],[Float]) = ([
             3.5,  5.5,  7.5,
            15.5, 17.5, 19.5
        ],[
            -3.0, -3.0, -3.0,
            -3.0, -3.0, -3.0
        ],[
            -0.5, -0.5, -0.5,
            -0.5, -0.5, -0.5
        ],[
             0.0, 0.0, 0.0,
             0.0, 0.0, 0.0
        ])
        try waveletDecomposition.scaleData(&cA, min: 0, max: 1)
        try waveletDecomposition.scaleData(&cH, min: -1, max: 1)
        try waveletDecomposition.scaleData(&cV, min: -1, max: 1)
        try waveletDecomposition.scaleData(&cD, min: -1, max: 1)
        XCTAssertEqual(cA, [0.0, 0.125, 0.25,
                            0.75, 0.875, 1.0])
        let minusOnes: [Float] = [-1.0,-1.0,-1.0,-1.0,-1.0,-1.0]
        XCTAssertEqual(cH, minusOnes)
        XCTAssertEqual(cV, minusOnes)
        XCTAssertEqual(cD, minusOnes)
    }
    
    func test_splitFreqBands() throws {
        let cols = 6
        let rows = 4
        let input: [Float] = [3.5,  5.5,  7.5, -0.5, -0.5, -0.5, 15.5, 17.5, 19.5, -0.5, -0.5, -0.5, -3.0, -3.0, -3.0,  0.0,  0.0,  0.0, -3.0, -3.0, -3.0,  0.0,  0.0,  0.0]
        let data = try Array2D(data: input, cols: cols, rows: rows)
        let output = try waveletDecomposition.splitFreqBands(data)
        let expected: ([Float],[Float],[Float],[Float]) = ([
             3.5,  5.5,  7.5,
            15.5, 17.5, 19.5
        ],[
            -3.0, -3.0, -3.0,
            -3.0, -3.0, -3.0
        ],[
            -0.5, -0.5, -0.5,
            -0.5, -0.5, -0.5
        ],[
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0
        ])
        XCTAssertEqual(output.0, expected.0)
        XCTAssertEqual(output.1, expected.1)
        XCTAssertEqual(output.2, expected.2)
        XCTAssertEqual(output.3, expected.3)
    }

}
