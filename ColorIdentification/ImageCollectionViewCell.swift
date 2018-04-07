//
//  ImageCollectionViewCell.swift
//  ColorIdentification
//
//  Created by Admin on 07/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cvColors: UICollectionView!
    @IBOutlet weak var imgPreview: UIImageView!
    var currentImageColors: [Color] = []
    
    override func awakeFromNib() {
        self.cvColors.register(UINib(nibName: "ColorCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ColorCell")
        self.cvColors.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
}

extension ImageCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell
        let color = self.currentImageColors[indexPath.item]
        cell.colorView.backgroundColor = color.color
        cell.lblRGB.text = "R:\(Int(color.red!))\nG:\(Int(color.green!))\nB:\(Int(color.blue!))"
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentImageColors.count
    }
    
}
