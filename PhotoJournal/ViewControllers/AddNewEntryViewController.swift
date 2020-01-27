//
//  AddNewEntryViewController.swift
//  PhotoJournal
//
//  Created by Liubov Kaper  on 1/25/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import UIKit

class AddNewEntryViewController: UIViewController {
    
    @IBOutlet weak var textEntryView: UITextView!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textEntryView.delegate = self
        
        
    }
    
    
    @IBAction func accessCameraButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
        
    }
    
    
    
    @IBAction func accessPhotoLibraryButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
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
