//
//  ViewController.swift
//  ColorIdentification
//
//  Created by Admin on 06/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var cvImages: UICollectionView!
    @IBOutlet weak var cvImagesPlaceHolder: UIView!
    
    var imageVC: ImageViewController!
    var images: [Image] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
        self.imageVC.delegate = self
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:themeColorRed]
        self.cvImages.register(UINib(nibName: "ImageCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ImageCell")
        self.cvImages.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    @IBAction func btnFABAction(_ sender: UIButton) {
        self.imageVC.image = nil
        self.navigationController?.pushViewController(self.imageVC, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        let image = self.images[indexPath.section]
        cell.imgPreview.image = image.image
        cell.currentImageColors = image.colors
        cell.cvColors.reloadData()
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.cvImagesPlaceHolder.isHidden = self.images.count != 0
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = self.images[indexPath.section]
        self.imageVC.image = image
        self.navigationController?.pushViewController(self.imageVC, animated: true)
    }
    
}

extension HomeViewController: ImageViewControllerDelegate {
    
    func didAdd(image: Image) {
        //Scrolling to top on adding new image
        self.cvImages.setContentOffset(.zero, animated: true)
        self.cvImages.performBatchUpdates({ 
            self.images.insert(image, at: 0)
            self.cvImages.insertSections(IndexSet.init(integer: 0))
        }, completion: nil)
    }
    
    func didEdit(image: Image) {
        if let i = self.images.index(of: image) {
            self.cvImages.reloadSections(IndexSet.init(integer: i))
        }
    }
    
}
