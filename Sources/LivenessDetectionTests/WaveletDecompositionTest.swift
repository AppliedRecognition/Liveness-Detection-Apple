//
//  WaveletDecompositionTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
import Accelerate
@testable import LivenessDetection

final class WaveletDecompositionTest: XCTestCase {

    let waveletDecomposition = WaveletDecomposition()
    
    func test_haarDWT1D() {
        let rows: [[Float]] = [
            [ 0.0,  1.0,  2.0,  3.0,  4.0,  5.0],
            [ 6.0,  7.0,  8.0,  9.0, 10.0, 11.0],
            [12.0, 13.0, 14.0, 15.0, 16.0, 17.0],
            [18.0, 19.0, 20.0, 21.0, 22.0, 23.0]
        ]
        let cols: [[Float]] = [
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
        for i in 0..<rows.count {
            let row = waveletDecomposition.haarDWT1D(rows[i])
            XCTAssertEqual(row, expectedRowResults[i])
        }
        for i in 0..<cols.count {
            let col = waveletDecomposition.haarDWT1D(cols[i])
            XCTAssertEqual(col, expectedColResults[i])
        }
    }
    
    func test_haarDWT2D() {
        let input: [UInt8] = [
             0,  1,  2,  3,  4,  5,
             6,  7,  8,  9, 10, 11,
            12, 13, 14, 15, 16, 17,
            18, 19, 20, 21, 22, 23
        ]
        let expectedOutput: [Float] = [
             3.5,  5.5,  7.5, -0.5, -0.5, -0.5,
            15.5, 17.5, 19.5, -0.5, -0.5, -0.5,
            -3.0, -3.0, -3.0,  0.0,  0.0,  0.0,
            -3.0, -3.0, -3.0,  0.0,  0.0,  0.0
        ]
        let columnCount = 6
        let output = waveletDecomposition.fwdHaarDWT2D(input, columnCount: columnCount)
        XCTAssertEqual(output, expectedOutput)
    }
    
    func test_scaling() {
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
        waveletDecomposition.scaleData(&cA, min: 0, max: 1)
        waveletDecomposition.scaleData(&cH, min: -1, max: 1)
        waveletDecomposition.scaleData(&cV, min: -1, max: 1)
        waveletDecomposition.scaleData(&cD, min: -1, max: 1)
        XCTAssertEqual(cA, [0.0, 0.125, 0.25,
                            0.75, 0.875, 1.0])
        let minusOnes: [Float] = [-1.0,-1.0,-1.0,-1.0,-1.0,-1.0]
        XCTAssertEqual(cH, minusOnes)
        XCTAssertEqual(cV, minusOnes)
        XCTAssertEqual(cD, minusOnes)
    }
    
    func test_splitFreqBands() {
        let input: [Float] = [3.5,  5.5,  7.5, -0.5, -0.5, -0.5, 15.5, 17.5, 19.5, -0.5, -0.5, -0.5, -3.0, -3.0, -3.0,  0.0,  0.0,  0.0, -3.0, -3.0, -3.0,  0.0,  0.0,  0.0]
        let output = waveletDecomposition.splitFreqBands(input, columnCount: 6)
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
