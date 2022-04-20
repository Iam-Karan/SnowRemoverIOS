//
//  AboutUsViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-29.
//

import UIKit
import Firebase

class AboutUsViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var feedback: UITextView!
    
    var nameText : String = ""
    var emailText : String = ""
    var feedbackText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func sendFeedback(_ sender: Any) {
        nameText = name.text ?? ""
        emailText = email.text ?? ""
        feedbackText = feedback.text ?? ""
        
        if(!nameText.isEmpty && !emailText.isEmpty && !feedbackText.isEmpty){
            let data = ["name" : nameText, "email" : emailText, "message": feedbackText, "read" : false] as [String : Any]
            Firestore.firestore().collection("contactMessages").document().setData(data) { error in
                if error != nil {
                    
                }else{
                    self.showToast("Message Sent!")
                    self.name.text = ""
                    self.email.text = ""
                    self.feedback.text = "Description"
                }
            }
        }
        
    }
}
