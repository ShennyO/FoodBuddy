//
//  CategoriesViewController.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

//the tableview cell resizes when I have different number of tableview cells


//set the tableview delegate and data source so we have access to the tableview functions and use this view controller to set the table view functions, the delegate functions are called somewhere else
class CategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
      
      @IBOutlet weak var categoriesTableView: UITableView!
      
      //collection view array is a 2d array to fill up the the collection view that we have per cell. We're going to use this array's foodObjects to create our 2d image cache array and and also use the foodObjects to check to see where to get our image from
      var collectionViewArray = [[FoodObject]]() {
            didSet {
                  //when this collectionViewArray changes, our tableview functions will reload, this should mean that the function to set the delegate and datasource of the collection view should also run but it doesn't, and the tag doesn't get reset so the images get all messed up
                  categoriesTableView.reloadData()
            }
      }
      
      var filteredCollectionViewArray = [[FoodObject]] () {
            didSet {
                  categoriesTableView.reloadData()
            }
      }
      
      //populate the AllCollectionView cell with images from cache
      var allImages = [UIImage]()
      //populate other collection View cells
      var imageCache = [[UIImage]](){
            didSet {
                  //when imageCache's array changes, it should reset the allImages
                  allImages = []
                  //loops through imageCache and resets allImages
                  for foodImageArray in imageCache {
                        allImages.append(contentsOf: foodImageArray)
                  }
            }
      }
      
      var filteredImageCache = [[UIImage]](){
            didSet {
                  //when imageCache's array changes, it should reset the allImages
            }
      }

      
      let searchController = UISearchController(searchResultsController: nil)
      
      
      //full list of all the custom category objects
      var categories = [CategoryObject](){
            didSet {
                  //Once the categories gets changed, whether I delete a category Object or add a category object, the table should reset and the indexes should also be reset, but they're not for some reason
                  categoriesTableView.reloadData()
            }
      }
      
      
      //foodObjects are used for their urls for KingFisher as well as to check the foodObject to see if they contain data, or url for the images
      var foodObjects = [FoodObject]()
      
      var filteredFoodObjects = [FoodObject]()
      var filteredNames = [String]()
      
      var filteredCategories = [CategoryObject]()
      
      
      func checkTable() {
            if categories.count == 0 {
                  self.categoriesTableView.isHidden = true
            } else {
                  self.categoriesTableView.isHidden = false
            }
            
      }
      
      //caching all my images
      //uses the collectionViewArray to get access to the foodObjects
      func getImageCache() {
            imageCache = []
            for (_, foodObjs) in collectionViewArray.enumerated() {
                  var imageArrayToPass = [UIImage]()
                  for (_, foodObj) in foodObjs.enumerated() {
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
                        imageArrayToPass.append(imageToPass!)
                  }
                  imageCache.append(imageArrayToPass)
            }
      }
      
      
      func getFilteredImageCache() {
            filteredImageCache = []
            for (_, foodObjs) in filteredCollectionViewArray.enumerated() {
                  var imageArrayToPass = [UIImage]()
                  for (_, foodObj) in foodObjs.enumerated() {
                        var imageToPass: UIImage?
                      
                        if let data = foodObj.imageData as Data? {
                              imageToPass = UIImage(data: data)
                                    } else if foodObj.imageURL != nil {
                              
                              
                              let placeholderImage = UIImage(named: "foodPlaceholderImage")
                              imageToPass = placeholderImage
                              
                        } else {
                              let placeholderImage = UIImage(named: "foodPlaceholderImage")
                              imageToPass = placeholderImage
                        }
                        imageArrayToPass.append(imageToPass!)
                  }
                  filteredImageCache.append(imageArrayToPass)
            }
      }

      
      
      func filterTableForSearchText(searchText: String, scope: String = "All") {
            
            //filtering the foodObjects I need, the foodObjects came from the collectionViewArray, collectionViewArray comes from the category objects
            
            let  foodNames = foodObjects.flatMap({ $0.name })
            
            let categoryNames = categories.flatMap( { $0.title })
            
            let bothNames = foodNames + categoryNames
            
            var foundIndex: Int?
            
            //looping through bothnames
            for index in 0 ..< bothNames.count {
                  if bothNames[index].lowercased().contains(searchText.lowercased()) {
                        //we're not using any of the index, we're basically filtering when we find something that matches
                        foundIndex = index
                  }
            }
            
            
            
            if foundIndex != nil {
                  // since we have both food names and category names, if our found index is greater than our foodnames array, we know its a category, and if not, we know its a food name
                  if foundIndex! > foodNames.count - 1 {
                        //this is a category
                        
                        //filtering through all the category array, see which categories contain the search text, and return the category that contains it
                        filteredCategories = categories.filter { category in
                              return (category.title?.lowercased().contains(searchText.lowercased()))!
                        }
      
                  } else {
                        //this is an item
                        filteredFoodObjects = foodObjects.filter { food in
                              return (food.name?.lowercased().contains(searchText.lowercased()))!
                        }
                        
                        filteredCategories = categories.filter { category in
                              category.match = false
                              //well I use foodObjects in here
                              for filteredFoodIndex in filteredFoodObjects {
                                    if category.uid == filteredFoodIndex.uid {
                                          category.match = true
                                    }
                              }
                              return category.match! == true
                        }
                        
                  }

            }  else {
                  filteredCategories = []
            }

            getFilteredCollectionViewArray()
            getFilteredImageCache()
            categoriesTableView.reloadData()
            


           /* filteredFoodObjects = foodObjects.filter { food in
                  return (food.name?.lowercased().contains(searchText.lowercased()))!
            }
            
            //get new category objects based on filtering foodobjects
            filteredCategories = categories.filter { category in
                  
                  category.match = false
                  //well I use foodObjects in here
                  for filteredFoodIndex in filteredFoodObjects {
                        if category.uid == filteredFoodIndex.uid {
                              category.match = true
                        }
                  }
                  return category.match! == true
            } */
            
            //getting a filteredCollectionArray, problem, the images for filtered are not working ([[FoodObjects]]

            
            
      }
      
      //filling up my collectionView 2-D array with array of foodObjects
      func getCollectionViewArray() {
            collectionViewArray = []
            for (_, categoryObj ) in categories.enumerated() {
                  let Objects =  CoreDataHelper.retrieveFoodObjects(with: categoryObj.uid!)
                  collectionViewArray.append(Objects)
            }
      }
      
      //getting the 2d food objects array based on what categories we have
      func getFilteredCollectionViewArray() {
            filteredCollectionViewArray = []
            for (_, categoryObj ) in filteredCategories.enumerated() {
                  let Objects =  CoreDataHelper.retrieveFoodObjects(with: categoryObj.uid!)
                  filteredCollectionViewArray.append(Objects)
            }
      }
      
      
      override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            
            
            self.navigationController?.navigationBar.tintColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
            //retrieve all the categories from CoreData
            self.categories = CoreDataHelper.retrieveCategoryObjects()
            
            
            self.categories.sort(by: {$0.time!.timeIntervalSinceNow > $1.time!.timeIntervalSinceNow})
            
            //going through each category object and retrieving the foodObjects that match with the uid, then appending that array of FoodObjects to the 2D array CollectionViewArray
            
            //if i deleted the foodObject, this collection View Array shouldn't even have the food Object
            getCollectionViewArray()
            //looping through the collectionViewArray to get the images
            //I use foodObjects here to check how to get the image
            getImageCache()
            // A list of all the foodObjects ( for kingfisher actually )
            getAllFoodObjects()
            
            categoriesTableView.reloadData()
            
      }
      
      func getAllFoodObjects() {
            self.foodObjects = []
            for (index, item) in collectionViewArray.enumerated() {
                  self.foodObjects.append(contentsOf: item)
            }
      }
      
      override func viewDidLoad() {
            categoriesTableView.delegate = self
            categoriesTableView.dataSource = self
            //self.categories = CoreDataHelper.retrieveCategoryObjects()
            
            
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            definesPresentationContext = true
            searchController.searchBar.delegate = self
            
            categoriesTableView.tableHeaderView = searchController.searchBar
            
            searchController.searchBar.placeholder = "Search for items or categories"
            
            
            navigationController?.navigationBar.isTranslucent = false
            let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
            UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
            
            
      }
      
      
      
      func numberOfSections(in tableView: UITableView) -> Int {
            
            return 2
      }
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if section == 0 {
                  if searchController.isActive {
                        return 0
                  } else {
                        return 1
                  }
                  
            } else {
                  
                  if searchController.isActive && (searchController.searchBar.text?.characters.count)! > 0 {
                        return filteredCategories.count
                  }
                  
                  return categories.count
            }
      }
      
      
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = categoriesTableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            if indexPath.section == 0 {
                  
                  if searchController.isActive {
                        cell.isHidden = true
                  } else {
                        if categories.count == 0 {
                              cell.categoryLabel.text = "All Categories - Add a new category to start!"
                        } else {
                        cell.categoryLabel.text = "All Categories"
                        }
                  }
                  
            } else {
                  
                  let categoryObj : CategoryObject
                  
                  if searchController.isActive && (searchController.searchBar.text?.characters.count)! > 0 {
                        categoryObj = filteredCategories[indexPath.row]
                  } else {
                        categoryObj = categories[indexPath.row]
                        
                  }
                  cell.categoryLabel.text = categoryObj.title
            }
            
            cell.previewCollectionView.reloadData()
            
            
            return cell
      }
      
      func tableView(_ tableView: UITableView,
                     willDisplay cell: UITableViewCell,
                     forRowAt indexPath: IndexPath) {
            
            guard let tableViewCell = cell as? CategoryCell else { return }
            
            //this sets the datasource and delegate for each collection view
            
            if indexPath.section == 1 {
                  
                  tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
                  
            } else {
                  tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 1000)
            }
            
            //
            if tableViewCell.previewCollectionView.numberOfItems(inSection: 0) > 5  {
                  (tableViewCell.dotLabel.text = "..." )
            } else {
                  (tableViewCell.dotLabel.text = "")
            }
      }
      
      
      
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            
            //this is the height of the cell .23x the height of the whole view
            
            return 130
            
      }
      
      func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
                  
                  let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
                        //TODO: edit the row at indexPath here
                        if indexPath.section == 1 {
                              let currentCategoryObj = self.categories[indexPath.row]
                              self.performSegue(withIdentifier: "editCategory", sender: indexPath)
                        }
                        
                        
                  }
                  editAction.backgroundColor = .blue
                  
                  let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
                        if indexPath.section == 1 {
                              let currentCategoryFoodObjects = CoreDataHelper.retrieveFoodObjects(with: self.categories[indexPath.row].uid!)
                              
                              for foodObject in currentCategoryFoodObjects {
                                    NotificationManager.shared.deleteNotification(foodObj: foodObject)
                                    CoreDataHelper.delete(foodObject: foodObject)
                                    
                              }
                              
                              
                              CoreDataHelper.deleteCategory(categoryObject: self.categories[indexPath.row])
                              
                              
                              self.categories = CoreDataHelper.retrieveCategoryObjects()
                              
                              self.categories.sort(by: {$0.time!.timeIntervalSinceNow > $1.time!.timeIntervalSinceNow})
                              
                              self.getCollectionViewArray()
                              //looping through the collectionViewArray to get the images
                              //I use foodObjects here to check how to get the image
                              self.getImageCache()
                              // A list of all the foodObjects ( for kingfisher actually )
                              self.getAllFoodObjects()
                              
                              self.categoriesTableView.reloadData()
                              
                        }
                  }
                  deleteAction.backgroundColor = .red
                  
                  return [editAction,deleteAction]
            
            
      }
      
      func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            if indexPath.section > 0 {
                  return true
            }
            
            return false
      }
      
      
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if indexPath.section == 0 {
                  self.performSegue(withIdentifier: "toHomeFoodList", sender: self)
            } else if indexPath.section == 1 {
                  self.performSegue(withIdentifier: "toCustomFoodList", sender: self)
            }
            
      }
      
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            
            if segue.identifier == "toCustomFoodList"{
                  let foodVC = segue.destination as! HomeViewController
                  let indexPathRow = categoriesTableView.indexPathForSelectedRow?.row
                  let categoryObj: CategoryObject
                  
                  if searchController.isActive && searchController.searchBar.text != "" {
                        
                        categoryObj = filteredCategories[indexPathRow!]
                        
                  } else {
                        categoryObj = categories[indexPathRow!]
                  }
                  
                  
                  foodVC.toCustom = true
                  CategoryObject.setCurrent(categoryObj)
            } else if segue.identifier == "toHomeFoodList" {
                  let foodVC = segue.destination as! HomeViewController
                  
                  foodVC.toCustom = false
            } else if segue.identifier == "editCategory" {
                  let editCategoryVC = segue.destination as! NewCategoryViewController
                  
                  let indexPath: NSIndexPath
                  if sender is UITableViewCell {
                        indexPath = categoriesTableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
                  } else {
                        indexPath = sender as! NSIndexPath
                  }
                  editCategoryVC.categoryObj = categories[indexPath.row]
                  
            }
            
            
      }
      
      @IBAction func unwindToCategory(segue: UIStoryboardSegue) {
            
      }
      
}

extension CategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
      
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            var maxnum = 0
            let index = categoriesTableView.indexPathForSelectedRow?.row
            if collectionView.tag == 1000 {
                  
                  maxnum = foodObjects.count
                  
                  return maxnum
                  
            } else {
                  
                  if searchController.isActive && (searchController.searchBar.text?.characters.count)! > 0 {
                        
                        maxnum = filteredCollectionViewArray[collectionView.tag].count
                        
                  } else {
             maxnum = collectionViewArray[collectionView.tag].count
                  }
            }
            return maxnum
      }
      
      
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell
            
            //getting the height and width of each cell in the collection view
            
            return cell
      }
      
      //these are the collection view cells
      
      func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let foodCell = cell as! collectionCell
            
            foodCell .frame = CGRect(x: (CGFloat(indexPath.row) * collectionView.frame.height), y: 0.0, width: collectionView.frame.height, height: collectionView.frame.height)
            
            //the collectionView.tag represents the row of collectionView, the indexpath.item represents the item of the collectionView. But I still need to differentiate the home view
            
            if collectionView.tag == 1000 {
                  //in here I have to display all of the images from the cache
                  
                  
                  
                  if foodObjects[indexPath.item].imageURL != nil {
                        let imageURL = URL(string: foodObjects[indexPath.item].imageURL!)
                        
                        foodCell.collectionCellImage.kf.setImage(with: imageURL)
                        
                  }
                        
                        
                  else if let data = foodObjects[indexPath.item].imageData as Data? {
                        foodCell.collectionCellImage.image = allImages[indexPath.item]
                  }
                  else {
                        let placeHolderImage = UIImage(named: "foodPlaceholderImage")
                        foodCell.collectionCellImage.image = placeHolderImage
                  }
                  
                  
                  
                  foodCell.collectionCellImage.layer.borderWidth = 2
                  foodCell.collectionCellImage.layer.cornerRadius = 24
                  foodCell.collectionCellImage.clipsToBounds = true
                  foodCell.collectionCellImage.layer.borderColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0).cgColor
                  
                  return
                  
            } else {
                  
                  if searchController.isActive && (searchController.searchBar.text?.characters.count)! > 0 {
                        
                        if filteredCollectionViewArray[collectionView.tag][indexPath.item].imageURL != nil {
                              let imageURL = URL(string: filteredCollectionViewArray[collectionView.tag][indexPath.item].imageURL!)
                              foodCell.collectionCellImage.kf.setImage(with: imageURL)
                              
                        }
                              
                        else if let data = filteredCollectionViewArray[collectionView.tag][indexPath.item].imageData as Data? {
                              foodCell.collectionCellImage.image = filteredImageCache[collectionView.tag][indexPath.item]
                        }
                        else {
                              let placeHolderImage = UIImage(named: "foodPlaceholderImage")
                              foodCell.collectionCellImage.image = placeHolderImage
                        }
                        
                  } else {
                        
                        if collectionViewArray[collectionView.tag][indexPath.item].imageURL != nil {
                              let imageURL = URL(string: collectionViewArray[collectionView.tag][indexPath.item].imageURL!)
                              foodCell.collectionCellImage.kf.setImage(with: imageURL)
                              
                        }
                              
                        else if let data = collectionViewArray[collectionView.tag][indexPath.item].imageData as Data? {
                              foodCell.collectionCellImage.image = imageCache[collectionView.tag][indexPath.item]
                        }
                        else {
                              let placeHolderImage = UIImage(named: "foodPlaceholderImage")
                              foodCell.collectionCellImage.image = placeHolderImage
                        }
                        
                  }
            }
            
            foodCell.collectionCellImage.layer.borderWidth = 2
            foodCell.collectionCellImage.layer.cornerRadius = 24
            foodCell.collectionCellImage.clipsToBounds = true
            
            foodCell.collectionCellImage.layer.borderColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0).cgColor
            
            
      }
      
}

extension CategoriesViewController: UISearchResultsUpdating, UISearchBarDelegate, UITextFieldDelegate {
      func updateSearchResults(for searchController: UISearchController) {
            filterTableForSearchText(searchText: searchController.searchBar.text!)
      }
      
      
      
      
      
}
