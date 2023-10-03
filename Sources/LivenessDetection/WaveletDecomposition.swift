//
//  WaveletDecomposition.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import Foundation
import Accelerate

@available(iOS 13, *)
class WaveletDecomposition {
    
    let width: Int = 500
    let height: Int = 375
    let depth: Int = 1
    
    func haarTransformArray(_ array: [UInt8], columnCount: Int) -> (UnsafeMutablePointer<Float>, UnsafeMutablePointer<Float>, UnsafeMutablePointer<Float>, UnsafeMutablePointer<Float>) {
        let dwt2d = self.fwdHaarDWT2D(array, columnCount: columnCount)
        var (cA, cH, cV, cD): ([Float],[Float],[Float],[Float]) = self.splitFreqBands(dwt2d, columnCount: columnCount)
        self.scaleData(&cA, min: 0, max: 1)
        self.scaleData(&cH, min: -1, max: 1)
        self.scaleData(&cV, min: -1, max: 1)
        self.scaleData(&cD, min: -1, max: 1)
        let ptrCa = UnsafeMutablePointer<Float>.allocate(capacity: cA.count)
        ptrCa.initialize(from: &cA, count: cA.count)
        let ptrCh = UnsafeMutablePointer<Float>.allocate(capacity: cH.count)
        ptrCh.initialize(from: &cH, count: cH.count)
        let ptrCv = UnsafeMutablePointer<Float>.allocate(capacity: cV.count)
        ptrCv.initialize(from: &cV, count: cV.count)
        let ptrCd = UnsafeMutablePointer<Float>.allocate(capacity: cD.count)
        ptrCd.initialize(from: &cD, count: cD.count)
        return (ptrCa, ptrCh, ptrCv, ptrCd)
    }
    
    func measureExecutionTime(block: () throws -> Void) -> String {
        if #available(iOS 16, *) {
            if let time = try? ContinuousClock().measure(block) {
                return time.formatted(.units(allowed: [.seconds, .milliseconds], width: .abbreviated))
            }
        } else {
            try? block()
        }
        return ""
    }
    
    func scaleData(_ data: inout [Float], min: Float, max: Float) {
        let inpMax = vDSP.maximum(data)
        let inpMin = vDSP.minimum(data)
        vDSP.add(0-inpMin, data, result: &data)
        vDSP.divide(data, inpMax-inpMin, result: &data)
        data = data.map({ $0.isNaN ? 0 : $0 })
        vDSP.add(multiplication: (a: data, b: max - min), min, result: &data)
    }
    
    func haarDWT1D(_ data: [Float]) -> [Float] {
        var avg0: Float = 0.5
        var avg1: Float = 0.5
        var dif0: Float = 0.5
        var dif1: Float = -0.5
        let stride1 = vDSP_Stride(1)
        let stride2 = vDSP_Stride(2)
        var buf1: [Float] = .init(repeating: .nan, count: data.count/2)
        var buf2: [Float] = .init(repeating: .nan, count: data.count/2)
        var out: [Float] = []

        vDSP_vsmul(data, stride2, &avg0, &buf1, stride1, vDSP_Length(buf1.count))
        vDSP_vsmul(Array(data[1...]), stride2, &avg1, &buf2, stride1, vDSP_Length(buf1.count))
        vDSP_vadd(buf1, stride1, buf2, stride1, &buf1, stride1, vDSP_Length(buf1.count))
        out.append(contentsOf: buf1)

        vDSP_vsmul(data, stride2, &dif0, &buf1, stride1, vDSP_Length(buf1.count))
        vDSP_vsmul(Array(data[1...]), stride2, &dif1, &buf2, stride1, vDSP_Length(buf1.count))
        vDSP_vadd(buf1, stride1, buf2, stride1, &buf1, stride1, vDSP_Length(buf1.count))
        out.append(contentsOf: buf1)
        return out
    }
    
    func fwdHaarDWT2D(_ data: [UInt8], columnCount: Int) -> [Float] {
        let input: [Float] = vDSP.integerToFloatingPoint(data, floatingPointType: Float.self)
        var rows: [Float] = []
        for i in stride(from: 0, to: data.count, by: columnCount) {
            rows.append(contentsOf: self.haarDWT1D(Array(input[i..<i+columnCount]))
            )
        }
        let rowCount = data.count / columnCount
        let stride1 = vDSP_Stride(1)
        vDSP_mtrans(rows, stride1, &rows, stride1, UInt(columnCount), UInt(rowCount))
        var cols: [Float] = []
        for i in stride(from: 0, to: rows.count, by: rowCount) {
            cols.append(contentsOf: self.haarDWT1D(Array(rows[i..<i+rowCount])))
        }
        vDSP_mtrans(cols, stride1, &cols, stride1, UInt(rowCount), UInt(columnCount))
        return cols
    }
    
    func splitFreqBands(_ data: [Float], columnCount: Int) -> ([Float], [Float], [Float], [Float]) {
        let rowCount = data.count / columnCount
        let stride1 = vDSP_Stride(1)
        let halfRow = rowCount / 2
        let halfCol = columnCount / 2
        let quarterLength = rowCount/2*columnCount/2
        var topHalf = Array(data[0..<rowCount*columnCount/2])
        vDSP_mtrans(topHalf, stride1, &topHalf, stride1, vDSP_Length(columnCount), vDSP_Length(halfRow))
        var topLeft = Array(topHalf[0..<quarterLength])
        vDSP_mtrans(topLeft, stride1, &topLeft, stride1, vDSP_Length(halfRow), vDSP_Length(halfCol))
        var topRight = Array(topHalf[quarterLength..<quarterLength*2])
        vDSP_mtrans(topRight, stride1, &topRight, stride1, vDSP_Length(halfRow), vDSP_Length(halfCol))
        var bottomHalf = Array(data[rowCount*columnCount/2..<data.count])
        vDSP_mtrans(bottomHalf, stride1, &bottomHalf, stride1, vDSP_Length(columnCount), vDSP_Length(halfRow))
        var bottomLeft = Array(bottomHalf[0..<quarterLength])
        vDSP_mtrans(bottomLeft, stride1, &bottomLeft, stride1, vDSP_Length(halfRow), vDSP_Length(halfCol))
        var bottomRight = Array(bottomHalf[quarterLength..<quarterLength*2])
        vDSP_mtrans(bottomRight, stride1, &bottomRight, stride1, vDSP_Length(halfRow), vDSP_Length(halfCol))
        return (topLeft, bottomLeft, topRight, bottomRight)
    }
}
