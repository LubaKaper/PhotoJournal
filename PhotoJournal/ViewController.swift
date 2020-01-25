//
//  ViewController.swift
//  PhotoJournal
//
//  Created by Liubov Kaper  on 1/22/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var imageObjects = [ImageObject]()
    
    private var imagePickerController = UIImagePickerController()
    
    public let dataPersistence = PersistenceHelper <ImageObject> (filename: "photojournal.plist")
    
    private var selectedImage: UIImage? {
        didSet {
            // gets called when new image is selected
            appendNewPhotoToCollection()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // set UIImagePickerCintri=oller delegate as this viewcontroller
        imagePickerController.delegate = self
        loadImageObjects()
    }
    
    private func loadImageObjects() {
        do {
            imageObjects = try dataPersistence.loadItems()
        } catch {
            print("loading object error: \(error)")
        }
    }
    
    private func appendNewPhotoToCollection() {
        guard let image = selectedImage else {
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
        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), imageDescription: "...")
        
        //insert new image object into image objects
        imageObjects.insert(imageObject, at: 0)
        
        // create indexPath for insertion into collection
        let indexPath = IndexPath(row: 0, section: 0)
        
        //insert new cell into coleection view
        collectionView.insertItems(at: [indexPath])
        
        // persist imageObject to documents directory
        do {
            try dataPersistence.create(imageObject)
        } catch {
            print("saving error: \(error)")
        }
    }
    
   
    @IBAction func addPhotoButtonPressed(_ sender: UIBarButtonItem) {
        // present an action sheet to the user
        // actions: camera, photo library, cancel
        // preferredStyle: .alert(will show actions in the middle of the screen)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            [weak self] alertAction in self?.showImagesController(isCameraSelected: true)
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { [weak self] alertAction in self?.showImagesController(isCameraSelected: false)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        }
    
    private func showImagesController(isCameraSelected: Bool) {
         // source type default will be .photoLibrary
        imagePickerController.sourceType = .photoLibrary
        if isCameraSelected {
            imagePickerController.sourceType = .photoLibrary
        }
        present(imagePickerController, animated: true)
    }
    
}

extension UIImage {
    func resizeImge(to width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return imageObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // step5: creating custom delegation: - must have an instance of object B
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {
            fatalError("could not downcast to ImageCell")
        }
        let imageObject = imageObjects[indexPath.row]
        cell.configureCell(imageObject: imageObject)
        // step5: creating custom delegation: - set delegate object
        cell.delegate = self
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // width of the device
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        // cell width is 80% of device width
        let itemWidth: CGFloat = maxWidth * 0.80
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // we need to access the UIImagePickerController.infokey.original image key to get the UIImage that was selected
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selected not found")
            return
        }
        selectedImage = image
        dismiss(animated: true)
    }
}

// step6: creating custom delegation: - conform to delegate
extension ViewController: ImageCellDelegate {
    
    func didLongPress(_ imageCell: ImageCell) {
        
        guard let indexPath = collectionView.indexPath(for: imageCell) else {
            return
        }
        // present an action sheet
        // actions: delete, cancel, edit
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] alertAction in self?.deleteImageObject(indexPath: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        //TODO:- add segue to detailVC
        let editAction = UIAlertAction(title: "Edit", style: .destructive)
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func deleteImageObject(indexPath: IndexPath) {
        // delete image from document directory
        do {
            try dataPersistence.delete(event: indexPath.row)
            imageObjects.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        } catch {
            print("error deleting this item: \(error)")
        }
        
    }
    
}
