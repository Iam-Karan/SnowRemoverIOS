//
//  OrderItemTableViewCell.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-18.
//

import UIKit
import Firebase

class OrderItemTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(with data : OrderItemModel){
        name.text = data.name
        let gsReference = Storage.storage().reference(forURL:  "gs://snowremovalapp-ac3d9.appspot.com/"+data.imageurl)
        gsReference.downloadURL(completion: { (url, error) in
            if ((url?.isFileURL) != nil){
                ImageService.downloadImage(withURL: url!) { image in
                    self.productImage.image = image
                }
            }
        })
        
        price.text = "$"+data.price
        
        if(data.type == "products"){
            quantity.text = "Quantity: "+data.quantity
        }else{
            quantity.text = "Hours: "+data.quantity
        }
        
    }

}
