//
//  CoreDataHelper.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/13/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class CoreDataHelper {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let persistentContainer = appDelegate.persistentContainer
    static let managedContext = persistentContainer.viewContext
    //static methods will go here
    
    static func saveFoodObject() {
        
        do {
            
          try managedContext.save()
                
        } catch let error as NSError{
           print(error.localizedDescription)
        }
        
        }
    
    static func saveCategoryObject() {
        
        do {
            
            try managedContext.save()
            
        } catch let error as NSError{
            print(error.localizedDescription)
        }
        
    }

    
    static func retrieveFoodObjects(with uid: String) -> [FoodObject]{
        
        let fetchRequest = NSFetchRequest<FoodObject>(entityName: "FoodObject")
        
        fetchRequest.predicate = NSPredicate(format: "uid = %@", uid)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return []
           }
    
    static func retrieveAllFoodObjects() -> [FoodObject]{
        
        let fetchRequest = NSFetchRequest<FoodObject>(entityName: "FoodObject")
        
                
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return []
    }

    
    static func retrieveCategoryObjects() -> [CategoryObject]{
        
        let fetchRequest = NSFetchRequest<CategoryObject>(entityName: "CategoryObject")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return []
    }

    
    static func delete(foodObject: FoodObject) {
        managedContext.delete(foodObject)
        saveFoodObject()
    }
    
    static func deleteCategory(categoryObject: CategoryObject) {
        managedContext.delete(categoryObject)
        saveCategoryObject()
    }

    
    }
