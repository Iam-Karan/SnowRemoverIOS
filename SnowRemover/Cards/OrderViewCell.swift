//
//  OrderViewCell.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-17.
//

import UIKit

class OrderViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var itemCount: UILabel!
    @IBOutlet weak var orderPrice: UILabel!
    @IBOutlet weak var orderImage: UIImageView!
    @IBOutlet weak var orderBtn: UIButton!
    
    override func awakeFromNib(){
        super.awakeFromNib()
    }

    
    func setData(with data : OrderModel){
        let currntDate = Date()
        name.text =  data.name
        
        itemCount.text = "x"+data.itemCount+" items"
        orderPrice.text = "$"+data.price
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        let dateString  : String = dateFormatter.string(from: data.date as Date)
        date.text = dateString
        
        if(data.date > currntDate){
            orderBtn.titleLabel?.text = "Pending"
            orderBtn.layer.backgroundColor = CGColor.init(red: 255, green: 255, blue: 0, alpha: 1)
        }else{
            orderBtn.titleLabel?.text = "Completed"
            orderBtn.layer.backgroundColor = CGColor.init(red: 0, green: 255, blue: 0, alpha: 1)
        }
    }

}
