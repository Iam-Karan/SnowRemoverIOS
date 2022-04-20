//
//  CartViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-10.
//

import UIKit
import Firebase
import FirebaseAuth

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var cartTable: UITableView!
    
    @IBOutlet weak var reserveBtn: UIButton!
    @IBOutlet weak var orderBtn: UIButton!
    @IBOutlet weak var emptyCart: UIView!
    
    var userUID : String = ""
    var cartItems : [CartModel] = []
    var cartData : [[String : Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        orderBtn.isHidden = true
        reserveBtn.isHidden = true
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid ?? ""
            loadData()
        }
        
        cartTable.dataSource = self
        cartTable.delegate = self
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
                    let type : String = data["type"] as? String ?? ""
                    let quantity : Int = data["quantity"] as? Int ?? 1
                    let hours : Int = data["hours"] as? Int ?? 1
                    let price : Double = data["price"] as? Double ?? 1
                    let hoursValue : String = String(hours)
                    let quantityvalue : String = String(quantity)
                    
                    cartItems.append(CartModel(id: docId, name: nameValue, imageUrl: imageUrlValue, type: type, hours: hoursValue, quantity: quantityvalue))
                    
                    let item = ["id" : docId, "image" : imageUrlValue, "name" : nameValue, "price" : price, "quantity" : quantity, "type" : type, "hours" : hours] as [String : Any]
                    
                    cartData.append(item)
                    
                   // products.append(ProductModel(id: docId, name: nameValue, price: priceValue, imageurl: imageUrlValue, type: type))
                }
                if(cartData.count > 0){
                    emptyCart.isHidden = true
                    orderBtn.isHidden = false
                    reserveBtn.isHidden = false
                }
                self.cartTable.reloadData()
                //self.personCollection.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        
        
        cell.setData(with: cartItems[indexPath.row])
        
        cell.removeItem.tag = indexPath.row
        cell.removeItem.addTarget(self, action: #selector(removeItem), for: .touchUpInside)
        
        cell.increaseItem.tag = indexPath.row
        cell.increaseItem.addTarget(self, action: #selector(increaseCount), for: .touchUpInside)
        
        cell.decreaseItem.tag = indexPath.row
        cell.decreaseItem.addTarget(self, action: #selector(decreaseCount), for: .touchUpInside)
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        let separatorLineView = UIView(frame: CGRect(x: 0, y: 0, width: 380, height: 3))
        /// change size as you need.
        separatorLineView.backgroundColor = UIColor.white
        // you can also put image here
        cell.contentView.addSubview(separatorLineView)
        
        return cell
    }
    
    @objc func removeItem(sender : UIButton){
        
        let indexPath = sender.tag
      
        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection("cart").document(cartItems[indexPath].id).delete() { (err) in
            if let err = err {
                print(err)
            }else{
                self.showToast("item removed successfully")
                self.cartItems.removeAll()
                self.loadData()
            }
            
        }
        
    }
    
    @objc func increaseCount(sender : UIButton){
        let indexPath = sender.tag
        let type : String = cartItems[indexPath].type
        let db = Firestore.firestore()
        
        if(type == "products"){
            let quntity = (Int(cartItems[indexPath].quantity) ?? 0) + 1
            cartData[indexPath]["quantity"] = quntity
            db.collection("users").document(userUID).collection("cart").document(cartItems[indexPath].id).setData(cartData[indexPath])
        }else{
            let quntity = (Int(cartItems[indexPath].hours) ?? 0) + 1
            cartData[indexPath]["hours"] = quntity
            db.collection("users").document(userUID).collection("cart").document(cartItems[indexPath].id).setData(cartData[indexPath])
        }
        self.cartItems.removeAll()
        loadData()
    }
    
    @objc func decreaseCount(sender : UIButton){
        let indexPath = sender.tag
        let type : String = cartItems[indexPath].type
        let db = Firestore.firestore()
        
        if(type == "products"){
            var quntity = (Int(cartItems[indexPath].quantity) ?? 0)
            if(quntity <= 1){
                db.collection("users").document(userUID).collection("cart").document(cartItems[indexPath].id).delete() { (err) in
                    if let err = err {
                        print(err)
                    }else{
                        self.showToast("item removed successfully")
                        self.cartItems.removeAll()
                        self.loadData()
                    }
                    
                }
            }else{
                quntity = quntity - 1
                cartData[indexPath]["quantity"] = quntity
                db.collection("users").document(userUID).collection("cart").document(cartItems[indexPath].id).setData(cartData[indexPath])
            }
             
        }else{
            var quntity = (Int(cartItems[indexPath].hours) ?? 0)
            if(quntity <= 1){
                db.collection("users").document(userUID).collection("cart").document(cartItems[indexPath].id).delete() { (err) in
                    if let err = err {
                        print(err)
                    }else{
                        self.showToast("item removed successfully")
                        self.cartItems.removeAll()
                        self.loadData()
                    }
                    
                }
            }else{
                quntity = quntity - 1
                cartData[indexPath]["hours"] = quntity
                db.collection("users").document(userUID).collection("cart").document(cartItems[indexPath].id).setData(cartData[indexPath])
            }
            
        }
        self.cartItems.removeAll()
        loadData()
    }
    
    @IBAction func reserveOrder(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "ReserveStoryboard", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "ReserveViewController") as! ReserveViewController
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
    
    @IBAction func confirmOrder(_ sender: Any) {
        let date = Date()
        let storyBoard : UIStoryboard = UIStoryboard(name: "CheckoutStoryboard", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.orderDate = date
        self.present(secondViewController, animated:true, completion:nil)
    }
    
    
    @IBAction func onBackPressed(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
    
}
