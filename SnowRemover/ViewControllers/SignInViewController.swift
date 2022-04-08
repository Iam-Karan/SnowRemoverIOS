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
 
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func SignIn(_ sender: Any) {
        let emailValue = email.text ?? ""
        let passwordValue = password.text ?? ""
        
        if !emailValue.isEmpty || !passwordValue.isEmpty {
            
            Auth.auth().signIn(withEmail: emailValue, password: passwordValue) { (result, error) in
                    if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                        print(error)
                        self.showToast("Invalid email or password!")
                    } else {
                        
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

                        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "HomeScreen")
                        
                        secondViewController.modalPresentationStyle = .fullScreen
                        secondViewController.showToast("Login Successfully!")
                        self.present(secondViewController, animated:true, completion:nil)
                    }
                }
        }
        
        
    }
    
    
    @IBAction func GotoSignUp(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "SignUpStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
       
        self.present(secondViewController, animated:true, completion:nil)
    }
    
}
