//
//  ViewController.swift
//  Instafilter
//
//  Created by Camilo Hernández Guerrero on 8/07/22.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var slider: UISlider!
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context =  CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(createAlertAction(using: "CIBumpDistortion"))
        alertController.addAction(createAlertAction(using: "CIGaussianBlur"))
        alertController.addAction(createAlertAction(using: "CIPixellate"))
        alertController.addAction(createAlertAction(using: "CISepiaTone"))
        alertController.addAction(createAlertAction(using: "CITwirlDistortion"))
        alertController.addAction(createAlertAction(using: "CIUnsharpMask"))
        alertController.addAction(createAlertAction(using: "CIVignette"))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @objc func importPicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        setInputKeys()
        
        guard let CIImage = currentFilter.outputImage else { return }
        
        if let CGImage = context.createCGImage(CIImage, from: CIImage.extent) {
            imageView.image = UIImage(cgImage: CGImage)
        }
    }
    
    func createAlertAction(using title: String) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: setFilter)
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        guard let actionTitle = action.title else { return }
        let beginImage = CIImage(image: currentImage)
        
        currentFilter = CIFilter(name: actionTitle)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func setInputKeys() {
        let inputKeys = currentFilter.inputKeys
        let imageSize = currentImage.size
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(slider.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(slider.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(slider.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: imageSize.width / 2, y: imageSize.height / 2), forKey: kCIInputCenterKey)
        }
    }
}
