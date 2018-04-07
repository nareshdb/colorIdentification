//
//  Color.swift
//  ColorIdentification
//
//  Created by Admin on 07/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import Foundation
import UIKit

class Color: NSObject {
    
    var color: UIColor!
    var name: String?
    var red: CGFloat!
    var green: CGFloat!
    var blue: CGFloat!
    
    init(color: UIColor, name: String?, red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.color = color
        self.name = name
        self.red = red
        self.blue = blue
        self.green = green
    }
}
