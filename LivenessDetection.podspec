Pod::Spec.new do |spec|
  spec.name         = "LivenessDetection"
  spec.version      = "1.2.0"
  spec.summary      = "Detects whether an image or its part were taken live or off a screen or a photograph"
  spec.homepage     = "https://github.com/AppliedRecognition/Liveness-Detection-Apple"
  spec.license = { :type => "COMMERCIAL", :file => "LICENCE.txt" }
  spec.author             = "Jakub Dolejs"
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/AppliedRecognition/Liveness-Detection-Apple.git", :tag => "v#{spec.version}" }
  spec.source_files  = "Sources/LivenessDetection"
end
