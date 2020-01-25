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
