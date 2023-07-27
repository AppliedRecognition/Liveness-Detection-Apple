//
//  SpoofDetector4Component.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 21/07/2023.
//

import Foundation
import UIKit
import CoreML
import Accelerate

class SpoofDetector4Component {
    
    let model: MLModel
    let config: SpoofDetector4Config
    let identifier: String
    lazy var shape = [1, 3, config.width, config.height] as [NSNumber]
    lazy var strides = [config.width * config.height * 3, config.width * config.height, config.width, 1] as [NSNumber]
    
    convenience init(configuration: SpoofDetector4Config) throws {
        let compiledModelURL = try MLModel.compileModel(at: configuration.modelURL)
        try self.init(compiledModelURL: compiledModelURL, identifier: configuration.modelURL.lastPathComponent, config: configuration)
    }
    
    private init(compiledModelURL: URL, identifier: String, config: SpoofDetector4Config) throws {
        self.model = try MLModel(contentsOf: compiledModelURL)
        self.identifier = identifier
        self.config = config
    }
    
    func detectSpoofInImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> Float {
        let img = self.cropAndResizeImage(image, cropRect: self.calculateRoi(imageSize: image.size, face: roi), destSize: CGSize(width: self.config.width, height: self.config.height))
        let multiArray = try self.prepareImage(img)
        let featureProvider = try MLDictionaryFeatureProvider(dictionary: ["input_1": multiArray])
        let prediction = try self.model.prediction(from: featureProvider)
        let softmax = try self.softmaxFromFeatureProvider(prediction)
        return softmax[0]
    }
    
    func predictionFromImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> [Float] {
        let img = self.cropAndResizeImage(image, cropRect: self.calculateRoi(imageSize: image.size, face: roi), destSize: CGSize(width: self.config.width, height: self.config.height))
        let multiArray = try self.prepareImage(img)
        let featureProvider = try MLDictionaryFeatureProvider(dictionary: ["input_1": multiArray])
        let prediction = try self.model.prediction(from: featureProvider)
        return try self.softmaxFromFeatureProvider(prediction)
    }
    
    private func floatArrayFromFeatureProvider(_ featureProvider: MLFeatureProvider) throws -> [Float] {
        guard let outputKey = self.model.modelDescription.outputDescriptionsByName.keys.first else {
            throw NSError()
        }
        guard let multiArray = (featureProvider as? MLDictionaryFeatureProvider)?[outputKey]?.multiArrayValue else {
            throw NSError()
        }
        var vec: [Float] = []
        for i in 0..<multiArray.count {
            vec.append(multiArray[i].floatValue)
        }
        return vec
    }
    
    private func softmaxFromFeatureProvider(_ featureProvider: MLFeatureProvider) throws -> [Float] {
        let vec = try self.floatArrayFromFeatureProvider(featureProvider)
        return Utils.softmax(vec)
    }
    
    private func prepareImage(_ cgImage: CGImage) throws -> MLMultiArray {
        let colourSpace: Unmanaged<CGColorSpace> = cgImage.colorSpace != nil ? Unmanaged.passRetained(cgImage.colorSpace!) : Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB())
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
        let trimmedBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: cgImage.width * cgImage.height * 4)
        var trimmedBuffer = vImage_Buffer(data: trimmedBytes, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width * 4)
        defer {
            if #available(iOS 13, *) {
                trimmedBuffer.free()
            } else {
                trimmedBytes.deallocate()
            }
        }
        error = vImageCopyBuffer(&originalBuffer, &trimmedBuffer, 4, numericCast(kvImageNoAllocate))
        guard error == kvImageNoError else {
            throw NSError()
        }
        
        let channelSize = cgImage.width * cgImage.height
        var offset = 0
        let input = UnsafeMutablePointer<Float32>.allocate(capacity: channelSize * 3)
        for i in 0..<3 {
            let channelBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: channelSize)
            var channelBuffer = vImage_Buffer(data: channelBytes, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width)
            defer {
                if #available(iOS 13, *) {
                    channelBuffer.free()
                } else {
                    channelBytes.deallocate()
                }
            }
            error = vImageExtractChannel_ARGB8888(&trimmedBuffer, &channelBuffer, i, numericCast(kvImageNoFlags))
            guard error == kvImageNoError else {
                throw NSError()
            }
            let floatBytes = UnsafeMutablePointer<Float32>.allocate(capacity: channelSize)
            var floatBuffer = vImage_Buffer(data: floatBytes, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width * 4)
            defer {
                if #available(iOS 13, *) {
                    floatBuffer.free()
                } else {
                    floatBytes.deallocate()
                }
            }
            error = vImageConvert_Planar8toPlanarF(&channelBuffer, &floatBuffer, 255.0, 0.0, numericCast(kvImageNoFlags))
            guard error == kvImageNoError else {
                throw NSError()
            }
            (input + offset).initialize(from: floatBytes, count: channelSize)
            offset += channelSize
        }
        return try MLMultiArray(dataPointer: input, shape: self.shape, dataType: .float32, strides: self.strides)
    }
    
    private func cropAndResizeImage(_ image: UIImage, cropRect: CGRect?, destSize: CGSize) -> CGImage {
        UIGraphicsBeginImageContext(destSize)
        defer {
            UIGraphicsEndImageContext()
        }
        let destOrigin: CGPoint
        if let rect = cropRect {
            let xScale = destSize.width / rect.width
            let yScale = destSize.height / rect.height
            destOrigin = CGPoint(x: 0-rect.minX*xScale, y: 0-rect.minY*yScale)
        } else {
            destOrigin = .zero
        }
        image.draw(in: CGRect(origin: destOrigin, size: destSize))
        return UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
    }
    
    private func calculateRoi(imageSize: CGSize, face: CGRect?) -> CGRect? {
        guard let faceRect = face else {
            return nil
        }
        let x = Int(faceRect.minX)
        let y = Int(faceRect.minY)
        let boxWidth = Int(faceRect.width + 1)
        let boxHeight = Int(faceRect.height + 1)
        let shiftX = Int(Float(boxWidth) * self.config.shiftX)
        let shiftY = Int(Float(boxHeight) * self.config.shiftY)
        let scale = min(
            config.scale,
            min(
                Float(imageSize.width) - 1 / Float(boxWidth),
                Float(imageSize.height - 1) / Float(boxHeight)
            )
        )
        let boxCenterX = boxWidth / 2 + x
        let boxCenterY = boxHeight / 2 + y
        let newWidth = Int(Float(boxWidth) * scale)
        let newHeight = Int(Float(boxHeight) * scale)
        var leftTopX = boxCenterX - newWidth / 2 + shiftX
        var leftTopY = boxCenterY - newHeight / 2 + shiftY
        var rightBottomX = boxCenterX + newWidth / 2 + shiftX
        var rightBottomY = boxCenterY + newHeight / 2 + shiftY
        if leftTopX < 0 {
            rightBottomX -= leftTopX
            leftTopX = 0
        }
        if leftTopY < 0 {
            rightBottomY -= leftTopY
            leftTopY = 0
        }
        if rightBottomX >= Int(imageSize.width) {
            let s = rightBottomX - Int(imageSize.width) + 1
            leftTopX -= s
            rightBottomX -= s
        }
        if (rightBottomY >= Int(imageSize.height)) {
            let s = rightBottomY - Int(imageSize.height) + 1
            leftTopY -= s
            rightBottomY -= s
        }
        return CGRect(x: leftTopX, y: leftTopY, width: newWidth, height: newHeight)
    }
}
