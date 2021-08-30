//
//  ViewController.swift
//  MemeMachine
//
//  Created by Atin Agnihotri on 30/08/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var memeImageView: UIImageView!
    
    var topText: String?
    var bottomText: String?
    var sourceImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    func setupNavBar() {
        title = "Meme Machine"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Import Image Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importImageTapped))
        
        // Share Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    @objc func importImageTapped() {
        var actions = [UIAlertAction]()
        
        // Import image from Photo Library
        let library = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.importImageFromLibrary()
        }
        actions.append(library)
        
        // Import image from Camera if available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let camera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.importImageFromCamera()
            }
            actions.append(camera)
        }
        
        // Cancel
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        actions.append(cancel)
        
        showActionSheet(title: "Import Image", actions: actions)
    }
    
    func importImageFromLibrary() {
        showImagePicker(for: .photoLibrary)
    }
    
    func importImageFromCamera() {
        showImagePicker(for: .camera)
    }
    
    func showImagePicker(for sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func shareTapped() {
        if let imageData = memeImageView.image?.jpegData(compressionQuality: 0.8) {
            let ac = UIActivityViewController(activityItems: [imageData], applicationActivities: [])
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(ac, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        sourceImage = image
        promptMemeTopText()
    }
    
    func promptMemeTopText() {
        promptMemeText(forTop: true)
    }
    
    func promptMemeBottomText() {
        promptMemeText(forTop: false)
    }
    
    func promptMemeText(forTop: Bool) {
        let orientation = forTop ? "top" : "bottom"
        let title = "Enter \(orientation) text"
        let ac = UIAlertController(title: title, message: "Leave empty if desired", preferredStyle: .alert)
        
        ac.addTextField()
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak ac] _ in
            guard let text = ac?.textFields?[0].text else { return }
            if forTop {
                self?.topText = text
                self?.promptMemeBottomText()
            } else {
                self?.bottomText = text
                self?.setEditedImage()
            }
        }
        
        ac.addAction(confirm)
        
        present(ac, animated: true)
    }
    
    func setEditedImage() {
        guard let sourceImage = sourceImage else {
            showWarning(title: "No image", message: "No image selected to memify")
            return
        }
        
        let memifiedImageSize = CGSize(width: sourceImage.size.width, height: sourceImage.size.height + 200)
        
        print("Image Width: \(memifiedImageSize.width), Height: \(memifiedImageSize.height)")
        
        let renderer = UIGraphicsImageRenderer(size: memifiedImageSize)
        
        let memifiedImage = renderer.image {  context in
            let cgContext = context.cgContext
            
            let imageRect = CGRect(x: 0, y: 0, width: memifiedImageSize.width, height: memifiedImageSize.height)
            cgContext.addRect(imageRect)
            cgContext.setFillColor(UIColor.black.cgColor)
            cgContext.drawPath(using: .fillStroke)
            
            let isBigImage = imageRect.size.width > 500
            
            if let topText = topText {
                let topTextRect = CGRect(x: 0, y: isBigImage ? 30 : 10, width: sourceImage.size.width, height: 100)
                let attributedTopText = getMemeText(for: topText)
                attributedTopText.draw(with: topTextRect, options: .usesLineFragmentOrigin, context: nil)
            }
            
            if let bottomText = bottomText {
                let topTextRect = CGRect(x: 0, y: sourceImage.size.height + 100 + (isBigImage ? 30 : 10), width: sourceImage.size.width, height: 100)
                let attributedTopText = getMemeText(for: bottomText)
                attributedTopText.draw(with: topTextRect, options: .usesLineFragmentOrigin, context: nil)
            }
            
            sourceImage.draw(at: CGPoint(x: 0, y: 100))
        }
        
        memeImageView.image = memifiedImage
    }
    
    func getMemeText(for string: String) -> NSAttributedString {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .bold),
            .paragraphStyle: paraStyle,
            .foregroundColor: UIColor.white.cgColor,
            .backgroundColor: UIColor.black.cgColor
        ]
        
        return NSAttributedString(string: string, attributes: attrs)
    }
    
    func showWarning(title: String, message: String? = nil) {
        showPopupAlert(title: "🚨 " + title, message: message)
    }
    
    func showActionSheet(title: String, message: String? = nil, actions: [UIAlertAction] = []) {
        showAlert(style: .actionSheet, title: title, message: message, actions: actions)
    }
    
    func showPopupAlert(title: String, message: String? = nil, actions: [UIAlertAction] = [], numberOfTextFields: Int = 0) {
        showAlert(style: .alert, title: title, message: message, actions: actions, numberOfTextFields: numberOfTextFields)
    }
    
    func showAlert(style: UIAlertController.Style, title: String, message: String? = nil, actions: [UIAlertAction] = [], numberOfTextFields: Int = 0) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: style)
        
        if (style == .alert) && (numberOfTextFields > 0) {
            for _ in 0..<numberOfTextFields {
                ac.addTextField()
            }
        }
        
        if actions.isEmpty {
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            for action in actions {
                ac.addAction(action)
            }
        }
        
        present(ac, animated: true)
    }


}

