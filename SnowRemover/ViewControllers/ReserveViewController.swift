//
//  ReserveViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-04-13.
//

import UIKit

class ReserveViewController: UIViewController {

    
    @IBOutlet weak var reserveDate: UITextField!
    @IBOutlet weak var reserveTime: UITextField!
    
    var dateValue : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onClickDoneButton))
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        reserveDate.inputAccessoryView = toolBar
        reserveTime.inputAccessoryView = toolBar
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(timeChanged(datePicker:)), for: UIControl.Event.valueChanged)
        timePicker.frame.size = CGSize(width: 0, height: 300)
        timePicker.preferredDatePickerStyle = .wheels
        
        
        reserveDate.inputView = datePicker
        reserveDate.text = formatDate(date: Date())
        reserveTime.inputView = timePicker
        reserveTime.text = formatTime(date: Date())
    }
    
    
    @objc func dateChanged(datePicker: UIDatePicker){
        reserveDate.text = formatDate(date: datePicker.date)
    }

    @objc func timeChanged(datePicker: UIDatePicker){
        reserveTime.text = formatTime(date: datePicker.date)
    }
    
    @objc func onClickDoneButton() {
        self.view.endEditing(true)
    }

    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter.string(from: date)
    }
    
    func formatTime(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    @IBAction func confirmOrder(_ sender: Any) {
        dateValue = (reserveDate.text ?? "")! + " " + (reserveTime.text ?? "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy HH:mm"
        let date = dateFormatter.date(from: dateValue)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "CheckoutStoryboard", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.orderDate = date ?? Date()
        self.present(secondViewController, animated:true, completion:nil)
        
    }
    

    @IBAction func backButton(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "CartStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        
        self.present(secondViewController, animated:true, completion:nil)
    }
}
