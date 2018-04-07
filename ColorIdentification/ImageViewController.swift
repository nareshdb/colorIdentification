//
//  ImageViewController.swift
//  ColorIdentification
//
//  Created by Admin on 06/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import UIKit
import ColorThiefSwift
import AVFoundation
import AVKit
import Toast_Swift
import Photos

class ImageViewController: UIViewController {

    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var cvColors: UICollectionView!
    
    weak var image: Image!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.cvColors.register(UINib(nibName: "ColorCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ColorCell")
    }

    @IBAction func btnPickerAction(_ sender: UIButton) {
        self.openCameraPopUp()
    }
    
    @IBAction func btnSaveEditAction(_ sender: UIButton) {
        
    }
    
    func change(_image: UIImage) {
        
        self.imgPreview.image = _image
        self.image.colors.removeAll()
        
        
        if let colors = ColorThief.getPalette(from: _image, colorCount: 20) {
            self.image.colors = colors.flatMap { (color) -> Color? in
                return Color(
                    color: color.makeUIColor(),
                    name: nil,
                    red: CGFloat(color.r),
                    green: CGFloat(color.g),
                    blue: CGFloat(color.b))
            }
        }
        
        if let primaryColor = ColorThief.getColor(from: _image) {
            self.image.colors.insert(
                Color(
                    color: primaryColor.makeUIColor(),
                    name: nil,
                    red: CGFloat(primaryColor.r),
                    green: CGFloat(primaryColor.g),
                    blue: CGFloat(primaryColor.b)
            ), at: 0)
        }

        self.cvColors.reloadData()
    }
    
}

extension ImageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
   
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell
        let color = self.image.colors[indexPath.item]
        cell.colorView.backgroundColor = color.color
        cell.lblRGB.text = "R:\(color.red) G:\(color.green) B:\(color.blue)"
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.image?.colors.count ?? 0
    }
    
}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCameraPopUp()
    {
        let cameraPopUp = UIAlertController(title: "Select Source", message: "", preferredStyle: .actionSheet)
        
        cameraPopUp.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            func gotoCamera()
            {
                if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
                {
                    self.view.makeToast("Camera not available")
                    return
                }
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            switch authStatus
            {
            case .denied :
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(_ granted: Bool) -> Void in
                    
                    DispatchQueue.main.async {
                        if granted {
                            gotoCamera()
                        }
                        else {
                            self.view.makeToast("Camera access is required")
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                                }
                            }
                        }
                    }
                })
            case .authorized, .notDetermined :
                gotoCamera()
            case .restricted :
                self.view.makeToast("You are not permitted to access camera.")
            }
        }))
        
        cameraPopUp.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (action) in
                
                let authStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
                func openPhotos()
                {
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
                    {
                        self.imagePicker.sourceType = .photoLibrary
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                    else
                    {
                        self.view.makeToast("Photos not available.")
                        return
                    }
                }
                switch authStatus
                {
                case .authorized :
                    openPhotos()
                case .denied, .notDetermined :
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        DispatchQueue.main.async {
                            switch status
                            {
                            case .authorized:
                                openPhotos()
                            case .denied:
                                self.view.makeToast("Photos access is required")
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                                    if #available(iOS 10.0, *) {
                                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                                    } else {
                                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                                    }
                                }
                            default :
                                break
                            }
                        }
                    })
                case .restricted :
                    self.view.makeToast("You are not permitted to access photos.")
                }
        }))
        
        self.present(cameraPopUp, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        var pickedImage = UIImage()
        if let p = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            pickedImage = p
        }
        else if let p = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            pickedImage = p
        }
        else {
            return
        }
        self.change(_image: pickedImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}


fileprivate extension UIColor {
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let components = self.cgColor.components else { return nil }
        
        return (
            red: components[0],
            green: components[1],
            blue: components[2],
            alpha: components[3]
        )
    }
}

