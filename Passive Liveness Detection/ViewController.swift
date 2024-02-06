//
//  ViewController.swift
//  Passive Liveness Detection
//
//  Created by Jakub Dolejs on 26/10/2023.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func selectFromPhotos() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        if #available(iOS 17, *) {
            configuration.selection = .continuous
        }
        configuration.filter = .any(of: [.images])
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @IBAction func takePicture() {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.allowsEditing = false
        controller.cameraCaptureMode = .photo
        controller.cameraDevice = .front
        controller.cameraFlashMode = .off
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultViewController = segue.destination as? ResultViewController, let image = sender as? UIImage {
            resultViewController.image = image
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            guard let image = info[.originalImage] else {
                return
            }
            self.performSegue(withIdentifier: "result", sender: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            guard let asset = results.first(where: { $0.itemProvider.canLoadObject(ofClass: UIImage.self) }) else {
                return
            }
            asset.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                guard let img = image as? UIImage else {
                    return
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "result", sender: img)
                }
            }
        }
    }
}
