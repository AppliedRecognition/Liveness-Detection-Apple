//
//  ImageProcessingError.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import Foundation

public enum ImageProcessingError: Error {
    case cgImageConversionError,
    pixelBufferInitializationError,
    cgImageFromBufferError,
    imageMatrixMultiplyError,
    imageRotationError,
    imageResizingError
}
