//
//  CheckoutViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-13.
//

import UIKit
import Firebase
import FirebaseAuth

class CheckoutViewController: UIViewController {

    var orderDate = Date()
    
    var userUID : String = ""
    var total : Double = 0
    var tax : Double = 0
    var subtotal : Double = 0
    var orderID : String = ""
    
    var cartData = [[String : Any]]()
    
    @IBOutlet weak var taxValue: UILabel!
    @IBOutlet weak var subtotalValue: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    
    @IBOutlet weak var addressValue: UITextField!
    @IBOutlet weak var cityValue: UITextField!
    @IBOutlet weak var stateValue: UITextField!
    @IBOutlet weak var countryValue: UITextField!
    @IBOutlet weak var zipCodeValue: UITextField!
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid ?? ""
            loadData()
        }
        errorText.isHidden = true
        
    }
    
    func loadData(){
        let db = Firestore.firestore()
        
        db.collection("users").document(userUID).collection("cart").getDocuments(){ [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let docId = document.documentID
                    let nameValue: String = data["name"] as? String ?? ""
                    let imageUrlValue: String = data["image"] as? String ?? ""
                    let price : Double = data["price"] as? Double ?? 0
                    let type : String = data["type"] as? String ?? ""
                    let quantity : Int = data["quantity"] as? Int ?? 1
                    let hours : Int = data["hours"] as? Int ?? 1
                    
                    if(type == "personimages"){
                        subtotal = subtotal + (price * Double(hours))
                    }else{
                        subtotal = subtotal + (price * Double(quantity))
                    }
                   
                    let items : [String : Any] = ["hour" : String(hours), "id" : docId, "imageUrl" : imageUrlValue, "name" : nameValue, "price" : price, "quantity" : String(quantity), "type" : type]
                    
                    cartData.append(items)
                }
                
                tax = (subtotal * 15) / 100
                total = subtotal + tax
                
                let subtotalString : String = String(subtotal)
                let totalString : String = String(total)
                let taxString : String = String(tax)
                
                subtotalValue.text = subtotalString
                taxValue.text = taxString
                totalValue.text = totalString
                
               
            }
        }
    }
    @IBAction func confirmOrder(_ sender: Any) {
        let addressString : String = addressValue.text ?? ""
        let cityString : String = cityValue.text ?? ""
        let stateString : String = stateValue.text ?? ""
        let countryString : String = countryValue.text ?? ""
        let zipString : String = zipCodeValue.text ?? ""
        if(!addressString.isEmpty && !cityString.isEmpty && !stateString.isEmpty && !countryString.isEmpty && !zipString.isEmpty){
            let orderAddress = addressString+", "+cityString+", "+stateString+", "+countryString+" "+zipString
            let curruntDate = Date()
            
            let db = Firestore.firestore()
            let orderData = ["address" : orderAddress, "items" : cartData, "order_date" : curruntDate, "payment" : true, "reservation_datetime" : orderDate, "total" : total] as [String : Any]
            
            let ref = db.collection("users").document(userUID).collection("order").document()
            orderID = ref.documentID
            ref.setData(orderData){error in
            if error != nil {
                
            }
            }
            
            let adminOrderData = ["address" : orderAddress, "items" : cartData, "order_date" : curruntDate, "payment" : true, "reservation_datetime" : orderDate, "total" : total, "feedback" :"", "isDelivered": false, "userId" : userUID] as [String : Any]
            
            db.collection("orders").document(orderID).setData(adminOrderData){error in
                if error != nil {
                    
                }
                }
            
            for item in cartData{
                let itemId = item["id"] as! String
                
                db.collection("users").document(userUID).collection("cart").document(itemId).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    }
                }
            }
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
            
            secondViewController.modalPresentationStyle = .fullScreen
            secondViewController.showToast("Order Placed successfully!")
            self.present(secondViewController, animated:true, completion:nil)
            
        }
        if(addressString.isEmpty){
            self.errorText.text = "Address must not be empty"
            self.errorText.isHidden = false
            self.addressValue.layer.borderWidth = 1
            self.addressValue.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        if(cityString.isEmpty){
            self.errorText.text = "City must not be empty"
            self.errorText.isHidden = false
            self.cityValue.layer.borderWidth = 1
            self.cityValue.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        if(stateString.isEmpty){
            self.errorText.text = "State must not be empty"
            self.errorText.isHidden = false
            self.stateValue.layer.borderWidth = 1
            self.stateValue.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        if(countryString.isEmpty){
            self.errorText.text = "Country must not be empty"
            self.errorText.isHidden = false
            self.countryValue.layer.borderWidth = 1
            self.countryValue.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        if(zipString.isEmpty){
            self.errorText.text = "Zipcode must not be empty"
            self.errorText.isHidden = false
            self.zipCodeValue.layer.borderWidth = 1
            self.zipCodeValue.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "CartStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        
        self.present(secondViewController, animated:true, completion:nil)
    }
}
