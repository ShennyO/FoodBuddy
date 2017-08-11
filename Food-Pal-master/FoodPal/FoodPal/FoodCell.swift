//
//  CategoryCell.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

class FoodCell: UITableViewCell {
    
    @IBOutlet weak var foodImage: UIImageView!
    
      
    @IBOutlet weak var foodLifeBar: UIView!
      @IBOutlet weak var greenBar: UIView!
    
    @IBOutlet weak var foodNameLabel: UILabel!
    
      @IBOutlet weak var greenBarWidth: NSLayoutConstraint!
      
      @IBOutlet weak var daysLeftLabel: UILabel!
        
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var amountNumberLabel: UILabel!
}
