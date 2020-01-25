//
//  PersistanceHandler.swift
//  PhotoJournal
//
//  Created by Liubov Kaper  on 1/22/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import Foundation

enum DataPersistenceError: Error { // conforming to the Error protocol
  case savingError(Error) // associative value
  case fileDoesNotExist(String)
  case noData
  case decodingError(Error)
  case deletingError(Error)
}

typealias Writeable = Codable & Equatable

class PersistenceHelper <T: Writeable> {
  
  // CRUD - create, read, update, delete
  
  // array of events
    private var items: [T]
  
  private var filename: String
  
  init(filename: String) {
    self.filename = filename
    self.items = []
  }
  
  private func saveItemsToDocumentsDirectory() throws {
    // step 1.
     // get url path to the file that the Event will be saved to
     //let url = FileManager.getPath(with: filename, for: .documentsDirectory)
    
    // events array will be object being converted to Data
    // we will use the Data object and write (save) it to documents directory
    do {
      // step 3.
      // convert (serialize) the events array to Data
      let data = try PropertyListEncoder().encode(items)
        let url = FileManager.getPath(with: filename, for: .documentsDirectory)
      // step 4.
      // writes, saves, persist the data to the documents directory
      try data.write(to: url, options: .atomic)
    } catch {
      // step 5.
      throw DataPersistenceError.savingError(error)
    }
  }
  
 // for re-ordering, and keeping date in sync
  public func synchronize(_ items: [T]) {
    self.items = items
    try? saveItemsToDocumentsDirectory()
  
  }
  
  // DRY - don't repeat yourself
  
  // create - save item to documents directory
  public func create(_ item: T) throws {
    _ = try? loadItems()
    // step 2.
    // append new event to the events array
    items.append(item)
    
    do {
      try saveItemsToDocumentsDirectory()
    } catch {
        throw DataPersistenceError.savingError(error)
    }
  }

  // read - load (retrieve) items from documents directory
  public func loadItems() throws -> [T] {
    // we need access to the filename URL that we are reading from
    let path = FileManager.getPath(with: filename, for: .documentsDirectory).path
    
    // check if file exist
    // to convert URL to String we use .path on the URL
    if FileManager.default.fileExists(atPath: path) {
      if let data = FileManager.default.contents(atPath: path) {
        do {
          items = try PropertyListDecoder().decode([T].self, from: data)
        } catch {
          throw DataPersistenceError.decodingError(error)
        }
      } else {
        throw DataPersistenceError.noData
      }
    }
    else {
      throw DataPersistenceError.fileDoesNotExist(filename)
    }
    return items
  }
    
    // Update
    
    @discardableResult
    public func update(_ oldItem: T, with newItem: T) -> Bool {
        if let index = items.firstIndex(of: oldItem) { // is oldItem == currentitem searched
           let result = update(newItem, at: index)
            return result
        }
        return false
    }
    
    @discardableResult// silences the warning if the return value is not used by the caller
    public func update(_ item: T, at index: Int) -> Bool {
        items[index] = item
        // save items to documents directory
        do {
            try saveItemsToDocumentsDirectory()
            return true
        } catch {
           return false
        }
    }
  
  // delete - remove item from documents directory
  public func delete(event index: Int) throws {
    // remove the item from the events array
    items.remove(at: index)
    
    // save our events array to the documents directory
    do {
      try saveItemsToDocumentsDirectory()
    } catch {
      throw DataPersistenceError.deletingError(error)
    }
  }
}
