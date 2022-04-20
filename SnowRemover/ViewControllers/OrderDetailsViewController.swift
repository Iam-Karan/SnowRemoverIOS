//
//  OrderDetailsViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-18.
//

import UIKit
import Firebase
import FirebaseAuth

class OrderDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var orderId = String()
    @IBOutlet weak var oId: UILabel!
    @IBOutlet weak var oDate: UILabel!
    @IBOutlet weak var oAddress: UILabel!
    @IBOutlet weak var oPrice: UILabel!
    @IBOutlet weak var oFeedback: UITextView!
    @IBOutlet weak var oProducts: UITableView!
    @IBOutlet weak var errorText: UILabel!
    
    var userUID : String = ""
    var orders : [OrderItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorText.isHidden = true
        if Auth.auth().currentUser != nil {
            oProducts.dataSource = self
            oProducts.delegate = self
            
            userUID = Auth.auth().currentUser?.uid ?? ""
            loadData()
        }
        
        oFeedback.layer.borderWidth = 2
        oFeedback.layer.borderColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        
        
    }
    
    func loadData(){
        let db = Firestore.firestore()
        
        db.collection("users").document(userUID).collection("order").document(orderId).getDocument{ [self] (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                let docId = snapshot?.documentID
                let timeStamp = snapshot?.get("reservation_datetime") as? Timestamp ?? nil
                let date: Date = timeStamp?.dateValue() ?? Date()
                print(date)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .medium
                let dateString  : String = dateFormatter.string(from: date as Date)
                let total: Double = snapshot?.get("total") as? Double ?? 0
                let totalString : String = String(format: "%.2f", total)
                let addressString : String = snapshot?.get("address") as! String
                let items : [[String : Any]] = snapshot?.get("items")  as! [[String : Any]]
                for item in items {
                    let id : String = item["id"] as! String
                    let name : String = item["name"]  as! String
                    let price : Double = item["price"] as! Double
                    let priceString : String = String(price)
                    let type : String = item["type"] as! String
                    let quantity : String = item["quantity"] as! String
                    let hour : String = item["hour"] as! String
                    let imageUrl : String = item["imageUrl"] as! String
                    
                    orders.append(OrderItemModel(id: id, name: name, imageUrl: imageUrl, type: type, hours: hour, quantity: quantity, price: priceString))
                    self.oProducts.reloadData()
                }
                oId.text = docId
                oDate.text = dateString
                oPrice.text = "$"+totalString
                oAddress.text = addressString
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemTableViewCell", for: indexPath) as! OrderItemTableViewCell
        
        cell.setData(with: orders[indexPath.row])
        
        let separatorLineView = UIView(frame: CGRect(x: 0, y: 0, width: 380, height: 3))
        /// change size as you need.
        separatorLineView.backgroundColor = UIColor.white
        // you can also put image here
        cell.contentView.addSubview(separatorLineView)
        
        return cell
    }
    
    
    @IBAction func submitFeedback(_ sender: Any) {
        let feedbackValue : String = oFeedback.text ?? ""
        let db = Firestore.firestore()
        if(!feedbackValue.isEmpty){
            db.collection("orders").document(orderId).getDocument{ snapshot, error in
                if error != nil {
                    // ERROR
                }
                else {
                    snapshot!.reference.updateData([
                        "feedback": feedbackValue
                                ])
                    self.showToast("Feedback send Sucessfully!")
                    self.oFeedback.text = "Feedback"
                    
                }
            }
        }else{
            self.errorText.isHidden = false
            self.oFeedback.layer.borderWidth = 2
            self.oFeedback.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
    }
    
    @IBAction func gotoHomeScren(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
}
