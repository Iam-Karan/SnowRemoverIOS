//
//  ProductCollectionViewCell.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-29.
//

import UIKit
import Firebase

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    static func nib() -> UINib {
        return UINib(nibName: "ProductCollectionViewCell", bundle: nil)
    }
    
    public func setData(with product: ProductModel){
        nameLabel.text = product.name
        priceLabel.text = product.price
        
        imageView.image = UIImage(named: "logo")
        
        if product.type == "person"{
            let gsReference = Storage.storage().reference(forURL:  "gs://snowremovalapp-ac3d9.appspot.com/personimages/"+product.imageurl)
            gsReference.downloadURL(completion: { (url, error) in
                if ((url?.isFileURL) != nil){
                    ImageService.downloadImage(withURL: url!) { image in
                        self.imageView.image = image
                    }
                }
            })
        }else{
            let gsReference = Storage.storage().reference(forURL:  "gs://snowremovalapp-ac3d9.appspot.com/products/"+product.imageurl)
            gsReference.downloadURL(completion: { (url, error) in
                if ((url?.isFileURL) != nil){
                    ImageService.downloadImage(withURL: url!) { image in
                        self.imageView.image = image
                    }
                }
            })
        }
        
        
        
        
        
        
    }

}
