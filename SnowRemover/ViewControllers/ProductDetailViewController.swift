//
//  ProductDetailViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-30.
//

import UIKit
import Firebase
import FirebaseFirestore

class ProductDetailViewController: UIViewController {

    var productId = String()
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDiscription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQuntity: UILabel!
    
    var count : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(productId)
        LoadData()
        // Do any additional setup after loading the view.
    }

    @IBAction func RemoveCount(_ sender: Any) {
        if count > 1{
            count = count - 1
            let qnt = String(count)
            productQuntity.text = qnt
        }
    }
    
    @IBAction func AddCount(_ sender: Any) {
        count = count + 1
        let qnt = String(count)
        productQuntity.text = qnt
    }
    
    func LoadData(){
        let db = Firestore.firestore()
        
        db.collection("products").document(productId).getDocument{ snapshot, error in
            if error != nil {
                // ERROR
            }
            else {
                let name = snapshot?.get("name") as? String ?? "productname"
                let description = snapshot?.get("description") as? String ?? "Description"
                let price = snapshot?.get("price_numerical") as? String ?? "300"
                let imageUrl = snapshot?.get("main_image") as? String ?? "Url"
                
                let gsReference = Storage.storage().reference(forURL:  "gs://snowremovalapp-ac3d9.appspot.com/products/"+imageUrl)
                gsReference.downloadURL(completion: { (url, error) in
                    if ((url?.isFileURL) != nil){
                        ImageService.downloadImage(withURL: url!) { image in
                            self.productImage.image = image
                        }
                    }
                })
                
                self.productName.text = name
                self.productDiscription.text = description
                self.productPrice.text = "$"+price
                
            }
        }
    }
    @IBAction func AddToCart(_ sender: Any) {
        
    }
    
    
    @IBAction func BackButoon(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
        
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
}
