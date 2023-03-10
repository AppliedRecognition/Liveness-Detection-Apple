![Cocoapods](https://img.shields.io/cocoapods/v/LivenessDetection)

# Liveness Detection

The LivenessDetection framework detects whether an image or its part were taken live or off a screen or a photograph.

The framework has two detectors:

- **Moire detector**<br />Finds moire pattern interference artifacts
- **Spoof device detector**<br />Finds devices that can be used to spoof liveness, e.g., screens, photographs

## Installation from CocoaPods

- Add the following dependency in your Podfile:

    ```ruby
    pod 'LivenessDetection'
    ```
- Run

    ```
    pod install
    ```
    
## Usage

1. [Contact Applied Recognition](mailto:support@appliedrecognition.com) to obtain machine learning model files.
2. Copy the model files to your app's resources.

### Moire detection

```swift
func detectMoireInImage(_ image: CGImage) -> Float? {
    // Get the model URL from your app's resource bundle
    guard let moireDetectorModelURL = Bundle.main.url(forResource: "MoireDetectorModel", withExtension: "mlmodel") else {
        return nil
    }
    // Load the moire detector
    guard let moireDetector = try? MoireDetector(modelURL: moireDetectorModelURL) else {
        return nil
    }
    // Run the moire detection
    return try? moireDetector.detectMoireInImage(cgImage)
}
```

### Spoof device detection

```swift
func detectSpoofDevicesInImage(_ image: UIImage) -> [DetectedSpoofDevice]? {
    // Get the model URL from your app's resource bundle
    guard let spoofDeviceDetectorModelURL = Bundle.main.url(forResource: "SpoofDeviceDetectorModel", withExtension: "mlmodel") else {
        return nil
    }
    // Load the spoof device detector
    guard let spoofDeviceDetector = try? SpoofDeviceDetector(modelURL: spoofDeviceDetectorModelURL) else {
        return nil
    }
    return try? spoofDeviceDetector.detectSpoofDevicesInImage(image)
}
```

### Spoof detection using detector 3

```swift
func detectSpoofInImage(_ image: UIImage) -> Float? {
    // Get the model URL from your app's resource bundle
    guard let spoofDetectorModelURL = Bundle.main.url(forResource: "SpoofDetector3Model", withExtension: "mlmodel") else {
        return nil
    }
    // Load the spoof detector
    guard let spoofDetector = try? SpoofDetector3(modelURL: spoofDetectorModelURL) else {
        return nil
    }
    // Run the spoof detection
    return try? spoofDetector.detectSpoofInImage(image)
}
```

### Note
Loading/compiling the model file can be somewhat expensive. You will want to construct the detectors on a background thread. Unless you're only detecting liveness in one image, you will most likely want to construct the detectors once instead of creating a new instance for each detection.

Here is a more complete, better optimised example:

```swift
class LivenessDetection {

    class func create(completion: Result<LivenessDetection,Error>) {
        DispatchQueue.global().async {
            do {
                // Get the model URL from your app's resource bundle
                guard let moireDetectorModelURL = Bundle.main.url(forResource: "MoireDetectorModel", withExtension: "mlmodel") else {
                    throw LivenessDetectionError.failedToFindMoireDetectorModelFile
                }
                // Load the moire detector
                let moireDetector = try MoireDetector(modelURL: moireDetectorModelURL)
                // Get the model URL from your app's resource bundle
                guard let spoofDeviceDetectorModelURL = Bundle.main.url(forResource: "SpoofDeviceDetectorModel", withExtension: "mlmodel") else {
                    throw LivenessDetectionError.failedToFindSpoofDeviceDetectorModelFile
                }
                // Load the spoof device detector
                let spoofDeviceDetector = try? SpoofDeviceDetector(modelURL: spoofDeviceDetectorModelURL)
                // Get the model URL from your app's resource bundle
                guard let spoofDetector3ModelURL = Bundle.main.url(forResource: "SpoofDetector3Model", withExtension: "mlmodel") else {
                    throw LivenessDetectionError.failedToFindSpoofDetector3ModelFile
                }
                // Load spoof detector 3
                let spoofDetector3 = try? SpoofDetector3(modelURL: spoofDetector3ModelURL)
                completion(.success(LivenessDetection(moireDetector: moireDetector, spoofDeviceDetector: spoofDeviceDetector, spoofDetector3: spoofDetector3))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    let moireDetector: MoireDetector
    let spoofDeviceDetector: SpoofDeviceDetector
    let spoofDetector3: SpoofDetector3
    let confidenceThreshold: Float = 0.5
    
    private init(moireDetector: MoireDetector, spoofDeviceDetector: SpoofDeviceDetector, spoofDetector3: SpoofDetector3) {
        self.moireDetector = moireDetector
        self.spoofDeviceDetector = spoofDeviceDetector
        self.spoofDetector3 = spoofDetector3
    }
    
    func detectLivenessInImage(_ image: UIImage, completion: Result<Boolean,Error>) {
        DispatchQueue.global().async {
            do {
                var passed: Boolean = true
                let spoofDevice = try self.spoofDeviceDetector.detectSpoofDevicesInImage(image).sorted(by: { $0.confidence > $1.confidence }).first
                if let device = spoofDevice, device.confidence > self.confidenceThreshold {
                    passed = false
                }
                if passed {
                    guard let cgImage = image.cgImage else {
                        throw LivenessDetectionError.failedToCreateCGImageFromUIImage
                    }
                    let moireConfidence = try self.moireDetector.detectMoireInImage(cgImage)
                    passed = moireConfidence > self.confidenceThreshold
                }
                if passed {
                    let spoofConfidence = try self.spoofDetector3.detectSpoofInImage(image)
                    passed = spoofConfidence > self.confidenceThreshold
                }
                completion(.success(passed))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

enum LivenessDetectionError: Error {
    case failedToFindMoireDetectorModelFile
    case failedToFindSpoofDeviceDetectorModelFile
    case failedToFindSpoofDetector3ModelFile
    case failedToCreateCGImageFromUIImage
}
```

Usage of the example class:

```swift
LivenessDetection.create { result in
    switch result {
        case .success(let livenessDetection):
            livenessDetection.detectLivenessInImage(image) { result in
                switch result {
                case .success(let passed):
                    NSLog("Liveness detection %@", passed ? "passed" : "failed")
                case .failure(let error):
                    NSLog("Liveness detection failed: %@", error.localizedDescription)
                }
            }
        case .failure(let error):
            NSLog("Failed to create liveness detection instance: %@", error.localizedDescription)
    }
}
```