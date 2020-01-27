//
//  ImageCell.swift
//  PhotoJournal
//
//  Created by Liubov Kaper  on 1/24/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import UIKit

// step1: creating custom delegation:
protocol ImageCellDelegate: AnyObject {
    //ImageCellDelegate only works with class types
    // list required funcs, initializers, variebles
    func didLongPress(_ imageCell: ImageCell) 
}

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //step2: creating custom delegation: - define optional delegate variable
    weak var delegate: ImageCellDelegate?
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(longPressAction(gesture:)))
        return gesture
    }()
    
    @objc
    private func longPressAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began { // if gesture is active
            gesture.state = .cancelled
            return
        }
        
        delegate?.didLongPress(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //layer.cornerRadius = 20.0
        //backgroundColor = .black
        addGestureRecognizer(longPressGesture)
    }
    
    public func configureCell(imageObject: ImageObject) {
        guard let image = UIImage(data: imageObject.imageData) else {
            return
        }
        imageView.image = image
        imageView.layer.cornerRadius = 80.0
        descriptionLabel.text = imageObject.imageDescription
        
    }
    
}
