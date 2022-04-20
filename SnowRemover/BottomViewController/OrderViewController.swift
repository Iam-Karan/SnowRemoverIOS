//
//  OrderViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-29.
//

import UIKit
import Firebase
import FirebaseAuth

class OrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userBtn: UIImageView!
    @IBOutlet weak var cartBtn: UIImageView!
    @IBOutlet weak var emptyOrder: UIView!
    
    var orders : [OrderModel] = []
    var userUID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            orderTable.dataSource = self
            orderTable.delegate = self
            
            userUID = Auth.auth().currentUser?.uid ?? ""
            loadData()
            loadOrders()
            let singinGasture = UITapGestureRecognizer(target: self, action: #selector(gotoUserProfileTapped(tapGestureRecognizer:)))
            userBtn.isUserInteractionEnabled = true
            userBtn.addGestureRecognizer(singinGasture)

        }else{
            let singinGasture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            userBtn.isUserInteractionEnabled = true
            userBtn.addGestureRecognizer(singinGasture)
        }
        
        let cartGasture = UITapGestureRecognizer(target: self, action: #selector(gotoCartscreen(tapGestureRecognizer:)))
        cartBtn.isUserInteractionEnabled = true
        cartBtn.addGestureRecognizer(cartGasture)
        
    }
    
    func loadData(){
        let db = Firestore.firestore()
        
        db.collection("users").document(userUID).getDocument{ snapshot, error in
            if error != nil {
                // ERROR
            }
            else {
                let userNameValue = snapshot?.get("firstName") as? String ?? "Hi, Users"
                self.userName.text = userNameValue
            }
        }
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        let storyBoard : UIStoryboard = UIStoryboard(name: "SignInStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        
        self.present(secondViewController, animated:true, completion:nil)
        // Your action
    }
    
    @objc func gotoUserProfileTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        let storyBoard : UIStoryboard = UIStoryboard(name: "UserProfileStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        
        self.present(secondViewController, animated:true, completion:nil)
        // Your action
    }
    
    @objc func gotoCartscreen(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        let storyBoard : UIStoryboard = UIStoryboard(name: "CartStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        
        self.present(secondViewController, animated:true, completion:nil)
    }
    
    func loadOrders(){
        let db = Firestore.firestore()
        
        db.collection("users").document(userUID).collection("order").getDocuments(){ [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let docId = document.documentID
                    let timeStamp = data["reservation_datetime"] as? Timestamp ?? nil
                    let date: Date = timeStamp?.dateValue() ?? Date()
                    let total: Double = data["total"] as? Double ?? 0
                    let totalString : String = String(format: "%.2f", total)
                    let items : [[String : Any]] = data["items"]  as! [[String : Any]]
                    let itemCount : String = String(items.count)
                    
                    orders.append(OrderModel(id: docId, name: docId, imageUrl: "", date: date, itemCount: itemCount, price: totalString, btnText: ""))
                    
                }
                if(orders.count > 0){
                    emptyOrder.isHidden = true
                }
                self.orderTable.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderViewCell", for: indexPath) as! OrderViewCell
        
        cell.setData(with: orders[indexPath.row])
        
        let separatorLineView = UIView(frame: CGRect(x: 0, y: 0, width: 380, height: 10))
        /// change size as you need.
        separatorLineView.backgroundColor = UIColor.white
        // you can also put image here
        cell.contentView.addSubview(separatorLineView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        orderTable.deselectRow(at: indexPath, animated: true)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "OrderDetailsStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as! OrderDetailsViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.orderId = orders[indexPath.row].id
        self.present(secondViewController, animated:true, completion:nil)
   }

}
