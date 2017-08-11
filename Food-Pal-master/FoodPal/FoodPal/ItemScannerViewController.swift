//
//  ItemScannerViewController.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ItemScannerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
      
      //MARK: - IBOutlets
      @IBOutlet weak var addButton: UIButton!
      
      @IBOutlet weak var barcodeImage: UIImageView!
      
      @IBOutlet weak var itemScannerTitleLabel: UILabel!
      
      @IBOutlet weak var toTakePicButton: UIButton!
      
      @IBOutlet weak var amountScroller: UIPickerView!
      @IBOutlet weak var itemNameTextField: UITextField!
      
      @IBOutlet weak var expirationDatePicker: UIDatePicker!
      
      //MARK: -  Properties
      
      // variables needed for logic, and passing objects to other classes
      //selected imageURL should be passed from the Camera, or from the homeView on the edit
      var selectedItemImageURL: String?
      //var scanModeOn = true
      var editModeOn = true
      var manualModeOn = true
      var bypass = true
      var passable = true
      let photoHelper = PhotoHelper()
      var imageData: NSData?
      var customImage: UIImage?
      var multiplierToPass: String?
      var toScan = true
      var dateToPass: Date?
      
      //if product array is changed, then enable the button, and make it green, but somehow it's blue?
      var product: Product? = nil {
            didSet {
                  addButton.isEnabled = true
                  addButton.backgroundColor = UIColor(red:0.00, green:0.50, blue:1.00, alpha:1.0)
            }
      }
      
      //this variable is so I can pass this object to another class
      var foodObject: FoodObject?
      //default value for my amountPicker
      var amount: String? = "1"
      
      //amount for my picker
      var amountOfItemsScroller : [String] = ["1","2","3","4","5","6","7","8","9", "10", "11", "12", "13", "14", "15"]
      
      
      
      
      //MARK: - Life Cycle Functions
      
      override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            
      }
      
      override func viewWillAppear(_ animated: Bool) {
            
            super.viewWillAppear(animated)
            
           /* if scanModeOn && editModeOn == false && manualModeOn == false {
                  configureScanMode()
            } */  if manualModeOn && editModeOn == false {
                  configureManualMode()
            } else if editModeOn && manualModeOn == false {
                  configureEditMode()
            }
            
            if itemNameTextField.text == "" {
                  addButton.isEnabled = false
                  addButton.backgroundColor = UIColor.gray
            } else {
                  
                  addButton.isEnabled = true
                  addButton.backgroundColor = UIColor(red:0.78, green:0.086, blue:0.11, alpha:1.0)
            }
            
      }
      
      override func viewDidLoad() {
            
            super.viewDidLoad()
            
            if dateToPass != nil {
                  expirationDatePicker.date = dateToPass!
            }

            
          /*  if scanModeOn {
                  barcodeImage.image = UIImage(named: "barcode")
            }  */ if manualModeOn {
                  barcodeImage.image = UIImage(named: "addCameraImage")
            }
          //  barcodeImage.layer.cornerRadius = 25
            
            //barcodeImage.layer.masksToBounds = false
            barcodeImage.clipsToBounds = true
            
           /* if scanModeOn {
                  addButton.isEnabled = false
                  addButton.backgroundColor = UIColor.gray
            } */
            
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ItemScannerViewController.dismissKeyboard))
            
            view.addGestureRecognizer(tap)
            
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.amountScroller.dataSource = self
            self.amountScroller.delegate = self
            //this code makes no changes to my button
            print(addButton.bounds.height)
            addButton.layer.cornerRadius = addButton.frame.height * 0.375
            print(addButton.frame.height * 0.375)
            addButton.layer.borderWidth = 1
            addButton.layer.borderColor = UIColor.white.cgColor
            

            itemNameTextField.delegate = self
            
           
            
            
      }
      
      //MARK: - PICKERVIEW STUFF
      
      func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
      }
      
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            
            
            return amountOfItemsScroller.count
            
      }
      
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return amountOfItemsScroller[row]
      }
      
      func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            amount = amountOfItemsScroller[row]
            
      }
      
      func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.black
            pickerLabel.text = amountOfItemsScroller[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: "Futura", size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.center
            return pickerLabel
      }
      
      
      
      
      //MARK: - Mode Configurations
      func configureScanMode() {
            self.toTakePicButton.isEnabled = true
            //self.toCameraButton.isEnabled = true
            //self.toCameraButton.isHidden = false
            if bypass {
                  self.bypass = false
                  self.performSegue(withIdentifier: "toBarcodeCamera", sender: self)
            }
            //if a picture URL exists, set the image to that
            if selectedItemImageURL != nil {
                  let imageURL = URL(string: selectedItemImageURL!)
                  barcodeImage.kf.setImage(with: imageURL)
            }
            //if there's a name, set the name
            //this is for if we go back from the Camera View(this way, we're still in scanning mode
            if product != nil {
                  itemNameTextField.text = product?.title
                  
            }
            
      }
      
      func configureEditMode() {
            //self.toCameraButton.isEnabled = false
            self.toTakePicButton.isEnabled = false
            
            itemScannerTitleLabel.text = ""
            let placeHolderImage = UIImage(named: "foodPlaceholderImage")
            //if a foodObject exists, set the IBOutlets according to the foodObject's values
            
            if foodObject != nil {
                  foodObject?.amount = amount
                  self.navigationItem.title = "Editing Item"
                  self.addButton.setTitle("Save", for: .normal)
                  itemNameTextField.text = foodObject?.name
                  //this is for both manual Objects, and scanned objects being passed through
                  //we need the check against the product above, because this only checks against the edit stuff,
                  //in the initial manual, there's no foodObject to check against, it's nil
                  if foodObject?.imageURL != nil {
                        let imageURL = URL(string: (foodObject?.imageURL)!)
                        barcodeImage.kf.setImage(with: imageURL)
                  } else if foodObject?.imageData != nil {
                        barcodeImage.image = UIImage(data: (foodObject?.imageData)! as Data)
                  } else {
                        barcodeImage.image = placeHolderImage
                  }
            }
            
            
      }
      
      func configureManualMode() {
            //self.toCameraButton.isEnabled = false
            //self.toCameraButton.isHidden = true
            self.toTakePicButton.isEnabled = true
            
            // let takePicImage = UIImage(named: "addCameraImage")
            
            
            
            photoHelper.completionHandler = { image in
                  guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                        
                        return
                  }
                  
                  self.imageData = imageData as NSData
                  
                  DispatchQueue.main.async {
                        self.barcodeImage.image = image
                  }
                  
                  
                  
                  
            }
            
            
            if selectedItemImageURL != nil {
                  let imageURL = URL(string: selectedItemImageURL!)
                  barcodeImage.kf.setImage(with: imageURL)
            }
            
            itemScannerTitleLabel.text = "Take a picture!"
            
            
      }
      
      
      //MARK: - Actions
      
      @IBAction func toTakePicButtonTapped(_ sender: Any) {
            
            if toScan == false {
            photoHelper.presentActionSheet(from: self)
            } else {
                  self.performSegue(withIdentifier: "toBarcodeCamera", sender: self)
            }
            
      }
      
      @IBAction func addFoodButtonTapped(_ sender: Any) {
            if foodObject == nil {
                  foodObject = FoodObject()
            }
            
            checkExpiration(date: expirationDatePicker.date)
            //getExpirationDate(foodObj: foodObject!)
            
            
            if self.passable {
                  self.performSegue(withIdentifier: "toHomeView", sender: self)
            } else {
                  let alertController = UIAlertController(title: nil, message: "Invalid Expiration Date", preferredStyle: .alert)
                  alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                  }))
                  self.present(alertController, animated: true, completion: nil)
            }
      }
      
      
      @IBAction func toCamerButtonTapped(_ sender: Any) {
            self.performSegue(withIdentifier: "toBarcodeCamera", sender: self)
      }
      
      
      //MARK: - Segue Configurations
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "toHomeView" {
                  
                  
              /*    if scanModeOn {
                        
                        foodObject?.amount = amount
                        
                        foodObject?.name = itemNameTextField.text
                        
                        foodObject?.imageURL = product?.imageURL
                        
                        
                        
                        getExpirationDate(foodObj: foodObject!)
                        
                        getDaysLeft(foodObj: foodObject!)
                        
                        if foodObject?.uid == nil {
                              foodObject?.uid = CategoryObject.current.uid
                        }
                        
                  }  */  if manualModeOn || editModeOn {
                        
                        foodObject?.amount = amount
                        
                        foodObject?.name = itemNameTextField.text
                        
                        if foodObject?.uid == nil {
                              foodObject?.uid = CategoryObject.current.uid
                        }
                        if selectedItemImageURL != nil {
                              foodObject?.imageURL = selectedItemImageURL
                        }
                        if foodObject?.imageData == nil {
                              foodObject?.imageData = self.imageData
                        }
                        
                        getExpirationDate(foodObj: foodObject!)
                        getDaysLeft(foodObj: foodObject!)
                        
                  }
                  
                  
                  CoreDataHelper.saveFoodObject()
                  
                  print(foodObject)
                  
                  NotificationManager.shared.scheduleDaysLeft(daysLeft: (foodObject?.dateDifference)!, repeats: false, food: foodObject!)
                  
                  
            }
      }
      
      
      @IBAction func unwindToItemScanner(segue: UIStoryboardSegue) {
            
      }
      
      
      //MARK: - Helpers
      
      func getExpirationDate(foodObj: FoodObject) {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            let dateString = formatter.string(from: expirationDatePicker.date)
            foodObj.expirationDate = dateString
            
      }
      
      func getDaysLeft(foodObj: FoodObject) {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            
            let expirationDate = formatter.date(from: foodObj.expirationDate!)
            let current = Date()
            
            foodObj.dateDifference = expirationDate?.days(from: current)

      }
      
      
      func checkExpiration(date: Date) {
            
            let today = Date()
            
            if date.days(from: today) > 0 {
                  self.passable = true
            } else {
                  self.passable = false
            }
      }
      
      
      func dismissKeyboard() {
            view.endEditing(true)
            
         /*   if scanModeOn == false {
                  if itemNameTextField.text == "" {
                        addButton.isEnabled = false
                        addButton.backgroundColor = UIColor.gray
                  }  */ if manualModeOn {
                        addButton.isEnabled = true
                        addButton.backgroundColor = UIColor(red:0.78, green:0.086, blue:0.11, alpha:1.0)
                  }
                  
            }
            
      }
      


extension ItemScannerViewController: UITextFieldDelegate {
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return true
      }
}
