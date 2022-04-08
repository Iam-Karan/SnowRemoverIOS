//
//  SignUpViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-30.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confrimPasswordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SignUp(_ sender: Any) {
        
        let name = nameText.text as? String
        let email = emailText.text as? String
        let password = passwordText.text as? String
        let confirmPasword = confrimPasswordText.text as? String
        
        if name!.isEmpty || email!.isEmpty || password!.isEmpty || confirmPasword!.isEmpty || password != confirmPasword{
            self.showToast("Invalid cradential")
        }else{
            Auth.auth().createUser(withEmail: email ?? "email", password: password ?? "password") {(authResult, error) in
                        if let user = authResult?.user {
                            let userUID = Auth.auth().currentUser?.uid
                            
                            let data = ["uid" : userUID, "email" : email, "firstName": name, "type" : "Customer"]
                            
                            print(user)
                            
                            Firestore.firestore().collection("users").document(userUID!).setData(data) { error in
                                        if error != nil {
                                            // ERROR
                                            print(error)
                                        }
                                        else {
                                            // SUCCESSFUL
                                            let storyBoard : UIStoryboard = UIStoryboard(name: "SignInStoryboard", bundle:nil)

                                            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                                            
                                            secondViewController.modalPresentationStyle = .fullScreen
                                            secondViewController.showToast("Sign Up Successfully!")
                                            self.present(secondViewController, animated:true, completion:nil)
                                            
                                        }
                                    }
                            
                        } else {
                            print(error)
                        }
                    }
        }
    }
    
    @IBAction func GotoSignIn(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "SignInStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
}
