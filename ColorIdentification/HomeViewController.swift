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
    
    var images: [Image] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cvImages.register(UINib(nibName: "ImageCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ImageCell")
    }

    @IBAction func btnFABAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
}
