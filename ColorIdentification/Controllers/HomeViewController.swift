//
//  ViewController.swift
//  ColorIdentification
//
//  Created by Admin on 06/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import Toast_Swift

class HomeViewController: UIViewController {

    @IBOutlet weak var cvImages: UICollectionView!
    @IBOutlet weak var cvImagesPlaceHolder: UIView!
    
    var imageVC: ImageViewController!
    var images = try! Realm().objects(Image.self)
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
        //So that loadView get called
        let _ = imageVC.view
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:themeColorRed]
        self.cvImages.register(UINib(nibName: "ImageCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ImageCell")
        self.cvImages.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 100, right: 0)
        
        
        // Set results notification block
        self.notificationToken = self.images.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.cvImages.reloadData()
                self.cvImagesPlaceHolder.isHidden = self.images.count != 0
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.cvImages.performBatchUpdates({
                    
                    if insertions.count > 0 {
                        //Insertions
                        let insertionsIndexSet = NSMutableIndexSet()
                        insertions.forEach{insertionsIndexSet.add($0)}
                        self.cvImages.insertSections(insertionsIndexSet as IndexSet)
                    }
                    
                    if deletions.count > 0 {
                        //Deletions
                        let deletionsIndexSet = NSMutableIndexSet()
                        deletions.forEach{deletionsIndexSet.add($0)}
                        self.cvImages.deleteSections(deletionsIndexSet as IndexSet)
                    }
                    
                    if modifications.count > 0 {
                        //modifications
                        let modificationsIndexSet = NSMutableIndexSet()
                        modifications.forEach{modificationsIndexSet.add($0)}
                        self.cvImages.reloadSections(modificationsIndexSet as IndexSet)
                    }
                    
                }, completion: { (x) in
                    self.cvImagesPlaceHolder.isHidden = self.images.count != 0
                })
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                self.view.makeToast(err.localizedDescription)
                break
            }
        }
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
        cell.imgPreview.image = UIImage(data: image.image)
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
