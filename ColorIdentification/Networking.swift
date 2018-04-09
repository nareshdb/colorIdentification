//
//  Networking.swift
//  ColorIdentification
//
//  Created by Admin on 09/04/18.
//  Copyright © 2018 Naresh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Networking: NSObject {
 
    enum ColorNamesResponse {
        case success(names: [String])
        case error(message: String)
    }
    
    class func getColorNames(colors: [(r: Double, g: Double, b: Double)], response: @escaping (ColorNamesResponse)->()) {
        
        let parameters: [String:Any] = [
            "colors":colors.map({ color -> [String:Double] in
                return [
                    "r":color.r,
                    "g":color.g,
                    "b":color.b
                ]
            })
        ]
        
        Alamofire.request(URL(string: "https://us-central1-learning-firebase-190ab.cloudfunctions.net/rgbToColorName")!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (res) in
            if let colorNames = (res.result.value as AnyObject).value(forKey: "names") {
                let names = JSON(colorNames).arrayValue.map({ (name) -> String in
                    return name.stringValue
                })
                response(.success(names: names))
            }
            else {
                response(.error(message: res.error?.localizedDescription ?? "Something went wrong."))
            }
        }
    }
}
