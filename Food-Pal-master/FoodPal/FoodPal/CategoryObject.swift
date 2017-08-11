//
//  CategoryObject.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import CoreData



class CategoryObject: NSManagedObject {
    
    private static var _current : CategoryObject?
    
    static var current: CategoryObject {
        guard let currentCategory = _current else {
            fatalError("Category doesn't exist")
        }
        return currentCategory
    }
    
    static func setCurrent(_ category : CategoryObject) {
        _current = category
    }
    
    @NSManaged var title: String?
    @NSManaged var uid: String?
    @NSManaged var time: Date?
    var match: Bool? 
    
    

    
    convenience init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer = appDelegate.persistentContainer
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CategoryObject", in: managedContext)
        self.init(entity: entity!, insertInto: managedContext)
    }
}
