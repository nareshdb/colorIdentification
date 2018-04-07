//
//  Image.swift
//  ColorIdentification
//
//  Created by Admin on 06/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import Foundation
import UIKit

class Image: NSObject {
    
    var image: UIImage!
    var colors: [Color] = []
    
    init(image: UIImage, colors: [Color]) {
        self.image = image
        self.colors = colors
    }
}
