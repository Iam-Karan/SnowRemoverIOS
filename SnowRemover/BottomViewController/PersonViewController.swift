//
//  PersonViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-29.
//

import UIKit
import Firebase
import FirebaseFirestore
import CloudKit


class PersonViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var personCollection: UICollectionView!
    var products : [ProductModel] = []
    var userUID : String = ""
    var copyProducts : [ProductModel] = []
    var favProductIds : [String] = []
    
    @IBOutlet weak var dropDownMenu: UIImageView!
    
    @IBOutlet weak var selectMenu: UIButton!
    
    @IBOutlet var menuItems: [UIButton]!
    
    @IBOutlet weak var searchPerson: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchPerson.delegate = self
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid ?? ""
            getFavourite()
        }
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        personCollection.collectionViewLayout = layout
        personCollection.register(ProductCollectionViewCell.nib(), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        loadData();
        personCollection.delegate = self
        personCollection.dataSource = self
        
        selectMenu.layer.cornerRadius = selectMenu.frame.height / 2
        selectMenu.isHidden = true
        selectMenu.alpha = 0
        menuItems.forEach { (btn) in
            btn.layer.cornerRadius = btn.frame.height / 2
            btn.isHidden = true
            btn.alpha = 0
        }
        
        let menuGasture = UITapGestureRecognizer(target: self, action: #selector(openDropDownMenu(tapGestureRecognizer:)))
        dropDownMenu.isUserInteractionEnabled = true
        dropDownMenu.addGestureRecognizer(menuGasture)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        personCollection.deselectItem(at: indexPath, animated: true)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "PersonDetailStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "PersondetailViewController") as! PersondetailViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.personId = products[indexPath.row].id
        self.present(secondViewController, animated:true, completion:nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = personCollection.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        
        cell.layer.cornerRadius = 15.0
        cell.layer.borderWidth = 0.0
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 1
        cell.layer.masksToBounds = true
        
        cell.setData(with: products[indexPath.row])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width - 20 * 2) / 2
        let height = width * 1
        
        return CGSize(width: width, height: height)
    }
    
    func loadData(){
        let db = Firestore.firestore()
        
        db.collection("person").getDocuments(){ [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let docId = document.documentID
                    let nameValue: String = data["name"] as? String ?? ""
                    let priceValue: String = data["Price"] as? String ?? ""
                    let priceDouble : Double = Double(priceValue) ?? 0
                    let imageUrlValue: String = data["imageurl"] as? String ?? ""
                    let count : Int = 1
                    let type : String = "person"
                    let isArchive : Bool = data["archive"] as? Bool ?? false
                    if(!isArchive){
                        products.append(ProductModel(id: docId, name: nameValue, price: priceDouble, imageurl: imageUrlValue, type: type, count: count))
                    }
                }
                self.copyProducts.append(contentsOf: products)
                self.personCollection.reloadData()
            }
        }
        
    }
    
    func getFavourite(){
        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection("favorite").getDocuments(){ [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id : String = document.documentID
                    print(id)
                    favProductIds.append(id)
                }
            }
        }
    }
    
    @IBAction func selectMenuAction(_ sender: Any) {
        menuItems.forEach { (btn) in
            UIView.animate(withDuration: 0.3) {
                btn.isHidden = !btn.isHidden
                btn.alpha = btn.alpha == 0 ? 1 : 0
                btn.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func selectMenuItemAction(_ sender: UIButton) {
        let value : String = sender.titleLabel?.text ?? ""
        products.removeAll()
        if(value == "Available"){
            for product in copyProducts {
                if(product.count > 0){
                    products.append(product)
                }
            }
        }
        if(value == "Low To High"){
            products.append(contentsOf: copyProducts.sorted(by: { $0.price < $1.price }))
        }
        if(value == "High To Low"){
            products.append(contentsOf: copyProducts.sorted(by: { $0.price > $1.price }))
        }
        if(value == "Favorite"){
            for product in copyProducts {
                if(favProductIds.contains(product.id)){
                    self.products.append(product)
                }
            }
        }
        self.personCollection.reloadData()
    }
    
    @objc func openDropDownMenu(tapGestureRecognizer: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.3) {
            self.selectMenu.isHidden = !self.selectMenu.isHidden
            self.selectMenu.alpha = self.selectMenu.alpha == 0 ? 1 : 0
            self.selectMenu.layoutIfNeeded()
            self.menuItems.forEach { (btn) in
                UIView.animate(withDuration: 0.3) {
                    btn.isHidden = true
                    btn.alpha = 0
                    btn.layoutIfNeeded()
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        products.removeAll()
        if(searchText.isEmpty){
            products.append(contentsOf: copyProducts)
        }else{
            for product in copyProducts {
                if(product.name.uppercased().contains(searchText.uppercased())){
                    products.append(product)
                }
            }
        }
        self.personCollection.reloadData()
    }

}
