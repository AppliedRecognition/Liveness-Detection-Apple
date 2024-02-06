//
//  MoireDetectorTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
import Accelerate
import UniformTypeIdentifiers
@testable import LivenessDetection

final class MoireDetectorTest: BaseTest<MoireDetector> {
    
    var moireDetectorInputURL: URL!
    var moireDetectorOutputURL: URL!
    
    override var confidenceThreshold: Float {
        0.5
    }
    
    override var expectedSuccessRate: Float {
        0.74
    }
    
    override func createSpoofDetector() throws -> MoireDetector {
        try self.createMoireDetector()
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
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
    
    func test_compareImageScalingModes_attachCSV() throws {
        var csv = "\"Image\",\"Is spoof\",\"Resampled image score\",\"Cropped image score\""
        try self.withEachImage(types: [.moire]) { image, url, positive in
            let roi = try FaceDetection.detectFacesInImage(image).first?.bounds
            self.spoofDetector.scaleMode = .resample
            let resampleScore = try self.spoofDetector.detectSpoofInImage(image, regionOfInterest: roi)
            self.spoofDetector.scaleMode = .crop
            let cropScore = try self.spoofDetector.detectSpoofInImage(image, regionOfInterest: roi)
            csv.append(String(format: "\n\"%@\",%d,%.03f,%.03f", url.lastPathComponent, positive ? 1 : 0, resampleScore, cropScore))
        }
        guard let data = csv.data(using: .utf8) else {
            XCTFail()
            return
        }
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "Moire image resizing comparison.csv"
        self.add(attachment)
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
        let featureProvider = try self.spoofDetector.featureProviderFromInput(multiArrays)
        let prediction = try self.spoofDetector.predictionFromFeatureProvider(featureProvider)
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
    
    func test_measureImageProcessingSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        self.measure {
            _ = try! self.spoofDetector.processImage(image)
        }
    }
    
    func test_measureHaarTransformSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let (wavelet, colCount) = try self.spoofDetector.processImage(image)
        self.measure {
            _ = self.spoofDetector.waveletDecomposition.haarTransformArray(wavelet, columnCount: colCount)
        }
    }
    
    func test_measureHaarDWT1DSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let (wavelet, colCount) = try self.spoofDetector.processImage(image)
        let input: [Float] = vDSP.integerToFloatingPoint(wavelet, floatingPointType: Float.self)
        self.measure {
            var output: [Float] = []
            for i in stride(from: 0, to: wavelet.count, by: colCount) {
                output.append(contentsOf:
                                self.spoofDetector.waveletDecomposition.haarDWT1D(Array(input[i..<i+colCount]))
                )
            }
        }
    }
    
    func test_measureFwdHaarDWT2DSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let (wavelet, colCount) = try self.spoofDetector.processImage(image)
        measure {
            _ = self.spoofDetector.waveletDecomposition.fwdHaarDWT2D(wavelet, columnCount: colCount)
        }
    }
    
    func test_measureSplitFreqBandsSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let (wavelet, colCount) = try self.spoofDetector.processImage(image)
        let dwt2d = self.spoofDetector.waveletDecomposition.fwdHaarDWT2D(wavelet, columnCount: colCount)
        measure {
            _ = self.spoofDetector.waveletDecomposition.splitFreqBands(dwt2d, columnCount: colCount)
        }
    }
    
    func test_measureScaleDataSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let (wavelet, colCount) = try self.spoofDetector.processImage(image)
        let dwt2d = self.spoofDetector.waveletDecomposition.fwdHaarDWT2D(wavelet, columnCount: colCount)
        var (cA, cH, cV, cD) = self.spoofDetector.waveletDecomposition.splitFreqBands(dwt2d, columnCount: colCount)
        measure {
            self.spoofDetector.waveletDecomposition.scaleData(&cA, min: 0, max: 1)
            self.spoofDetector.waveletDecomposition.scaleData(&cH, min: -1, max: 1)
            self.spoofDetector.waveletDecomposition.scaleData(&cV, min: -1, max: 1)
            self.spoofDetector.waveletDecomposition.scaleData(&cD, min: -1, max: 1)
        }
    }
    
    func test_featureProviderFromInputSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let (wavelet, colCount) = try self.spoofDetector.processImage(image)
        let imgLL = self.spoofDetector.waveletDecomposition.haarTransformArray(wavelet, columnCount: colCount).0
        measure {
            _ = try! self.spoofDetector.multiArrayFromTransform(imgLL, name: "input_1")
        }
        imgLL.deallocate()
    }
    
    func test_measureFeatureProviderCreationSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let (wavelet, colCount) = try self.spoofDetector.processImage(image)
        let (imgLL, imgLH, imgHL, imgHH) = self.spoofDetector.waveletDecomposition.haarTransformArray(wavelet, columnCount: colCount)
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        measure {
            _ = try! self.spoofDetector.featureProviderFromInput(multiArrays)
        }
        imgLL.deallocate()
        imgLH.deallocate()
        imgHL.deallocate()
        imgHH.deallocate()
    }
    
    func test_measureMoireDetectorPredictionSpeed() throws {
        let image = try self.firstCGImage(type: .moire, positive: true)
        let (wavelet, colCount) = try self.spoofDetector.processImage(image)
        let (imgLL, imgLH, imgHL, imgHH) = self.spoofDetector.waveletDecomposition.haarTransformArray(wavelet, columnCount: colCount)
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        let featureProvider = try self.spoofDetector.featureProviderFromInput(multiArrays)
        measure {
            _ = try! self.spoofDetector.predictionFromFeatureProvider(featureProvider)
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
        let multiArray = try spoofDetector.multiArrayFromTransform(&imgLL, name: "input_1")
        for i in 0..<imgLL.count {
            XCTAssertEqual(multiArray[[0,0,i,0] as [NSNumber]].floatValue, imgLL[i])
        }
    }
}
