//
//  FoodObject.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/14/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class FoodObject: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var expirationDate: String?
    @NSManaged var amount: String?
    @NSManaged var imageURL: String?
    @NSManaged var uid: String?
    @NSManaged var multiplier: String?
    @NSManaged var imageData: NSData?
  
    
    var dateDifference: Int?
    
    convenience init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer = appDelegate.persistentContainer
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FoodObject", in: managedContext)
        self.init(entity: entity!, insertInto: managedContext)
    }


}
