//
//  Color.swift
//  ColorIdentification
//
//  Created by Admin on 07/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Color: Object {
    
    var color: UIColor {
        get {
            return UIColor(red: CGFloat(self.red.divided(by: 255.0)), green: CGFloat(self.green.divided(by: 255.0)), blue: CGFloat(self.blue.divided(by: 255.0)), alpha: 1.0)
        }
    }
    dynamic var name: String?
    dynamic var red: Double = 0.0
    dynamic var green: Double = 0.0
    dynamic var blue: Double = 0.0
    
    convenience init(color: UIColor, name: String?, red: Double, green: Double, blue: Double) {
        self.init()
        self.name = name
        self.red = red
        self.blue = blue
        self.green = green
    }
}
