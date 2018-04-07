//
//  Image.swift
//  ColorIdentification
//
//  Created by Admin on 06/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import Foundation
import RealmSwift
import Realm


class Image: Object {
    
    dynamic var image: Data!
    var colors = List<Color>()
    
    convenience init(image: Data, colors: List<Color>) {
        self.init()
        self.image = image
        self.colors = colors
    }
}
