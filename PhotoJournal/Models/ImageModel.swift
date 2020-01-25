//
//  ImageModel.swift
//  PhotoJournal
//
//  Created by Liubov Kaper  on 1/22/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import Foundation

struct ImageObject: Codable & Equatable{
  let imageData: Data
  let date: Date
    // creates unique id for the object
  let identifier = UUID().uuidString
    let imageDescription: String
}
