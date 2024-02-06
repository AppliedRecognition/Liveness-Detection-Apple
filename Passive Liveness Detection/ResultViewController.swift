//
//  ResultViewController.swift
//  Passive Liveness Detection
//
//  Created by Jakub Dolejs on 26/10/2023.
//

import UIKit
import Vision
import LivenessDetection

class ResultViewController: UIViewController {
    
    var image: UIImage?
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var table: UITableView!
    var scores: [(String,Float)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = self.image else {
            return
        }
        self.imageView.image = image
        Task {
            do {
                let spoofDetectors = try await self.createSpoofDetectors()
                let face = await self.detectFaceInImage(image)
                var annotatedImage: UIImage = image
                let shorterSide = min(image.size.width, image.size.height)
                if let faceRect = face {
                    UIGraphicsBeginImageContext(image.size)
                    defer {
                        UIGraphicsEndImageContext()
                    }
                    image.draw(at: .zero)
                    if let context = UIGraphicsGetCurrentContext() {
                        context.addPath(CGPath(roundedRect: faceRect, cornerWidth: shorterSide * 0.04, cornerHeight: shorterSide * 0.04, transform: nil))
                        context.setLineWidth(shorterSide * 0.01)
                        context.setStrokeColor(UIColor.green.cgColor)
                        context.strokePath()
                    }
                    if let img = UIGraphicsGetImageFromCurrentImageContext() {
                        annotatedImage = img
                    }
                }
                if let spoofDeviceDetector = spoofDetectors.first(where: { $0 is SpoofDeviceDetector }) as? SpoofDeviceDetector {
                    let spoofDevices = try spoofDeviceDetector.detectSpoofDevicesInImage(image)
                    if !spoofDevices.isEmpty {
                        UIGraphicsBeginImageContext(annotatedImage.size)
                        defer {
                            UIGraphicsEndImageContext()
                        }
                        annotatedImage.draw(at: .zero)
                        if let context = UIGraphicsGetCurrentContext() {
                            context.setLineWidth(shorterSide * 0.01)
                            context.setStrokeColor(UIColor.red.cgColor)
                            for spoofDevice in spoofDevices {
                                context.addPath(CGPath(roundedRect: spoofDevice.boundingBox, cornerWidth: shorterSide * 0.03, cornerHeight: shorterSide * 0.03, transform: nil))
                            }
                            context.strokePath()
                        }
                        if let img = UIGraphicsGetImageFromCurrentImageContext() {
                            annotatedImage = img
                        }
                    }
                }
                self.scores = try spoofDetectors.map {
                    let score = try $0.detectSpoofInImage(image, regionOfInterest: face)
                    return ($0.identifier,score)
                }
                DispatchQueue.main.async {
                    self.imageView.image = annotatedImage
                    self.table.dataSource = self
                    self.table.reloadData()
                    self.navigationItem.title = "Detection result"
                }
            } catch {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Detection failed"
                }
            }
        }
    }
    
    @IBAction func shareImage(_ button: UIBarButtonItem) {
        guard let image = self.image else {
            return
        }
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = button
        self.present(controller, animated: true)
    }
    
    func detectFaceInImage(_ image: UIImage) async -> CGRect? {
        do {
            let handler: VNImageRequestHandler
            if let cgImage = image.cgImage {
                handler = VNImageRequestHandler(cgImage: cgImage, orientation: self.image!.imageOrientation.cgImagePropertyOrientation)
            } else if let ciImage = image.ciImage {
                handler = VNImageRequestHandler(ciImage: ciImage, orientation: self.image!.imageOrientation.cgImagePropertyOrientation)
            } else {
                return nil
            }
            let transform = CGAffineTransform(scaleX: image.size.width, y: 0-image.size.height).concatenating(CGAffineTransform(translationX: 0, y: image.size.height))
            let imageCentreX = image.size.width/2
            let imageCentreY = image.size.height/2
            let request = VNDetectFaceRectanglesRequest()
            request.revision = VNDetectFaceRectanglesRequestRevision2
            try handler.perform([request])
            return request.results?
                .compactMap({ $0.boundingBox.applying(transform) })
                .sorted(by: { a, b in
                    hypot(a.midX - imageCentreX, a.midY - imageCentreY) < hypot(b.midX - imageCentreX, b.midY - imageCentreY)
                }).first
        } catch {
            return nil
        }
    }
    
    func createSpoofDetectors() async throws -> [SpoofDetector] {
        guard let modelURL = Bundle.main.url(forResource: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70", withExtension: "mlmodelc") else {
            fatalError("Model package not found")
        }
        let spoofDeviceDetector = try SpoofDeviceDetector(compiledModelURL: modelURL, identifier: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70")
        let moireDetectorName = "MoireDetectorModel_ep100_ntrn-627p-620n_02_res-98-99-96-0-5"
        guard let moireDetectorModelURL = Bundle.main.url(forResource: moireDetectorName, withExtension: "mlmodelc") else {
            fatalError("Moire detector model not found")
        }
        let moireDetector = try MoireDetector(compiledModelURL: moireDetectorModelURL, identifier: moireDetectorName)
        let psd003Name = "ARC_PSD-003_1.0.16_TRCD"
        guard let psd003ModelURL = Bundle.main.url(forResource: psd003Name, withExtension: "mlmodelc") else {
            fatalError("PSD003 detector model not found")
        }
        let psd003Detector = try SpoofDetector3(compiledModelURL: psd003ModelURL, identifier: psd003Name)
        return [spoofDeviceDetector, moireDetector, psd003Detector]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ResultViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (model, score) = self.scores[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell") as! ScoreCell
        cell.modelLabel.text = model
        cell.scoreLabel.text = String(format: "%.03f", score)
        return cell
    }
}

extension UIImage.Orientation {
    
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up:
            return .up
        case .right:
            return .right
        case .down:
            return .down
        case .left:
            return .left
        case .upMirrored:
            return .upMirrored
        case .rightMirrored:
            return .rightMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        default:
            return .up
        }
    }
}

class ScoreCell: UITableViewCell {
    
    @IBOutlet var modelLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
}
