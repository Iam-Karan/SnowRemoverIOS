//
//  PersondetailViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-30.
//

import UIKit
import Firebase

class PersondetailViewController: UIViewController {

    var personId = String()
    var favIcon : [UIImage] = [
        UIImage(systemName: "heart")!,
        UIImage(systemName: "heart.fill")!]

    var isFavourite : Bool = false
    
    @IBOutlet weak var personHours: UILabel!
    var userUID : String = ""
    
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personDescription: UILabel!
    @IBOutlet weak var personPrice: UILabel!
    @IBOutlet weak var personAge: UILabel!
    @IBOutlet weak var favouriteImage: UIImageView!
    @IBOutlet weak var personImage: UIImageView!
    
    var favProductIds : [String] = []
    let db = Firestore.firestore()
    var hour : Int = 1
    
    var name : String = ""
    var image : String = ""
    var price : String = ""
    var type : String = "person"
    var hours : String = "1"
    var quantity : String = "1"
    var cartid : [String] = []
    var cartQuntity : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        LoadData()
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid ?? ""
            print(userUID)
            getFavourite()
            
            
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.AddToFavourite(gesture:)))
        favouriteImage.addGestureRecognizer(tapGesture)
        favouriteImage.isUserInteractionEnabled = true
    }
    
    @IBAction func removeHours(_ sender: Any) {
        if hour > 1{
            hour = hour - 1
            let qnt = String(hour)
            personHours.text = qnt
        }
    }
    
    @IBAction func addHours(_ sender: Any) {
        hour = hour + 1
        let qnt = String(hour)
        personHours.text = qnt
    }
    
    
    func LoadData(){
        let db = Firestore.firestore()
        
        db.collection("person").document(personId).getDocument{ snapshot, error in
            if error != nil {
                // ERROR
            }
            else {
                self.name = snapshot?.get("name") as? String ?? "productname"
                let description = snapshot?.get("description") as? String ?? "Description"
                self.price = snapshot?.get("Price") as? String ?? "300"
                self.image = snapshot?.get("imageurl") as? String ?? "Url"
                let age = snapshot?.get("age") as? Int ?? 20
                let ageVlue = String(age)
                
                let gsReference = Storage.storage().reference(forURL:  "gs://snowremovalapp-ac3d9.appspot.com/personimages/"+self.image)
                gsReference.downloadURL(completion: { (url, error) in
                    if ((url?.isFileURL) != nil){
                        ImageService.downloadImage(withURL: url!) { image in
                            self.personImage.image = image
                        }
                    }
                })
                
                self.personName.text = self.name
                self.personDescription.text = description
                self.personPrice.text = "$"+self.price
                self.personAge.text = ageVlue
                
            }
        }
    }
    
    
    @IBAction func AddToCart(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid ?? ""
            
            quantity = personHours.text ?? "1"
            
            let hourINT = Int(quantity)
            let quantityINT = Int(hours)
            let priceDouble  = Double(price)
            
            let cartData = ["id" : personId, "image" : "personimages/"+image, "name" : name, "price" : priceDouble, "quantity" : quantityINT, "type" : type, "hours" : hourINT] as [String : Any]
            
            db.collection("users").document(userUID).collection("cart").document(personId).getDocument { (document, error) in
                if let document = document, document.exists {
                    print("document exist")
                    var cartQuantity : Int = document.get("hours") as? Int ?? 0
                    cartQuantity = cartQuantity + (hourINT ?? 0)
                    
                    document.reference.updateData([
                        "hours": cartQuantity
                                ])
                    self.showToast("Cart Upadted Sucessfully!")
                    
                } else {
                    print("document not exist")
                    self.db.collection("users").document(self.userUID).collection("cart").document(self.personId).setData(cartData){error in
                    if error != nil {
                        
                    }else{
                        self.showToast("service added successfully")
                    }
                    }
                }
            }
        }else{
            self.showToast("You need to login first")
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
                    if(id == personId){
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
                    db.collection("users").document(userUID).collection("favorite").document(personId).delete(){error in
                        if error != nil {
                            
                        }else{
                            self.isFavourite = !self.isFavourite
                            self.showToast("services removed as favorite!")
                            self.favouriteImage.image = self.favIcon[0]
                        }
                    }
                }else{
                    let data = ["id" : personId, "type" : "person"]
                    
                    db.collection("users").document(userUID).collection("favorite").document(personId).setData(data){error in
                    if error != nil {
                       
                    }else{
                        self.isFavourite = !self.isFavourite
                        self.showToast("services added as favorite!")
                        self.favouriteImage.image = self.favIcon[1]
                    }
                }
            }
            }
        }else{
            self.showToast("You need to login first")
        }
    }
    
    @IBAction func GotoHomeScreen(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
        
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
}
