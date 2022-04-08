//
//  UserProfileViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-30.
//

import UIKit
import Firebase
import FirebaseAuth

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var logoutBtn: UIImageView!
    
    var userId : String = ""
    var name : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        userId = Auth.auth().currentUser?.uid ?? "userId"
        
        let singoutGasture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        logoutBtn.isUserInteractionEnabled = true
        logoutBtn.addGestureRecognizer(singoutGasture)
        
        LoadData()
    }
    
    func LoadData(){
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument{ snapshot, error in
            if error != nil {
                // ERROR
            }
            else {
                self.name = snapshot?.get("firstName") as? String ?? "productname"
                let email = snapshot?.get("email") as? String ?? "Description"
                
                self.userName.text = self.name
                self.userEmail.text = email
                
            }
        }
    }
    
    @IBAction func UpdateProfile(_ sender: Any) {
        let db = Firestore.firestore()
        let updatedName : String = userName.text ?? ""
        let emailValue : String = userEmail.text ?? ""
        let oldPwValue : String = oldPassword.text ?? ""
        let newPwValue : String = newPassword.text ?? ""
        let confPwValue : String = confirmPassword.text ?? ""
        
        if updatedName != self.name && !updatedName.isEmpty{
            db.collection("users").document(userId).getDocument{ snapshot, error in
                if error != nil {
                    // ERROR
                }
                else {
                    snapshot!.reference.updateData([
                        "firstName": updatedName
                                ])
                    self.showToast("Name Upadted Sucessfully!")
                    
                }
            }
        }
        if !oldPwValue.isEmpty && !newPwValue.isEmpty && newPwValue == confPwValue {
            
            let user = Auth.auth().currentUser
            let eMail = EmailAuthProvider.credential(withEmail: emailValue, password: oldPwValue)

            // Prompt the user to re-provide their sign-in credentials
            
            user?.reauthenticate(with: eMail, completion: { (result, error) in
                if let err = error {
                   //..read error message
                } else {
                   //.. go on
                    
                      Auth.auth().currentUser?.updatePassword(to: newPwValue) { _ in (error)
                          if error != nil {
                          // An error happened.
                              print(error)
                        } else {
                            self.showToast("Password updated SuccessFully")
                        }
                      }
                    
                }
                
             })
                        
        }
        
    }
    
    @IBAction func GotoMainScreen(_ sender: Any){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
        
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
        {
        _ = tapGestureRecognizer.view as! UIImageView
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
        
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.showToast("Logout Successfully")
        self.present(secondViewController, animated:true, completion:nil)

    }
}
