//
//  OrderModel.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-17.
//

import Foundation
import UIKit

class OrderModel{
    var id : String
    var name : String
    var imageUrl : String
    var date : Date
    var itemCount : String
    var price : String
    var btnText : String
    
    init( id : String, name : String, imageUrl : String, date : Date, itemCount : String, price : String, btnText : String){
        self.id = id;
        self.name = name
        self.imageUrl = imageUrl
        self.date = date
        self.itemCount = itemCount
        self.price = price
        self.btnText = btnText
    }
}
