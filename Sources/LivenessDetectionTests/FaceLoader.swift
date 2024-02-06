//
//  FaceLoader.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 24/10/2023.
//

import Foundation

class FaceLoader {
    
    let facesURL = "http://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/faces.json"
    private let faces: [String:CGRect]
    
    init?() {
        guard let url = URL(string: self.facesURL), let data = try? Data(contentsOf: url) else {
            return nil
        }
        guard let faces = try? JSONDecoder().decode([String:Rect].self, from: data) else {
            return nil
        }
        self.faces = faces.mapValues({ CGRect(x: $0.x, y: $0.y, width: $0.width, height: $0.height) })
    }
    
    func faceInImage(_ image: String) -> CGRect? {
        self.faces[image]
    }
}

fileprivate struct Rect: Decodable {
    
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}
