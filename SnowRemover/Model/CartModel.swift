//
//  CartModel.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-13.
//

import Foundation
import UIKit

class CartModel {
    var id : String
    var name : String
    var imageurl : String
    var type : String
    var hours : String
    var quantity : String
    
    init(id : String, name : String, imageUrl  :String, type : String, hours : String, quantity : String){
        self.id = id
        self.name = name
        self.imageurl = imageUrl
        self.type = type
        self.hours = hours
        self.quantity = quantity
    }
}
