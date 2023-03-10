//
//  MoireDetector.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import Foundation
import UIKit
import CoreML
import Accelerate

/// Moire detector
///
/// Detects moire pattern artifacts in image
/// - Since: 1.0.0
public class MoireDetector: SpoofDetector {
    
    let imageLongerSideLength: Int = 1000
    let imageShorterSideLength: Int = 750
    let waveletDecomposition: WaveletDecomposition
    let model: MLModel
    
    /// Asynchronous constructor
    /// - Parameter modelURL: Model file URL
    /// - Since: 1.0.0
    @available(iOS 16, macOS 13, macCatalyst 16, *)
    public convenience init(modelURL: URL) async throws {
        let compiledModelURL = try await MLModel.compileModel(at: modelURL)
        try self.init(compiledModelURL: compiledModelURL, identifier: modelURL.lastPathComponent)
    }
    
    /// Constructor
    /// - Parameter modelURL: Model file URL
    public convenience init(modelURL: URL) throws {
        let compiledModelURL = try MLModel.compileModel(at: modelURL)
        try self.init(compiledModelURL: compiledModelURL, identifier: modelURL.lastPathComponent)
    }
    
    private init(compiledModelURL: URL, identifier: String) throws {
        self.waveletDecomposition = WaveletDecomposition()
        self.model = try MLModel(contentsOf: compiledModelURL)
        self.identifier = identifier
    }
    
    // MARK: - SpoofDetector
    
    public let identifier: String
    
    public var confidenceThreshold: Float = 0.3
    
    public func detectSpoofInImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> Float {
        if #available(iOS 13, *) {
            return try self.detectMoireInImage(image)
        } else if let cgImage = image.cgImage {
            return try self.detectMoireInImage(cgImage)
        } else {
            throw ImageProcessingError.cgImageConversionError
        }
    }
    
    // MARK: -
    
    /// Detect moire pattern interference artifacts in image
    /// - Parameter image: Image
    /// - Returns: Confidence score between `0.0` and `1.0` where `0` means 100% confidence that the image
    /// does not contain moire artifacts and `1` means 100% confidence that it does.
    /// - Since: 1.0.0
    public func detectMoireInImage(_ image: CGImage) throws -> Float {
        let wavelet: Array2D<UInt8> = try self.processImage(image)
        let (imgLL, imgLH, imgHL, imgHH) = try self.waveletDecomposition.haarTransformArray(wavelet)
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        let featureProvider = try self.featureProviderFromInput(multiArrays)
        let prediction = try self.predictionFromFeatureProvider(featureProvider)
        imgLL.deallocate()
        imgLH.deallocate()
        imgHL.deallocate()
        imgHH.deallocate()
        return prediction[0].floatValue
    }
    
    /// Detect moire pattern interference artifacts in image
    /// - Parameter image: Image
    /// - Returns: Confidence score between `0.0` and `1.0` where `0` means 100% confidence that the image
    /// does not contain moire artifacts and `1` means 100% confidence that it does.
    /// - Since: 1.1.0
    @available(iOS 13, *)
    public func detectMoireInImage(_ image: UIImage) throws -> Float {
        guard let cgImage: CGImage = self.cgImageFromUIImage(image) else {
            throw ImageProcessingError.cgImageConversionError
        }
        let rotatedImage = try self.rotateCGImage(cgImage, orientation: image.imageOrientation)
        return try self.detectMoireInImage(rotatedImage)
    }
    
    func cgImageFromUIImage(_ uiImage: UIImage) -> CGImage? {
        if let cg = uiImage.cgImage {
            return cg
        } else if let ci = uiImage.ciImage {
            let context = CIContext(options: nil)
            if let cg = context.createCGImage(ci, from: ci.extent) {
                return cg
            }
        }
        return nil
    }
    
    func predictionFromFeatureProvider(_ featureProvider: MLDictionaryFeatureProvider) throws -> MLMultiArray {
        guard let prediction = try self.model.prediction(from: featureProvider).featureValue(for: "Identity")?.multiArrayValue else {
            throw MoireDetectorError.predictionFailure
        }
        return prediction
    }
    
    func multiArrayFromTransform(_ transform: UnsafeMutablePointer<Float>, name: String) throws -> MLMultiArray {
        let shape = [1, 375, 500, 1] as [NSNumber]
        let strides = [187500, 500, 1, 1] as [NSNumber]
        return try MLMultiArray(dataPointer: transform, shape: shape, dataType: .float32, strides: strides)
    }
    
    func featureProviderFromInput(_ input: [String: UnsafeMutablePointer<Float>]) throws -> MLDictionaryFeatureProvider {
        let multis = try input.map { k, v in
            return (k, try self.multiArrayFromTransform(v, name: k))
        }
        let dict = multis.reduce(into: [String:MLFeatureValue](), { $0[$1.0] = MLFeatureValue(multiArray: $1.1) })
        return try MLDictionaryFeatureProvider(dictionary: dict)
    }
    
    func featureProviderFromMultiArrays(_ multiArrays: [String:MLMultiArray]) throws -> MLDictionaryFeatureProvider {
        let dict = multiArrays.mapValues({ MLFeatureValue(multiArray: $0) })
        return try MLDictionaryFeatureProvider(dictionary: dict)
    }
    
    func processImage(_ image: CGImage) throws -> Array2D<UInt8> {
        guard let resizedImage = self.resizeImage(image) else {
            throw ImageProcessingError.imageResizingError
        }
        let orientation: CGImagePropertyOrientation = resizedImage.width > resizedImage.height ? .up : .left
        let grayscale = try self.grayscaleFromCGImage(resizedImage, orientation: orientation)
        return grayscale
    }
    
    @available(iOS 13, *)
    func rotateCGImage(_ cgImage: CGImage, orientation: UIImage.Orientation) throws -> CGImage {
        let rotation: UInt8
        switch orientation {
        case .right, .rightMirrored:
            rotation = 3
        case .left, .leftMirrored:
            rotation = 1
        case .down, .downMirrored:
            rotation = 2
        default:
            return cgImage
        }
        let outWidth: UInt
        let outHeight: UInt
        // Flip width and height if the image is rotated 90 or 270 degrees
        if rotation == 1 || rotation == 3 {
            outWidth = UInt(cgImage.height)
            outHeight = UInt(cgImage.width)
        } else {
            outWidth = UInt(cgImage.width)
            outHeight = UInt(cgImage.height)
        }
        var imageBuffer = try self.imageBufferFromCGImage(cgImage)
        defer {
            imageBuffer.free()
        }
        // Set the bytes per row for the rotated image
        let outBytesPerRow: Int = Int(outWidth) * cgImage.bitsPerPixel / 8
        // Calculate the size of the rotated image buffer
        let destSize = outBytesPerRow * Int(outHeight) * MemoryLayout<UInt8>.size
        let rotatedData = UnsafeMutablePointer<UInt8>.allocate(capacity: destSize)
        var outBuffer = vImage_Buffer(data: rotatedData, height: outHeight, width: outWidth, rowBytes: outBytesPerRow)
        defer {
            outBuffer.free()
        }
        if cgImage.bitsPerPixel == 32 {
            var backgroundColour: UInt8 = 0
            vImageRotate90_ARGB8888(&imageBuffer, &outBuffer, rotation, &backgroundColour, numericCast(kvImageNoFlags))
        } else if cgImage.bitsPerPixel == 8 {
            vImageRotate90_Planar8(&imageBuffer, &outBuffer, rotation, 0, numericCast(kvImageNoFlags))
        } else {
            return cgImage
        }
        let colourSpace: Unmanaged<CGColorSpace> = cgImage.colorSpace != nil ? Unmanaged.passRetained(cgImage.colorSpace!) : Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB())
        let format = vImage_CGImageFormat(bitsPerComponent: UInt32(cgImage.bitsPerComponent), bitsPerPixel: UInt32(cgImage.bitsPerPixel), colorSpace: colourSpace, bitmapInfo: cgImage.bitmapInfo, version: 0, decode: nil, renderingIntent: .defaultIntent)
        return try outBuffer.createCGImage(format: format)
    }
    
    func imageBufferFromCGImage(_ cgImage: CGImage) throws -> vImage_Buffer {
        var colourSpace: Unmanaged<CGColorSpace> = cgImage.colorSpace != nil ? Unmanaged.passRetained(cgImage.colorSpace!) : Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB())
        var format = vImage_CGImageFormat(bitsPerComponent: UInt32(cgImage.bitsPerComponent), bitsPerPixel: UInt32(cgImage.bitsPerPixel), colorSpace: colourSpace, bitmapInfo: cgImage.bitmapInfo, version: 0, decode: nil, renderingIntent: .defaultIntent)
        let originalLength = cgImage.height * cgImage.bytesPerRow
        let originalBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: originalLength)
        var originalBuffer = vImage_Buffer(data: originalBytes, height:vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.bytesPerRow)
        let error = vImageBuffer_InitWithCGImage(&originalBuffer, &format, nil, cgImage, numericCast(kvImageNoAllocate))
        guard error == kvImageNoError else {
            if #available(iOS 13, *) {
                originalBuffer.free()
            } else {
                originalBytes.deallocate()
            }
            throw ImageProcessingError.cgImageFromBufferError
        }
        return originalBuffer
    }
    
    func grayscaleFromCGImage(_ cgImage: CGImage, orientation: CGImagePropertyOrientation) throws -> Array2D<UInt8> {
        var colourSpace: Unmanaged<CGColorSpace>
        if cgImage.colorSpace != nil {
            colourSpace = Unmanaged.passRetained(cgImage.colorSpace!)
        } else {
            colourSpace = Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB())
        }
        var format = vImage_CGImageFormat(bitsPerComponent: UInt32(cgImage.bitsPerComponent), bitsPerPixel: UInt32(cgImage.bitsPerPixel), colorSpace: colourSpace, bitmapInfo: cgImage.bitmapInfo, version: 0, decode: nil, renderingIntent: .defaultIntent)
        let originalLength = cgImage.height * cgImage.bytesPerRow
        let originalBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: originalLength)
        var originalBuffer = vImage_Buffer(data: originalBytes, height:vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.bytesPerRow)
        defer {
            if #available(iOS 13, *) {
                originalBuffer.free()
            } else {
                originalBytes.deallocate()
            }
        }
        var error = vImageBuffer_InitWithCGImage(&originalBuffer, &format, nil, cgImage, numericCast(kvImageNoAllocate))
        guard error == kvImageNoError else {
            throw ImageProcessingError.cgImageFromBufferError
        }
        if cgImage.bitsPerPixel == 8 {
            return try self.correctOrientationInImage(&originalBuffer, orientation: orientation)
        }
        let outLength = cgImage.width * cgImage.height
        let outPixels = UnsafeMutablePointer<UInt8>.allocate(capacity: outLength)
        var outputPlanar = vImage_Buffer(data: outPixels, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width)
        defer {
            if #available(iOS 13, *) {
                outputPlanar.free()
            } else {
                outPixels.deallocate()
            }
        }
        let divisor: Float = 0x1000
        var matrix: [Int16] = [0,Int16(0.299*divisor),Int16(0.587*divisor),Int16(0.114*divisor)]
        error = vImageMatrixMultiply_ARGB8888ToPlanar8(&originalBuffer, &outputPlanar, &matrix, Int32(divisor), nil, 0, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else {
            throw ImageProcessingError.imageMatrixMultiplyError
        }
        return try self.correctOrientationInImage(&outputPlanar, orientation: orientation)
    }
    
    func correctOrientationInImage(_ image: inout vImage_Buffer, orientation: CGImagePropertyOrientation) throws -> Array2D<UInt8> {
        // Get the vImage rotation constant based on the UI orientation
        let rotation: UInt8
        switch orientation {
        case .right, .rightMirrored:
            rotation = 3
        case .up, .upMirrored:
            rotation = 0
        case .left, .leftMirrored:
            rotation = 1
        case .down, .downMirrored:
            rotation = 2
        }
        let outWidth: UInt
        let outHeight: UInt
        // Flip width and height if the image is rotated 90 or 270 degrees
        if rotation == 1 || rotation == 3 {
            outWidth = UInt(image.height)
            outHeight = UInt(image.width)
        } else {
            outWidth = UInt(image.width)
            outHeight = UInt(image.height)
        }
        // Set the bytes per row for the rotated image
        let outBytesPerRow: Int = Int(outWidth)
        // Calculate the size of the rotated image buffer
        let destSize = outBytesPerRow * Int(outHeight) * MemoryLayout<UInt8>.size
        let rotatedData = UnsafeMutablePointer<UInt8>.allocate(capacity: destSize)
        var outBuffer = vImage_Buffer(data: rotatedData, height: outHeight, width: outWidth, rowBytes: outBytesPerRow)
        defer {
            if #available(iOS 13, *) {
                outBuffer.free()
            } else {
                rotatedData.deallocate()
            }
        }
        guard vImageRotate90_Planar8(&image, &outBuffer, rotation, 0, numericCast(kvImageNoFlags)) == kvImageNoError else {
            throw ImageProcessingError.imageRotationError
        }
        let grayscaleData = Array(UnsafeBufferPointer(start: rotatedData, count: destSize))
        return try Array2D(data: grayscaleData, cols: Int(outWidth), rows: Int(outHeight))
    }
    
    func debugImageFromGrayscaleArray(_ grayscaleArray: Array2D<UInt8>) throws -> UIImage {
        let targetColourSpace = Unmanaged.passUnretained(CGColorSpaceCreateDeviceGray())
        var targetFormat = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 8, colorSpace: targetColourSpace, bitmapInfo: CGBitmapInfo(rawValue: 0), version: 0, decode: nil, renderingIntent: .defaultIntent)
        var input: [UInt8] = grayscaleArray.data
        let grayscalePixels = UnsafeMutablePointer<UInt8>.allocate(capacity: grayscaleArray.data.count)
        grayscalePixels.initialize(from: &input, count: input.count)
        var grayscaleBuffer = vImage_Buffer(data: grayscalePixels, height: vImagePixelCount(grayscaleArray.rows), width: vImagePixelCount(grayscaleArray.cols), rowBytes: grayscaleArray.cols)
        defer {
            if #available(iOS 13, *) {
                grayscaleBuffer.free()
            } else {
                grayscalePixels.deallocate()
            }
        }
        var error: Int = kvImageNoError
        guard let target = vImageCreateCGImageFromBuffer(&grayscaleBuffer, &targetFormat, nil, nil, numericCast(kvImageNoFlags), &error) else {
            throw ImageProcessingError.cgImageFromBufferError
        }
        return UIImage(cgImage: target.takeRetainedValue())
    }
    
    func resizeImage(_ image: CGImage) -> CGImage? {
        let size: CGSize
        if image.width > image.height {
            size = CGSize(width: self.imageLongerSideLength, height: self.imageShorterSideLength)
        } else {
            size = CGSize(width: self.imageShorterSideLength, height: self.imageLongerSideLength)
        }
        let uiImage = UIImage(cgImage: image)
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        uiImage.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
}

enum MoireDetectorError: Int, Error {
    case predictionFailure, failedToInferMultiArrayShape
}
