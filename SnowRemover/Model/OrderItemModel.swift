//
//  OrderItemModel.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-18.
//

import Foundation

class OrderItemModel{
    var id : String
    var name : String
    var imageurl : String
    var type : String
    var hours : String
    var quantity : String
    var price : String
    
    init(id : String, name : String, imageUrl  :String, type : String, hours : String, quantity : String, price : String){
        self.id = id
        self.name = name
        self.imageurl = imageUrl
        self.type = type
        self.hours = hours
        self.quantity = quantity
        self.price = price
    }
}
