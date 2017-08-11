//
//  NewCategoryViewController.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit


class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var newCategoryAddButton: UIButton!
    
    @IBOutlet weak var newCategoryTextField: UITextField!
    
      var categoryObj: CategoryObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newCategoryTextField.delegate = self
        
       newCategoryAddButton.layer.cornerRadius = 15
       newCategoryAddButton.layer.borderWidth = 1
       newCategoryAddButton.layer.borderColor = UIColor.white.cgColor
        newCategoryTextField.becomeFirstResponder()
     
      
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewCategoryViewController.dismissKeyboard))
      
      view.addGestureRecognizer(tap)
      
      
      if newCategoryTextField.text == "" {
            newCategoryAddButton.isEnabled = false
            newCategoryAddButton.backgroundColor = UIColor.gray
      } else {
            newCategoryAddButton.isEnabled = true
            newCategoryAddButton.backgroundColor = UIColor(red:0.78, green:0.086, blue:0.11, alpha:1.0)
      }

      
    }
      
            
    
    
      func dismissKeyboard() {
            view.endEditing(true)
           /* if newCategoryTextField.text == "" {
                  newCategoryAddButton.isEnabled = false
                  newCategoryAddButton.backgroundColor = UIColor.gray
            } else {
                  newCategoryAddButton.isEnabled = true
                  newCategoryAddButton.backgroundColor = UIColor(red:0.00, green:0.50, blue:1.00, alpha:1.0)
            } */

      }
      
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 18
        let currentString: NSString = newCategoryTextField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
      
      if min(maxLength, newString.length) > 0 {
            newCategoryAddButton.isEnabled = true
            newCategoryAddButton.backgroundColor = UIColor(red:0.78, green:0.086, blue:0.11, alpha:1.0)
      } else {
            newCategoryAddButton.isEnabled = false
            newCategoryAddButton.backgroundColor = UIColor.gray
            
      }

      
        return newString.length <= maxLength
    }
    
    
    
    @IBAction func newCategoryAddButtonTapped(_ sender: Any) {
      
      if categoryObj == nil {
         categoryObj = CategoryObject()
         categoryObj?.uid = UUID().uuidString
         categoryObj?.time = Date()
      }
        categoryObj?.title = newCategoryTextField.text
      
        CoreDataHelper.saveCategoryObject()
        self.performSegue(withIdentifier: "newCategoryToCategory", sender: self)
        
    }
    
    
    
    
}
