//
//  CategoryCell.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit


class CategoryCell: UITableViewCell {
      
      //var foodObjects = [FoodObject](){
         //   didSet {
            //      previewCollectionView.reloadData()
            //}
      //}
      
     
      
      @IBOutlet weak var previewCollectionView: UICollectionView!
      
      @IBOutlet weak var categoryLabel: UILabel!
      
      @IBOutlet weak var dotLabel: UILabel!
      
      override func awakeFromNib() {
            super.awakeFromNib()
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            
            layout.minimumInteritemSpacing = 5
            
          //  self.previewCollectionView.delegate = self
           // self.previewCollectionView.dataSource = self
            
      }
      
      //this function isn't updating when i create a new category object, or when i delete a category object 
      func setCollectionViewDataSourceDelegate
            <D: UICollectionViewDataSource & UICollectionViewDelegate>
            (dataSourceDelegate: D, forRow row: Int) {
            
            previewCollectionView.delegate = dataSourceDelegate
            previewCollectionView.dataSource = dataSourceDelegate
            previewCollectionView.tag = row
            previewCollectionView.reloadData()
      }
}
