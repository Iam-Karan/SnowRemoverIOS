//
//  ProductDetailViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-30.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import YouTubeiOSPlayerHelper

class ProductDetailViewController: UIViewController, YTPlayerViewDelegate {

    var productId = String()
    var favIcon : [UIImage] = [
        UIImage(systemName: "heart")!,
        UIImage(systemName: "heart.fill")!]
    
    var changeIcon : [UIImage] = [
        UIImage(systemName: "circle")!,
        UIImage(systemName: "circle.fill")!
    ]

    var isFavourite : Bool = false
    
    var userUID : String = ""
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDiscription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQuntity: UILabel!
    @IBOutlet weak var favouriteImage: UIImageView!
    
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showVideo: UIImageView!
    
    @IBOutlet var playerView : YTPlayerView!
    
    var count : Int = 1
    var favProductIds : [String] = []
    let db = Firestore.firestore()
    
    var name : String = ""
    var image : String = ""
    var price : String = ""
    var type : String = "products"
    var hours : String = "1"
    var quantity : String = "1"
    var youTubeUrl : String = ""
    var videoId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadData()
        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid ?? ""
        
            getFavourite()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.AddToFavourite(gesture:)))
        favouriteImage.addGestureRecognizer(tapGesture)
        favouriteImage.isUserInteractionEnabled = true
        
        playerView.isHidden = true
        playerView.alpha = 0
        productImage.isHidden = false
        productImage.alpha = 1
        
        let videoBtn = UITapGestureRecognizer(target: self, action: #selector(showYoutubeVideo(tapGestureRecognizer:)))
        showVideo.isUserInteractionEnabled = true
        showVideo.addGestureRecognizer(videoBtn)
        
        let imageBtn = UITapGestureRecognizer(target: self, action: #selector(showProductImage(tapGestureRecognizer:)))
        showImage.isUserInteractionEnabled = true
        showImage.addGestureRecognizer(imageBtn)
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
        
        db.collection("products").document(productId).getDocument{ snapshot, error in
            if error != nil {
                // ERROR
            }
            else {
                self.name = snapshot?.get("name") as? String ?? "productname"
                let description = snapshot?.get("description") as? String ?? "Description"
                self.price = snapshot?.get("price_numerical") as? String ?? "300"
                self.image = snapshot?.get("main_image") as? String ?? "Url"
                self.youTubeUrl = snapshot?.get("video_url") as? String ?? "Url"
                self.videoId = self.youTubeUrl.replacingOccurrences(of: "https://www.youtube.com/watch?v=", with: "")
                
                let gsReference = Storage.storage().reference(forURL:  "gs://snowremovalapp-ac3d9.appspot.com/products/"+self.image)
                gsReference.downloadURL(completion: { (url, error) in
                    if ((url?.isFileURL) != nil){
                        ImageService.downloadImage(withURL: url!) { image in
                            self.productImage.image = image
                        }
                    }
                })
                
                self.productName.text = self.name
                self.productDiscription.text = description
                self.productPrice.text = "$"+self.price
                self.playerView.load(withVideoId: self.videoId, playerVars: ["playsinline" : 1])
                
            }
        }
    }
    
    func getFavourite(){
        
        db.collection("users").document(userUID).collection("favorite").getDocuments(){ [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let id : String = data["id"] as? String ?? ""
                    if(id == productId){
                        isFavourite = true
                        favouriteImage.image = favIcon[1]
                    }
                    favProductIds.append(id)
                }
            }
        }
    }
    
    @objc func AddToFavourite(gesture: UIGestureRecognizer) {
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid ?? ""
        if (gesture.view as? UIImageView) != nil {
                if(isFavourite){
                   
                    db.collection("users").document(userUID).collection("favorite").document(productId).delete(){error in
                        if error != nil {
                            
                        }else{
                            self.isFavourite = !self.isFavourite
                            self.showToast("item removed from favorite!")
                            self.favouriteImage.image = self.favIcon[0]
                        }
                    }
                }else{
                    let data = ["id" : productId, "type" : "products"]
                    
                    db.collection("users").document(userUID).collection("favorite").document(productId).setData(data){error in
                    if error != nil {
                        
                    }else{
                        self.isFavourite = !self.isFavourite
                        self.showToast("item added as favorite!")
                        self.favouriteImage.image = self.favIcon[1]
                    }
                }
            }
            }
        }else{
            self.showToast("You need to login first")
        }
    }
    
    @IBAction func AddToCart(_ sender: Any) {
        
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid ?? ""
            
            quantity = productQuntity.text ?? "1"
            
            let hourINT = Int(hours)
            let quantityINT = Int(quantity)
            let priceDouble  = Double(price)
            
            let cartData = ["id" : productId, "image" : "products/"+image, "name" : name, "price" : priceDouble, "quantity" : quantityINT, "type" : type, "hours" : hourINT] as [String : Any]
            
            db.collection("users").document(userUID).collection("cart").document(productId).getDocument { (document, error) in
                if let document = document, document.exists {
                    print("document exist")
                    var cartQuantity : Int = document.get("quantity") as? Int ?? 0
                    cartQuantity = cartQuantity + (hourINT ?? 0)
                    
                    document.reference.updateData([
                        "hours": cartQuantity
                                ])
                    self.showToast("Cart Upadted Sucessfully!")
                    
                } else {
                    print("document not exist")
                    self.db.collection("users").document(self.userUID).collection("cart").document(self.productId).setData(cartData){error in
                    if error != nil {
                        
                    }else{
                        self.showToast("Item added successfully")
                    }
                    }
                }
            }
        }
        else{
            self.showToast("You need to login first")
        }
    }
    
    @objc func showYoutubeVideo(tapGestureRecognizer: UITapGestureRecognizer){
        showVideo.image = changeIcon[1]
        showImage.image = changeIcon[0]
        
        UIView.animate(withDuration: 0.3) {
            self.playerView.isHidden = !self.playerView.isHidden
            self.playerView.alpha = self.playerView.alpha == 0 ? 1 : 0
            self.playerView.layoutIfNeeded()
            self.productImage.isHidden = !self.productImage.isHidden
            self.productImage.alpha = self.productImage.alpha == 0 ? 1 : 0
            self.productImage.layoutIfNeeded()
        }
        playerView.delegate = self
    }
    
    @objc func showProductImage(tapGestureRecognizer: UITapGestureRecognizer){
        showVideo.image = changeIcon[0]
        showImage.image = changeIcon[1]
        UIView.animate(withDuration: 0.3) {
            self.playerView.isHidden = !self.playerView.isHidden
            self.playerView.alpha = self.playerView.alpha == 0 ? 1 : 0
            self.playerView.layoutIfNeeded()
            self.productImage.isHidden = !self.productImage.isHidden
            self.productImage.alpha = self.productImage.alpha == 0 ? 1 : 0
            self.productImage.layoutIfNeeded()
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    @IBAction func BackButoon(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
        
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
}
