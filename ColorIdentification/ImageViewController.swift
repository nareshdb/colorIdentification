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
    @IBOutlet weak var imagePlaceholder: UIView!
    
    var image: Image? {
        didSet {
        
            if !self.isViewLoaded {return}
            
            if let i = self.image {
                self.imagePlaceholder.isHidden = true
                self.imgPreview.image = i.image
                self.currentImageColors = i.colors
                self.cvColors.reloadData()
                self.cvColors.setContentOffset(.zero, animated: true)
            }
            else {
                self.imgPreview.image = nil
                self.imagePlaceholder.isHidden = false
                self.currentImageColors = []
                self.cvColors.reloadData()
                self.openCameraPopUp()
            }
        }
    }
    var imagePicker = UIImagePickerController()
    weak var delegate: ImageViewControllerDelegate?
    var currentImageColors: [Color] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.cvColors.register(UINib(nibName: "ColorCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ColorCell")
        
        self.imagePicker.delegate = self
        
        self.cvColors.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }

    @IBAction func btnPickerAction(_ sender: UIButton) {
        self.openCameraPopUp()
    }
    
    @IBAction func btnSaveEditAction(_ sender: UIButton) {
        guard let img = self.imgPreview.image
            else {
                self.view.makeToast("No Image Selected")
                return
        }
        
        //Edit
        if let _image = self.image {
            _image.image = img
            _image.colors = self.currentImageColors
            self.delegate?.didEdit(image: _image)
            _ = self.navigationController?.popViewController(animated: true)
        }
        //AddNew
        else {
            let _image = Image(image: img, colors: self.currentImageColors)
            self.delegate?.didAdd(image: _image)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func change(_image: UIImage) {
        
        self.currentImageColors.removeAll()
        
        if let colors = ColorThief.getPalette(from: _image, colorCount: 20) {
            self.currentImageColors = colors.flatMap { (color) -> Color? in
                return Color(
                    color: color.makeUIColor(),
                    name: nil,
                    red: CGFloat(color.r),
                    green: CGFloat(color.g),
                    blue: CGFloat(color.b))
            }
        }
        
        if let primaryColor = ColorThief.getColor(from: _image) {
            self.currentImageColors.insert(
                Color(
                    color: primaryColor.makeUIColor(),
                    name: nil,
                    red: CGFloat(primaryColor.r),
                    green: CGFloat(primaryColor.g),
                    blue: CGFloat(primaryColor.b)
            ), at: 0)
        }

        //The function was called in background queue, so loading views in main queue
        DispatchQueue.main.async {
            self.imagePlaceholder.isHidden = true
            self.imgPreview.image = _image
            self.cvColors.reloadData()
        }
    }
    
}

extension ImageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell
        let color = self.currentImageColors[indexPath.item]
        cell.colorView.backgroundColor = color.color
        cell.lblRGB.text = "R:\(Int(color.red!)) G:\(Int(color.green!)) B:\(Int(color.blue!))"
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentImageColors.count
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
        
        cameraPopUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
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
        self.view.makeToast("Loading your colors")
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.change(_image: pickedImage)
        }
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

protocol ImageViewControllerDelegate: NSObjectProtocol {
    func didAdd(image: Image)
    func didEdit(image: Image)
}
