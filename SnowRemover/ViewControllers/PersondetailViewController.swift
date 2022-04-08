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
    
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personDescription: UILabel!
    @IBOutlet weak var personPrice: UILabel!
    @IBOutlet weak var personAge: UILabel!
    
    @IBOutlet weak var personImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        LoadData()
    }
    
    func LoadData(){
        let db = Firestore.firestore()
        
        db.collection("person").document(personId).getDocument{ snapshot, error in
            if error != nil {
                // ERROR
            }
            else {
                let name = snapshot?.get("name") as? String ?? "productname"
                let description = snapshot?.get("description") as? String ?? "Description"
                let price = snapshot?.get("Price") as? String ?? "300"
                let imageUrl = snapshot?.get("imageurl") as? String ?? "Url"
                let age = snapshot?.get("age") as? Int ?? 20
                let ageVlue = String(age)
                
                let gsReference = Storage.storage().reference(forURL:  "gs://snowremovalapp-ac3d9.appspot.com/personimages/"+imageUrl)
                gsReference.downloadURL(completion: { (url, error) in
                    if ((url?.isFileURL) != nil){
                        ImageService.downloadImage(withURL: url!) { image in
                            self.personImage.image = image
                        }
                    }
                })
                
                self.personName.text = name
                self.personDescription.text = description
                self.personPrice.text = "$"+price
                self.personAge.text = ageVlue
                
            }
        }
    }
    
    
    @IBAction func AddToCart(_ sender: Any) {
    }
    
    @IBAction func GotoHomeScreen(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
        
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
}
