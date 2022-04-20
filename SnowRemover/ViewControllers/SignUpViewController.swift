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
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorText.isHidden = true
    }
    
    @IBAction func SignUp(_ sender: Any) {
        
        let name = nameText.text ?? ""
        let email = emailText.text ?? ""
        let password = passwordText.text ?? ""
        let confirmPasword = confrimPasswordText.text ?? ""
        
        if !name.isEmpty || !email.isEmpty || !password.isEmpty || !confirmPasword.isEmpty || password == confirmPasword{
            
            Auth.auth().createUser(withEmail: email , password: password ) {(authResult, error) in
                        if let user = authResult?.user {
                            let userUID = Auth.auth().currentUser?.uid
                            
                            let data = ["uid" : userUID, "email" : email, "firstName": name, "type" : "Customer"]
                            
                            print(user)
                            
                            Firestore.firestore().collection("users").document(userUID!).setData(data) { error in
                                        if error != nil {
                                           
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
                           
                        }
                    }
        }
        if(name.isEmpty){
            self.errorText.text = "Name must not be empty"
            self.errorText.isHidden = false
            self.nameText.layer.borderWidth = 1
            self.nameText.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        if(email.isEmpty){
            self.errorText.text = "Email must not be empty"
            self.errorText.isHidden = false
            self.emailText.layer.borderWidth = 1
            self.emailText.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        if(password.isEmpty){
            self.errorText.text = "Password must not be empty"
            self.errorText.isHidden = false
            self.passwordText.layer.borderWidth = 1
            self.passwordText.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        if(password != confirmPasword){
            self.errorText.text = "Password and confirm password is not match"
            self.errorText.isHidden = false
            self.passwordText.layer.borderWidth = 1
            self.passwordText.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
            self.confrimPasswordText.layer.borderWidth = 1
            self.confrimPasswordText.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
    }
    
    @IBAction func GotoSignIn(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "SignInStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated:true, completion:nil)
    }
}
