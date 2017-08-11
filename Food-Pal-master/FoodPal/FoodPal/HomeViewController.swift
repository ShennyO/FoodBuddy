//
//  ViewController.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Kingfisher
import Foundation

class HomeViewController: UIViewController {
      
      @IBOutlet weak var categoryTableView: UITableView!
      
           @IBOutlet weak var addNewFoodObjectButton: UIBarButtonItem!
      var searchBarExists = false
      
      var toCustom = true
      var filteredFoodObjects = [FoodObject]()
      var cachedImages = [UIImage]()
      var filteredCachedImages = [UIImage]()
      var color: UIColor?
      let formatter = DateFormatter()
      
      var foodCells = [FoodObject]() {
            didSet {
                  categoryTableView.reloadData()
            }
      }
      
      @IBOutlet weak var categoryBarButton: UIBarButtonItem!
      let searchController = UISearchController(searchResultsController: nil)

      
      
      override func viewWillAppear(_ animated: Bool) {
            
            
            formatter.dateFormat = "YYYY-MM-dd"
            super.viewWillAppear(animated)
            self.categoryTableView.delegate = self
            self.categoryTableView.dataSource = self
            if toCustom {
                  foodCells = CoreDataHelper.retrieveFoodObjects(with: CategoryObject.current.uid!)
            } else if toCustom == false {
                  foodCells = CoreDataHelper.retrieveAllFoodObjects()
                  navigationItem.rightBarButtonItem = nil
            }
         
            
            for foodObj in foodCells {
                  
                  let expirationDateString = foodObj.expirationDate
                  
                  let expirationDate = formatter.date(from: expirationDateString!)
                  let currentDate = Date()
                  foodObj.dateDifference = expirationDate?.days(from: currentDate) 
            }
            foodCells.sort(by: {$0.dateDifference! < $1.dateDifference!})

            getImageCache()
            
      }
      
      func getImageCache() {
            cachedImages = []
            
            
                  for (_, foodObj) in foodCells.enumerated() {
                        var imageToPass: UIImage?
                        
                        if let data = foodObj.imageData as Data? {
                              imageToPass = UIImage(data: data)
                              //here I use foodObjects again, I need to check what information they contain to determine how to get the image
                        } else if foodObj.imageURL != nil {
                              let placeholderImage = UIImage(named: "foodPlaceholderImage")
                              imageToPass = placeholderImage
                              
                        } else {
                              let placeholderImage = UIImage(named: "foodPlaceholderImage")
                              imageToPass = placeholderImage
                        }
                      cachedImages.append(imageToPass!)
                  }
            
            
      }

      
      func filterTableForSearchText(searchText: String, scope: String = "All") {
            filteredFoodObjects = foodCells.filter { food in
                  return food.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
            
            filteredCachedImages = []
            
            
            for (_, foodObj) in filteredFoodObjects.enumerated() {
                  var imageToPass: UIImage?
                 
                  if let data = foodObj.imageData as Data? {
                        imageToPass = UIImage(data: data)
                        //here I use foodObjects again, I need to check what information they contain to determine how to get the image
                  } else if foodObj.imageURL != nil {
                        //kf can't set images, only imageViews
                        //let imageURL = URL(string: foodObj.imageURL!)
                        //imageViewToPass = UIImageView()
                        //imageViewToPass?.kf.setImage(with: imageURL)
                        let placeholderImage = UIImage(named: "foodPlaceholderImage")
                        imageToPass = placeholderImage
                        
                  } else {
                        let placeholderImage = UIImage(named: "foodPlaceholderImage")
                        imageToPass = placeholderImage
                  }
                  cachedImages.append(imageToPass!)
            }
            
            categoryTableView.reloadData()
      }
      
      
      
      override func viewDidLoad() {
            super.viewDidLoad()
            
            
            let buttonImage = UIImage(named: "categoryImage")!.withRenderingMode(.alwaysTemplate)
            let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            
            backButton.setBackgroundImage(buttonImage, for: .normal)
            backButton.tintColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
            backButton.addTarget(self, action: #selector(unwindCategoryTapped(_:)), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            definesPresentationContext = true
            searchController.searchBar.delegate = self
            categoryTableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.placeholder = "Search for your item"
      }
      
      override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
      }
      
      @IBAction func unwindToHomeViewController(segue: UIStoryboardSegue) {
            
      }
      @IBAction func toItemScannerButtonTapped(_ sender: Any) {
            
           /* let alertController = UIAlertController(title: nil, message: "Select how you want to add your item!", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Scan", style: .default, handler: { (_) in
                  self.performSegue(withIdentifier: "toItemScanner", sender: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Manual", style: .default, handler: { (_) in
                  self.performSegue(withIdentifier: "toManual", sender: nil)
                  
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
                  return
            }))
             */
            
            //self.present(alertController, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "toManual", sender: nil)

            
      }
      
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toItemScanner" {
                  let itemScanner = segue.destination as! ItemScannerViewController
                 // itemScanner.scanModeOn = true
                  itemScanner.editModeOn = false
                  itemScanner.manualModeOn = false
                  itemScanner.bypass = true
                  itemScanner.toScan = true
            }
            if segue.identifier == "toManual" {
                  let itemScanner = segue.destination as! ItemScannerViewController
                  itemScanner.manualModeOn = true
               //   itemScanner.scanModeOn = false
                  itemScanner.editModeOn = false
                  itemScanner.toScan = false
            }
            if segue.identifier == "toEditingItem" {
                  let itemScanner = segue.destination as! ItemScannerViewController
                  
                  let index = categoryTableView.indexPathForSelectedRow!
                  
              //    itemScanner.scanModeOn = false
                  itemScanner.editModeOn = true
                  itemScanner.manualModeOn = false
                  
                  let passBackFormatter = DateFormatter()
                  passBackFormatter.dateFormat = "YYYY-MM-dd"
                  
                  let dateToPass = passBackFormatter.date(from: foodCells[index.row].expirationDate!)!

                                   
                itemScanner.dateToPass = dateToPass
                  
                  if searchController.isActive && (searchController.searchBar.text?.characters.count)! > 0 {
                        itemScanner.foodObject = filteredFoodObjects[(index.row)]
                  } else {
                  
                  itemScanner.foodObject = foodCells[(index.row)]
                  }
                  
            }
            
      }
      
      @IBAction func unwindCategoryTapped(_ sender: Any) {
            self.performSegue(withIdentifier: "toCategory", sender: self)
      }
      
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if searchController.isActive && (searchController.searchBar.text?.characters.count)! > 0 {
                  return filteredFoodObjects.count
            } else {
                  return foodCells.count
            }
      }
      
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 192.5
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath) as! FoodCell
            
            cell.selectionStyle = .none
            
            if searchController.isActive && (searchController.searchBar.text?.characters.count)! > 0 {

                  if 10...20 ~= filteredFoodObjects[indexPath.row].dateDifference!  {
                        cell.greenBar.backgroundColor = UIColor(red:0.97, green:0.86, blue:0.13, alpha:1.0)
                  } else if filteredFoodObjects[indexPath.row].dateDifference! < 8 {
                        cell.greenBar.backgroundColor =  UIColor(red:0.78, green:0.086, blue:0.11, alpha:1.0)
                  }
                  
                  cell.foodNameLabel.text = filteredFoodObjects[indexPath.row].name
                  cell.amountNumberLabel.text = filteredFoodObjects[indexPath.row].amount
                  if filteredFoodObjects[indexPath.row].dateDifference! > 1 {
                        cell.daysLeftLabel.text = "\(filteredFoodObjects[indexPath.row].dateDifference!) days left" } else {
                        cell.daysLeftLabel.text = "\(filteredFoodObjects[indexPath.row].dateDifference!) day left"
                  }
                  
                  if filteredFoodObjects[indexPath.row].imageURL != nil {
                        let imageURL = URL(string: self.filteredFoodObjects[indexPath.row].imageURL!)
                        cell.foodImage.kf.setImage(with: imageURL)
                        
                  }
                        
                  else if let data = filteredFoodObjects[indexPath.row].imageData as Data? {
                        cell.foodImage.image = UIImage(data: data)
                  }
                  else {
                        let placeHolderImage = UIImage(named: "foodPlaceholderImage")
                        cell.foodImage.image = placeHolderImage
                  }
                  let whiteBarWidth  = view.frame.size.width - CGFloat(153)
                  
                  let greenBarMultiplier = Double(whiteBarWidth / 30)
                  cell.greenBarWidth.constant = CGFloat(greenBarMultiplier * Double(filteredFoodObjects[indexPath.row].dateDifference!))
                  
            } else {
            
                  
                  if 8...20 ~= foodCells[indexPath.row].dateDifference!   {
                        
                        cell.greenBar.backgroundColor = UIColor(red:0.97, green:0.86, blue:0.13, alpha:1.0)
                  } else if foodCells[indexPath.row].dateDifference! < 8 {
                        cell.greenBar.backgroundColor =  UIColor(red:0.78, green:0.086, blue:0.11, alpha:1.0)
                  } else if foodCells[indexPath.row].dateDifference! > 20 {
                        cell.greenBar.backgroundColor = UIColor(red:0.28, green:0.80, blue:0.33, alpha:1.0)
                  }
                  
            cell.foodNameLabel.text = foodCells[indexPath.row].name
            cell.amountNumberLabel.text = foodCells[indexPath.row].amount
                  if foodCells[indexPath.row].dateDifference! > 1 {
                        cell.daysLeftLabel.text = "\(foodCells[indexPath.row].dateDifference!) days left" } else {
                        cell.daysLeftLabel.text = "\(foodCells[indexPath.row].dateDifference!) day left"
                  }


            if foodCells[indexPath.row].imageURL != nil {
                  let imageURL = URL(string: self.foodCells[indexPath.row].imageURL!)
                  cell.foodImage.kf.setImage(with: imageURL)
                  
            }
            
            else if let data = foodCells[indexPath.row].imageData as Data? {
                  cell.foodImage.image = UIImage(data: data)
            }
            else {
                  let placeHolderImage = UIImage(named: "foodPlaceholderImage")
                  cell.foodImage.image = placeHolderImage
            }
            
                  let whiteBarWidth  = view.frame.size.width - CGFloat(153)
                 
                  let greenBarMultiplier = Double(whiteBarWidth / 30)
                  cell.greenBarWidth.constant = CGFloat(greenBarMultiplier * Double(foodCells[indexPath.row].dateDifference!))
            }
            
            
            cell.foodImage.contentMode = .scaleAspectFill
            
            cell.foodImage.layer.cornerRadius = 55
            cell.foodImage.layer.masksToBounds = false
            cell.foodImage.clipsToBounds = true
            
            cell.foodImage.layer.borderWidth = 2
            
            cell.foodLifeBar.layer.borderWidth = 2
            cell.foodLifeBar.layer.borderColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0).cgColor
            
            cell.foodLifeBar.layer.cornerRadius = 10
            
            cell.foodLifeBar.clipsToBounds = true
            
            cell.foodImage.layer.borderColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0).cgColor
            
           
            
            return cell
      }
      
      
      func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if self.searchController.isActive && (self.searchController.searchBar.text?.characters.count)! > 0 {
                  let selectedObjectToDelete = self.filteredFoodObjects[indexPath.row]
                  NotificationManager.shared.deleteNotification(foodObj: selectedObjectToDelete)
                  CoreDataHelper.delete(foodObject: selectedObjectToDelete)
                  
                  
                  self.filterTableForSearchText(searchText: self.searchController.searchBar.text!)
                  
            } else {
                  NotificationManager.shared.deleteNotification(foodObj: self.foodCells[indexPath.row])

                  CoreDataHelper.delete(foodObject: self.foodCells[indexPath.row])
                  

            }
            if self.toCustom {
                  self.foodCells = CoreDataHelper.retrieveFoodObjects(with: CategoryObject.current.uid!)
            } else {
                  self.foodCells = CoreDataHelper.retrieveAllFoodObjects()
            }
             foodCells.sort(by: {$0.dateDifference! < $1.dateDifference!})
            self.categoryTableView.reloadData()

      }
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
             self.performSegue(withIdentifier: "toEditingItem", sender: indexPath)
      }
      
      
}

extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate {
      func updateSearchResults(for searchController: UISearchController) {
            filterTableForSearchText(searchText: searchController.searchBar.text!)
      }
      
}


