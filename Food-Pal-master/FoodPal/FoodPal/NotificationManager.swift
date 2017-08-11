//
//  NotificationManager.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 8/1/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications

class NotificationManager: NSObject {
      
      static let shared: NotificationManager = {
            return NotificationManager()
      }()
      
      var isAuthorized = false
      
      func requestAuthorization(){
            
            let options: UNAuthorizationOptions = [.alert, .badge, .sound ]
            
            UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted: Bool, error: Error?) in
                  
                  if granted {
                        self.isAuthorized = true
                  } else {
                        self.isAuthorized = false
                  }
                  
            })
            
            UNUserNotificationCenter.current().delegate = self
      }
      
      func deleteNotification(foodObj: FoodObject){
            
            let foodName = foodObj.name!
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [foodName])
      }
      
      
      
      func scheduleDaysLeft(daysLeft: Int, repeats: Bool, food: FoodObject) {
            
            //this is the content of my notification
            let content = UNMutableNotificationContent()
            content.title = "\(food.name!) is almost expired!"
            if daysLeft < 3 {
                  content.body = "There's 1 day left!"
            } else {
                  content.body = "There's 3 days left!"
            }
            
            //Next up is the trigger
            let oneDay = daysLeft - 1
            
            let threeDays = daysLeft - 3
            
            let oneDayLeftInSeconds = Double(oneDay * 86400)
            
            let threeDaysLeftInSeconds =  Double(threeDays * 86400)
            
            let foodName = food.name!
            
            
            if daysLeft > 3 {
               
                  let threeDaysTrigger = UNTimeIntervalNotificationTrigger(timeInterval: threeDaysLeftInSeconds, repeats: repeats)
                  
                  let threeDaysRequest = UNNotificationRequest(identifier: foodName, content: content, trigger: threeDaysTrigger)
      
                  
                  
                  
                  //now we add the request

          
                  
                  UNUserNotificationCenter.current().add(threeDaysRequest , withCompletionHandler: { (error: Error?) in
                        
                        if error == nil {
                              print("Notification Activated, will be notified when there's 3 days left")
                              
                        }
                        
                  })

                

            }
            
            if daysLeft > 1 {
            
            let oneDayTrigger = UNTimeIntervalNotificationTrigger(timeInterval: oneDayLeftInSeconds, repeats: repeats)

            
                      //Now we have to create the request
            let oneDayrequest = UNNotificationRequest(identifier: foodName, content: content, trigger: oneDayTrigger)
                  
                  
           
            
            //now we add the request
            
           
            UNUserNotificationCenter.current().add(oneDayrequest, withCompletionHandler: { (error: Error?) in
                  
                  if error == nil {
                        print("Notification Activated, will be notified when there's 1 day left")
                        print("Notification Activated, will be notified in \(oneDayLeftInSeconds) seconds")
                        
                  }
                  
            })
                  
                            }
      }
      
      func scheduleTestNotification(daysLeft: Int, repeats: Bool, food: FoodObject) {
            
            //this is the content of my notification
            let content = UNMutableNotificationContent()
            content.title = "\(String(describing: food.name!)) is almost expired!"
            content.body = "There's three days left!"
            
            //Next up is the trigger
            
            let threeDays = daysLeft - (daysLeft - 3)
            let daysLeftInSeconds = Double(threeDays * 86400)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: repeats)
            
            let foodName = food.name!
            
            //Now we have to create the request
            let request = UNNotificationRequest(identifier: foodName, content: content, trigger: trigger)
            
            //now we add the request
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
                  
                  if error == nil {
                        print("Notification Activated, will be notified in 3 days")
                        
                  }
                  
            })
            
      }
      
      
      
}

extension NotificationManager: UNUserNotificationCenterDelegate {
      
      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
      }
      
      func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            completionHandler()
      }
      
      
      
}


