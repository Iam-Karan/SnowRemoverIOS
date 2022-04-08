//
//  OrderViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-29.
//

import UIKit
import Firebase
import FirebaseAuth

class OrderViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userBtn: UIImageView!
    @IBOutlet weak var cartBtn: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid != nil {

           loadData()
            let singinGasture = UITapGestureRecognizer(target: self, action: #selector(gotoUserProfileTapped(tapGestureRecognizer:)))
            userBtn.isUserInteractionEnabled = true
            userBtn.addGestureRecognizer(singinGasture)

        }else{
            let singinGasture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            userBtn.isUserInteractionEnabled = true
            userBtn.addGestureRecognizer(singinGasture)
        }
        
        
    }
    
    func loadData(){
        let userID = Auth.auth().currentUser!.uid
        
        print(userID)
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).getDocument{ snapshot, error in
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
    

}
