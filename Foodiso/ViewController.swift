//
//  ViewController.swift
//  Foodiso
//
//  Created by Babak Farahanchi on 2018-02-22.
//  Copyright © 2018 Bob. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let apikey = "15fd7ceae16c246b66481f745408cc6d4e049aa4"
    let version = "2018-02-22"
    var calssificationResults: [String] = []
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topbarImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shareButton.isHidden = true
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            let visualRecognition = VisualRecognition(apiKey: apikey, version: version)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
//                print(classifiedImages)
                
            let classes = classifiedImages.images.first!.classifiers.first!.classes
                self.calssificationResults = []
                for index in 0..<classes.count {
                    self.calssificationResults.append(classes[index].classification)
                }
                print(self.calssificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                if self.calssificationResults.contains("hotdog"){
                    
                    DispatchQueue.main.async {
                        self.navigationItem.title = "HotDog !!"
                        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topbarImageView.image = UIImage(named: "hotdog")
                    }
                    
                }
                else{
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not a HotDog !!"
                        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topbarImageView.image = UIImage(named: "not-hotdog")

                    }

                }
            })
            
        }else{
            print("issue in taking photo bobby jan")
        }
        
    }

 

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(String(describing: navigationItem.title))")
            
            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
        }
        else{
            self.navigationItem.title = "please login to twitter"
            
        }
        
    }
    
}

