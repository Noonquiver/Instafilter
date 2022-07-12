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
    @IBOutlet var intensity: UISlider!
    @IBOutlet var scale: UISlider!
    @IBOutlet var radius: UISlider!
    @IBOutlet var changeFilterButton: UIButton!
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context =  CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        imageView.alpha = 0
        intensity.tintColor = .gray
        intensity.isUserInteractionEnabled = false
        scale.tintColor = .gray
        scale.isUserInteractionEnabled = false
        radius.tintColor = .gray
        radius.isUserInteractionEnabled = false
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Change filter", message: nil, preferredStyle: .actionSheet)
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
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let alertController = UIAlertController(title: "No image", message: "There's no image to save, try selecting one first.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default))
            present(alertController, animated: true)
        }
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func scaleChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: Any) {
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
        
        UIView.animate(withDuration: 2, delay: 0.1) {
            self.imageView.alpha = 1
        }
        
        currentImage = image

        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        turnOnSliders()
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
        changeFilterButton.setTitle(currentFilter.name, for: .normal)
        
        applyProcessing()
    }
    
    func turnOnSliders() {
        intensity.tintColor = .systemBlue
        intensity.isUserInteractionEnabled = true
        scale.tintColor = .systemBlue
        scale.isUserInteractionEnabled = true
        radius.tintColor = .systemBlue
        radius.isUserInteractionEnabled = true
    }
    
    func setInputKeys() {
        let inputKeys = currentFilter.inputKeys
        let imageSize = currentImage.size
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        } else {
            intensity.tintColor = .gray
            intensity.isUserInteractionEnabled = false
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(scale.value * 10, forKey: kCIInputScaleKey)
        } else {
            scale.tintColor = .gray
            scale.isUserInteractionEnabled = false
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
        } else {
            radius.tintColor = .gray
            radius.isUserInteractionEnabled = false
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: imageSize.width / 2, y: imageSize.height / 2), forKey: kCIInputCenterKey)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alertController = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default))
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default))
            present(alertController, animated: true)
        }
    }
}
