//
//  MoireDetectorTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
@testable import LivenessDetection

final class MoireDetectorTest: BaseTest {
    
    var moireDetector: MoireDetector!
    var moireDetectorInputURL: URL!
    var moireDetectorOutputURL: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.moireDetector = try createMoireDetector()
        if let url = URL(string: "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/img_model_in_out_data/model_input.json") {
            self.moireDetectorInputURL = url
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/img_model_in_out_data/model_results.json") {
            self.moireDetectorOutputURL = url
        } else {
            throw NSError()
        }
    }
    
    func test_detectMoireInImages_succeedsOn80PercentOfImages() throws {
        let threshold: Float = 0.5
        let maxFailRatio: Float = 0.2
        var detectionCount: Float = 0
        var failCount: Float = 0
        try withEachCGImage(types: [.moire]) { (image, url, positive) in
            let score = try self.moireDetector.detectMoireInImage(image)
            let prefix = positive ? "positive" : "negative"
            if (positive && score >= threshold) || (!positive && score < threshold) {
                NSLog("%@/%@ succeeded: moire confidence %.04f", prefix, url.lastPathComponent, score)
            } else {
                NSLog("%@/%@ failed: moire confidence %.04f", prefix, url.lastPathComponent, score)
                failCount += 1
            }
            detectionCount += 1
        }
        let failRatio = failCount / detectionCount
        NSLog("Fail ratio: %.02f%%", failRatio * 100)
        XCTAssertLessThanOrEqual(failRatio, maxFailRatio, String(format: "Fail ratio must be below %.0f%% but is %.02f%%", maxFailRatio * 100, failRatio * 100))
    }
    
    func test_verifyMoireDetectionInputAndOutput() throws {
        let inputURL = try self.localURL(of: self.moireDetectorInputURL)
        let outputURL = try self.localURL(of: self.moireDetectorOutputURL)
        let inputData = try Data(contentsOf: inputURL)
        let outputData = try Data(contentsOf: outputURL)
        let input: [String:[[[[Float]]]]] = try JSONDecoder().decode([String:[[[[Float]]]]].self, from: inputData)
        var inputArrays: [String:[Float]] = [:]
        for (key, val) in input {
            inputArrays[key] = val.flatMap({ $0.flatMap({ $0.flatMap({ $0 }) }) })
        }
        guard var cA = inputArrays["X_LL"], var cH = inputArrays["X_LH"], var cV = inputArrays["X_HL"], var cD = inputArrays["X_HH"] else {
            throw NSError()
        }
        let imgLL = UnsafeMutablePointer<Float>.allocate(capacity: cA.count)
        imgLL.initialize(from: &cA, count: cA.count)
        let imgLH = UnsafeMutablePointer<Float>.allocate(capacity: cH.count)
        imgLH.initialize(from: &cH, count: cH.count)
        let imgHL = UnsafeMutablePointer<Float>.allocate(capacity: cV.count)
        imgHL.initialize(from: &cV, count: cV.count)
        let imgHH = UnsafeMutablePointer<Float>.allocate(capacity: cD.count)
        imgHH.initialize(from: &cD, count: cD.count)
        
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        let featureProvider = try self.moireDetector.featureProviderFromInput(multiArrays)
        let prediction = try self.moireDetector.predictionFromFeatureProvider(featureProvider)
        imgLL.deallocate()
        imgLH.deallocate()
        imgHL.deallocate()
        imgHH.deallocate()
        
        guard let output: [[Float]] = try JSONDecoder().decode([String:[[Float]]].self, from: outputData)["results"] else {
            throw NSError()
        }
        
        XCTAssertEqual(prediction[0].floatValue, output[0][0], accuracy: 0.02)
        XCTAssertEqual(prediction[1].floatValue, output[0][1], accuracy: 0.02)
    }
    
    func test_measureMoireDetectionSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        self.measure {
            _ = try! self.moireDetector.detectMoireInImage(image)
        }
    }
    
    func test_measureImageProcessingSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        self.measure {
            _ = try! self.moireDetector.processImage(image)
        }
    }
    
    func test_measureHaarTransformSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let wavelet: Array2D<UInt8> = try self.moireDetector.processImage(image)
        self.measure {
            _ = try! self.moireDetector.waveletDecomposition.haarTransformArray(wavelet)
        }
    }
    
    func test_measureFwdHaarDWT2DSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let wavelet: Array2D<UInt8> = try self.moireDetector.processImage(image)
        measure {
            _ = try! self.moireDetector.waveletDecomposition.fwdHaarDWT2D(wavelet)
        }
    }
    
    func test_measureSplitFreqBandsSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let wavelet: Array2D<UInt8> = try self.moireDetector.processImage(image)
        let dwt2d = try self.moireDetector.waveletDecomposition.fwdHaarDWT2D(wavelet)
        measure {
            _ = try! self.moireDetector.waveletDecomposition.splitFreqBands(dwt2d)
        }
    }
    
    func test_measureScaleDataSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let wavelet: Array2D<UInt8> = try self.moireDetector.processImage(image)
        let dwt2d = try self.moireDetector.waveletDecomposition.fwdHaarDWT2D(wavelet)
        var (cA, cH, cV, cD) = try self.moireDetector.waveletDecomposition.splitFreqBands(dwt2d)
        measure {
            try! self.moireDetector.waveletDecomposition.scaleData(&cA, min: 0, max: 1)
            try! self.moireDetector.waveletDecomposition.scaleData(&cH, min: -1, max: 1)
            try! self.moireDetector.waveletDecomposition.scaleData(&cV, min: -1, max: 1)
            try! self.moireDetector.waveletDecomposition.scaleData(&cD, min: -1, max: 1)
        }
    }
    
    func test_featureProviderFromInputSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let wavelet: Array2D<UInt8> = try self.moireDetector.processImage(image)
        let imgLL = try self.moireDetector.waveletDecomposition.haarTransformArray(wavelet).0
        measure {
            _ = try! self.moireDetector.multiArrayFromTransform(imgLL, name: "input_1")
        }
        imgLL.deallocate()
    }
    
    func test_measureFeatureProviderCreationSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let wavelet: Array2D<UInt8> = try self.moireDetector.processImage(image)
        let (imgLL, imgLH, imgHL, imgHH) = try self.moireDetector.waveletDecomposition.haarTransformArray(wavelet)
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        measure {
            _ = try! self.moireDetector.featureProviderFromInput(multiArrays)
        }
        imgLL.deallocate()
        imgLH.deallocate()
        imgHL.deallocate()
        imgHH.deallocate()
    }
    
    func test_measureMoireDetectorPredictionSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let wavelet: Array2D<UInt8> = try self.moireDetector.processImage(image)
        let (imgLL, imgLH, imgHL, imgHH) = try self.moireDetector.waveletDecomposition.haarTransformArray(wavelet)
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        let featureProvider = try self.moireDetector.featureProviderFromInput(multiArrays)
        measure {
            _ = try! self.moireDetector.predictionFromFeatureProvider(featureProvider)
        }
        imgLL.deallocate()
        imgLH.deallocate()
        imgHL.deallocate()
        imgHH.deallocate()
    }
    
    func test_multiArrayFromTransform() throws {
        var imgLL: [Float] = [
             3.5,  5.5,  7.5,
            15.5, 17.5, 19.5
        ]
        let multiArray = try moireDetector.multiArrayFromTransform(&imgLL, name: "input_1")
        for i in 0..<imgLL.count {
            XCTAssertEqual(multiArray[[0,0,i,0] as [NSNumber]].floatValue, imgLL[i])
        }
    }
}
