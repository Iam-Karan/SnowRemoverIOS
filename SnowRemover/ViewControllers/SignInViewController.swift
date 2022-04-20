//
//  SignInViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-30.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorText.isHidden = true
        
    }
    
    @IBAction func SignIn(_ sender: Any) {
        let emailValue = email.text ?? ""
        let passwordValue = password.text ?? ""
        
        if !emailValue.isEmpty || !passwordValue.isEmpty {
            
            Auth.auth().signIn(withEmail: emailValue, password: passwordValue) { (result, error) in
                    if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                        self.errorText.text = "Invalid email or password"
                        self.errorText.isHidden = false
                    } else {
                        
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

                        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
                        
                        secondViewController.modalPresentationStyle = .fullScreen
                        secondViewController.showToast("Login Successfully!")
                        self.present(secondViewController, animated:true, completion:nil)
                    }
                }
        }
        if(emailValue.isEmpty){
            self.errorText.text = "Email must not be empty"
            self.errorText.isHidden = false
            self.email.layer.borderWidth = 1
            self.email.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        if(passwordValue.isEmpty){
            self.errorText.text = "Password must not be empty"
            self.errorText.isHidden = false
            self.password.layer.borderWidth = 1
            self.password.layer.borderColor = CGColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        }
        
        
    }
    
    
    
    @IBAction func GotoSignUp(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "SignUpStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
       
        self.present(secondViewController, animated:true, completion:nil)
    }
    
}
