//
//  CameraViewController.swift
//  FoodPal
//
//  Created by Sunny Ouyang on 7/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftyJSON

//our reg UIView will be backed by an instance of our avcaptureVideoPreviewLayer
//and our layer property is overrided to cast the return value to the AVpreviewlayer


class CameraView: UIView {
      
      
      
      //basically a static var we can access in other classes
      
      
      
      override class var layerClass: AnyClass {
            get {
                  //so our camera can capture video?
                  //what does it mean to write .self
                  return AVCaptureVideoPreviewLayer.self
            }
      }
      //this variable is an instance of the AVCaptureVideoPreviewLayer?
      override var layer: AVCaptureVideoPreviewLayer {
            get {
                  //what is the super.layer referring to?
                  return super.layer as! AVCaptureVideoPreviewLayer
            }
      }
      
}

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
      
      
      var highlightView = UIView()
      
      //access a camera view
      var cameraView: CameraView!
      
      var productToPass: Product? = nil
      var imageURLtoPass: String? = nil
      
      let session = AVCaptureSession()
      let sessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [],  target: nil)
      
      //create a UIView, and set it equal to camera
      
      
      override func loadView() {
            cameraView = CameraView()
            view = cameraView
      }
      
      override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            self.highlightView.autoresizingMask =   [UIViewAutoresizing.flexibleTopMargin,
                                                     UIViewAutoresizing.flexibleBottomMargin,
                                                     UIViewAutoresizing.flexibleLeftMargin,
                                                     UIViewAutoresizing.flexibleRightMargin
            ]
            self.highlightView.layer.borderColor = UIColor.green.cgColor
            self.highlightView.layer.borderWidth = 3
            
            
            self.view.addSubview(self.highlightView)
            sessionQueue.async {
                  self.session.startRunning()
            }
      }
      
      override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            sessionQueue.async {
                  self.session.stopRunning()
            }
      }
      
      override func viewDidLoad() {
            
            super.viewDidLoad()
            
            let _ = self.view
            
            //beginning our video capture session with AV
            self.navigationController?.navigationBar.tintColor = UIColor.white
            //what I'm guessing is that we added the preview layer, and its somehow fkin with the highlight view
            
            
            session.beginConfiguration()
            //provides an object that is accessing our camera
            let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            //now we gotta check to see if our device has a camera
            if (videoDevice != nil) {
                  //the input we receive from our camera
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice)
                  //now we check if our camera has input to give back to us
                  if videoDeviceInput != nil {
                        // we know that there is input, now we check if it is the correct type
                        if session.canAddInput(videoDeviceInput){
                              session.addInput(videoDeviceInput)
                        }
                  }
            }
            //creating an object that has all of the output data from our capture session
            let metaDataOutput = AVCaptureMetadataOutput()
            //now, just like with input, we gotta check if we can add the output to our session
            if session.canAddOutput(metaDataOutput){
                  session.addOutput(metaDataOutput)
                  metaDataOutput.metadataObjectTypes = [
                        AVMetadataObjectTypeEAN13Code,
                        AVMetadataObjectTypeQRCode,
                        AVMetadataObjectTypeEAN8Code,
                        AVMetadataObjectTypeCode39Code,
                        AVMetadataObjectTypeCode128Code
                  ]
                  //sets the metaDataOutput delegate in this class, we're going to handle the callbacks, what we want to do with the output here.
                  metaDataOutput.setMetadataObjectsDelegate(self as! AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            }
            
            session.commitConfiguration()
            
            cameraView.layer.session = session
            cameraView.layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            
            let videoOrientation: AVCaptureVideoOrientation
            switch UIApplication.shared.statusBarOrientation {
            case .portrait:
                  videoOrientation = .portrait
                  
            case .portraitUpsideDown:
                  videoOrientation = .portraitUpsideDown
                  
            case .landscapeLeft:
                  videoOrientation = .landscapeLeft
                  
            case .landscapeRight:
                  videoOrientation = .landscapeRight
                  
            default:
                  videoOrientation = .portrait
            }
            
            cameraView.layer.connection.videoOrientation = videoOrientation
            
            
            
            
            
            
            // Do any additional setup after loading the view, typically from a nib.
      }
      
      override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            
            // Update camera orientation
            let videoOrientation: AVCaptureVideoOrientation
            switch UIDevice.current.orientation {
            case .portrait:
                  videoOrientation = .portrait
                  
            case .portraitUpsideDown:
                  videoOrientation = .portraitUpsideDown
                  
            case .landscapeLeft:
                  videoOrientation = .landscapeRight
                  
            case .landscapeRight:
                  videoOrientation = .landscapeLeft
                  
            default:
                  videoOrientation = .portrait
            }
            
            cameraView.layer.connection.videoOrientation = videoOrientation
      }
      
      
      
      
      func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
            
            guard let metaDataObject = metadataObjects as? [AVMetadataMachineReadableCodeObject] else {
                  return
            }
            
            var highlightRect = CGRect()
            
            if metadataObjects.count > 0 && metadataObjects.first is AVMetadataMachineReadableCodeObject {
                  let scan = metadataObjects.first as! AVMetadataMachineReadableCodeObject
                  
                  highlightRect = scan.bounds
                  highlightRect.origin.x *= view.bounds.size.width
                  highlightRect.origin.y *= view.bounds.size.height
                 
                  highlightRect.size.width *= (view.bounds.size.width)
                  
                  highlightRect.size.height *= (view.bounds.size.height)
                  self.highlightView.frame = highlightRect
                  
                  self.view.bringSubview(toFront: self.highlightView)
                  
                  if let barcode = scan.stringValue {
                        
                        self.session.stopRunning()
                        
                        let apiToContact = "https://api.upcitemdb.com/prod/trial/lookup?upc=\(barcode)"
                        
                        Alamofire.request(apiToContact).validate().responseJSON() { response in
                              
                              switch response.result {
                                    
                              case .success:
                                    if let value = response.result.value {
                                          
                                          let json = JSON(value)
                                          
                                          
                                          
                                          guard let title = json["items"][0]["offers"][0]["title"].string, let imageURL = json["items"][0]["images"][0].string else {
                                                
                                                let alertController = UIAlertController(title: "No Data found", message: "Database doesn't contain data for this barcode", preferredStyle: .alert
                                                )
                                                
                                                
                                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                                }))
                                                
                                                self.present(alertController, animated: true, completion: nil)
                                                
                                                return
                                                
                                          }
                                          
                                          let product = Product(title: title, imageURL: imageURL)
                                          self.productToPass = product
                                          self.imageURLtoPass = imageURL
                                          
                                          
                                    }
                                    
                                    let alertController = UIAlertController(title: "Barcode scanned", message: scan.stringValue, preferredStyle: .alert
                                    )
                                    
                                    
                                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                          self.performSegue(withIdentifier: "done", sender: nil)
                                          
                                    }))
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                    
                                    
                              case .failure:
                                    
                                    
                                    print("Can't call api")
                                    
                                    
                              }
                              
                        }
                        
                  }
                  
            }
            
      }
      
      
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "done" {
                  let destinationVC = segue.destination as! ItemScannerViewController
                  destinationVC.product = productToPass
                  destinationVC.selectedItemImageURL = imageURLtoPass
                  // destinationVC.bypass = false
            }
      }
      
      override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
      }
      
      
}
