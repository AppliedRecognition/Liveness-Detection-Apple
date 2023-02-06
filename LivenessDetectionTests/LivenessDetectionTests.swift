//
//  LivenessDetectionTests.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import XCTest
@testable import LivenessDetection

final class LivenessDetectionTests: XCTestCase {
    
    private var spoofDeviceDetection: SpoofDeviceDetector!
    private var moireDetection: MoireDetector!
    
    override func setUpWithError() throws {
        let bundle = Bundle(for: type(of: self))
        guard let spoofDeviceDetectorModelURL = bundle.url(forResource: "SpoofDeviceDetector", withExtension: "mlmodel", subdirectory: "Models/spoof-device-detection") else {
            throw NSError()
        }
        guard let moireDetectorModelURL = bundle.url(forResource: "MoireDetector", withExtension: "mlmodel", subdirectory: "Models/moire-detection") else {
            throw NSError()
        }
        self.spoofDeviceDetection = try SpoofDeviceDetector(modelURL: spoofDeviceDetectorModelURL)
        self.moireDetection = try MoireDetector(modelURL: moireDetectorModelURL)
    }
    
    func test_measureMoireDetectionSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        self.measure {
            _ = try! self.moireDetection.detectMoireInImage(cgImage)
        }
    }
    
    func test_measureSpoofDeviceDetectionSpeed() throws {
        let image = try self.loadTestImage()
        self.measure {
            _ = try! self.spoofDeviceDetection.detectSpoofDevicesInImage(image)
        }
    }
    
    func test_measureImageProcessingSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        self.measure {
            _ = try! self.moireDetection.processImage(cgImage)
        }
    }
    
    func test_measureHaarTransformSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        let wavelet: Array2D<UInt8> = try self.moireDetection.processImage(cgImage)
        self.measure {
            _ = try! self.moireDetection.waveletDecomposition.haarTransformArray(wavelet)
        }
    }
    
    func test_measureFwdHaarDWT2DSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        let wavelet: Array2D<UInt8> = try self.moireDetection.processImage(cgImage)
        measure {
            _ = try! self.moireDetection.waveletDecomposition.fwdHaarDWT2D(wavelet)
        }
    }
    
    func test_measureSplitFreqBandsSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        let wavelet: Array2D<UInt8> = try self.moireDetection.processImage(cgImage)
        let dwt2d = try self.moireDetection.waveletDecomposition.fwdHaarDWT2D(wavelet)
        measure {
            _ = try! self.moireDetection.waveletDecomposition.splitFreqBands(dwt2d)
        }
    }
    
    func test_measureScaleDataSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        let wavelet: Array2D<UInt8> = try self.moireDetection.processImage(cgImage)
        let dwt2d = try self.moireDetection.waveletDecomposition.fwdHaarDWT2D(wavelet)
        var (cA, cH, cV, cD) = try self.moireDetection.waveletDecomposition.splitFreqBands(dwt2d)
        measure {
            try! self.moireDetection.waveletDecomposition.scaleData(&cA, min: 0, max: 1)
            try! self.moireDetection.waveletDecomposition.scaleData(&cH, min: -1, max: 1)
            try! self.moireDetection.waveletDecomposition.scaleData(&cV, min: -1, max: 1)
            try! self.moireDetection.waveletDecomposition.scaleData(&cD, min: -1, max: 1)
        }
    }
    
    func test_featureProviderFromInputSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        let wavelet: Array2D<UInt8> = try self.moireDetection.processImage(cgImage)
        var imgLL = try self.moireDetection.waveletDecomposition.haarTransformArray(wavelet).0
        measure {
            _ = try! self.moireDetection.multiArrayFromTransform(&imgLL, name: "input_1")
        }
    }
    
    func test_measureFeatureProviderCreationSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        let wavelet: Array2D<UInt8> = try self.moireDetection.processImage(cgImage)
        let (imgLL, imgLH, imgHL, imgHH) = try self.moireDetection.waveletDecomposition.haarTransformArray(wavelet)
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        measure {
            _ = try! self.moireDetection.featureProviderFromInput(multiArrays)
        }
    }
    
    func test_measureMoireDetectorPredictionSpeed() throws {
        let cgImage = try self.loadTestCGImage()
        let wavelet: Array2D<UInt8> = try self.moireDetection.processImage(cgImage)
        let (imgLL, imgLH, imgHL, imgHH) = try self.moireDetection.waveletDecomposition.haarTransformArray(wavelet)
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        let featureProvider = try self.moireDetection.featureProviderFromInput(multiArrays)
        measure {
            _ = try! self.moireDetection.predictionFromFeatureProvider(featureProvider)
        }
    }
    
    func ignore_testLivenessDetection() throws {
        let colours: [CGColor] = [UIColor.green.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor, UIColor.cyan.cgColor]
        try self.forEachTestImage { url, image in
            let spoofs = try self.spoofDeviceDetection.detectSpoofDevicesInImage(image)
            var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            for spoof in spoofs {
                imageRect = imageRect.union(spoof.boundingBox)
            }
            let addedHeight: CGFloat = 32
            let lineWidth: CGFloat = 4
            let padding: CGFloat = 8
            let paddingTransform = CGAffineTransform(translationX: padding, y: padding)
            imageRect.size.height += addedHeight
            let offset = CGAffineTransform(translationX: 0-imageRect.minX, y: 0-imageRect.minY)
            UIGraphicsBeginImageContext(imageRect.size)
            image.draw(at: .zero.applying(offset))
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 0, y: image.size.height, width: image.size.width, height: addedHeight))
            var colourIndex = 0
            for spoof in spoofs {
                if colourIndex >= colours.count {
                    colourIndex = 0
                }
                let spoofRect = spoof.boundingBox.applying(offset).insetBy(dx: lineWidth/2, dy: lineWidth/2)
                let scoreString = self.attributedString(String(format: "Spoof device: %.03f", spoof.confidence), colour: .black)
                var labelRectSize = scoreString.size()
                labelRectSize = CGSize(width: labelRectSize.width + padding * 2, height: labelRectSize.height + padding * 2)
                let labelRect = CGRect(origin: spoofRect.origin, size: labelRectSize)
                context.setFillColor(UIColor.white.cgColor)
                context.fill(labelRect)
                context.setStrokeColor(colours[colourIndex])
                context.setLineWidth(lineWidth)
                context.stroke(spoofRect)
                scoreString.draw(at: spoofRect.origin.applying(paddingTransform))
            }
            defer {
                UIGraphicsEndImageContext()
            }
            if let cgImage = image.cgImage {
                let confidence = try self.moireDetection.detectMoireInImage(cgImage)
                self.attributedString(String(format: "Moire: %.03f", confidence), colour: .black).draw(at: CGPoint(x: padding, y: imageRect.maxY - addedHeight + padding))
            }
            if let annotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                let attachment = XCTAttachment(image: annotatedImage)
                attachment.lifetime = .keepAlways
                attachment.name = url.lastPathComponent
                self.add(attachment)
            }
        }
    }
    
    func test_haarDWT1D() throws {
        let decomp = WaveletDecomposition()
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
            let row = decomp.haarDWT1D(a2d.row(i), length: w)
            XCTAssertEqual(row, expectedRowResults[i])
        }
        for i in 0..<a2d.cols {
            let col = decomp.haarDWT1D(a2d.column(i), length: h)
            XCTAssertEqual(col, expectedColResults[i])
        }
    }
    
    let intToUInt8: (Int) -> UInt8 = { UInt8(clamping: $0) }
    
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
        let decomp = WaveletDecomposition()
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
        let computed = try decomp.fwdHaarDWT2D(data)
        let expected: [[Float]] = [
            [ 3.5,  5.5,  7.5, -0.5, -0.5, -0.5],
            [15.5, 17.5, 19.5, -0.5, -0.5, -0.5],
            [-3.0, -3.0, -3.0,  0.0,  0.0,  0.0],
            [-3.0, -3.0, -3.0,  0.0,  0.0,  0.0]
        ]
        XCTAssertEqual(computed.array, expected)
        //        let (cA, cH, cV, cD) = try decomp.splitFreqBands(computed)
        //        print(cA, cH, cV, cD)
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
        let decomp = WaveletDecomposition()
        try decomp.scaleData(&cA, min: 0, max: 1)
        try decomp.scaleData(&cH, min: -1, max: 1)
        try decomp.scaleData(&cV, min: -1, max: 1)
        try decomp.scaleData(&cD, min: -1, max: 1)
        XCTAssertEqual(cA, [0.0, 0.125, 0.25, 0.75, 0.875, 1.0] as [Float])
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
        let decomp = WaveletDecomposition()
        let output = try decomp.splitFreqBands(data)
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
    
    
    
    private func loadTestImage() throws -> UIImage {
        guard let testImageURL = try self.testImageURLs().first, let data = try? Data(contentsOf: testImageURL), let image = UIImage(data: data) else {
            throw NSError()
        }
        return image
    }
    
    private func loadTestCGImage() throws -> CGImage {
        let image = try self.loadTestImage()
        if let cgImage = image.cgImage {
            return cgImage
        }
        throw NSError()
    }
    
    private func attributedString(_ string: String, colour: UIColor) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 18)
        return NSAttributedString(string: string, attributes: [.foregroundColor: colour, .font: font])
    }
    
    private func testImageURLs() throws -> [URL] {
        guard let imagesDirectoryURL = Bundle(for: type(of: self)).url(forResource: "Test images", withExtension: nil) else {
            throw NSError()
        }
        return try FileManager.default.contentsOfDirectory(at: imagesDirectoryURL, includingPropertiesForKeys: nil)
    }
    
    private func forEachTestImage(_ task: @escaping (URL, UIImage) throws -> Void) throws {
        let imageURLs = try self.testImageURLs()
        for url in imageURLs {
            let imageData = try Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else {
                continue
            }
            try task(url, image)
        }
    }

}
