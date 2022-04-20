//
//  CartTableViewCell.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-13.
//

import UIKit
import Firebase

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var cartImage: UIImageView!
    
    @IBOutlet weak var cartName: UILabel!
    @IBOutlet weak var quantity: UILabel!

    @IBOutlet weak var removeItem: UIButton!
    @IBOutlet weak var itemCount: UILabel!
    
    @IBOutlet weak var increaseItem: UIButton!
    @IBOutlet weak var decreaseItem: UIButton!
    
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    
    public func setData(with items: CartModel){
        cartName.text = items.name
        
        let gsReference = Storage.storage().reference(forURL:  "gs://snowremovalapp-ac3d9.appspot.com/"+items.imageurl)
        gsReference.downloadURL(completion: { (url, error) in
            if ((url?.isFileURL) != nil){
                ImageService.downloadImage(withURL: url!) { image in
                    self.cartImage.image = image
                }
            }
        })
        if items.type != "products"{
            self.quantity.text = "Hours:"
            self.itemCount.text = items.hours
        }else{
            self.quantity.text = "Quantity:"
            self.itemCount.text = items.quantity
        }
    }
    
}
