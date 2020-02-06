//
//  AddNewEntryViewController.swift
//  PhotoJournal
//
//  Created by Liubov Kaper  on 1/25/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import UIKit
import AVFoundation

class AddNewEntryViewController: UIViewController {
    
    @IBOutlet weak var textEntryView: UITextView!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var imagePickerController = UIImagePickerController()
    
    public let dataPersistence = PersistenceHelper <ImageObject> (filename: "photojournal.plist")
    
//    private var newImage: UIImage? {
//        didSet {
//
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textEntryView.delegate = self
        imagePickerController.delegate = self
        
    }
    
    
    
    
    @IBAction func accessCameraButtonPressed(_ sender: UIBarButtonItem) {
        //imagePickerController.sourceType = .camera
//        present(imagePickerController, animated: true)
     //   UIImagePickerController.isSourceTypeAvailable(.camera)
      self.showImagesController(isCameraSelected: true)
    }
    
    private func showImagesController(isCameraSelected: Bool) {
         // source type default will be .photoLibrary
        imagePickerController.sourceType = .photoLibrary
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        present(imagePickerController, animated: true)
    }
    
    
    
    @IBAction func accessPhotoLibraryButtonPressed(_ sender: UIBarButtonItem) {
        self.showImagesController(isCameraSelected: false)
    }
    
    
    @IBAction func saveEntryButtonPressed(_ sender: UIButton) {
        guard let description = textEntryView.text else {
            print("no text entry")
            return
        }
        guard let image = imageView.image else {
            //jpegData(compressionQuality: 1.0) converts UIImage to data
            print("image is nil")
            return
        }
        // resize image because it is too large
        // the size for resizing of image
        let size = UIScreen.main.bounds.size
        
        // we will maintain the aspect ratio of the image
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        // resize image
        let resizedImage = image.resizeImge(to: rect.size.width, height: rect.size.height)
        
        guard let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // create an image object using the image selected
        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), imageDescription: textEntryView.text)
        
        do {
            try dataPersistence.create(imageObject)
        } catch {
            print("saving error: \(error)")
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension AddNewEntryViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // adding placeholder text to textView
        if textView.text == "Enter Photo Description"{
        textView.text = ""
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
        textView.text = "Enter Photo Description"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(text)
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}

extension AddNewEntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                print("image selected not found")
                return
            }
        imageView.image = image
            //selectedImage = image
            dismiss(animated: true)
        }
    
}
