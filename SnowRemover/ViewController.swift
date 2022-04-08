//
//  ViewController.swift
//  SnowRemover
//
//  Created by Dev Patel on 2022-03-29.
//

import UIKit
import Firebase
import FirebaseFirestore
import CloudKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var productCollection: UICollectionView!
    
    var products : [ProductModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        productCollection.collectionViewLayout = layout
        productCollection.register(ProductCollectionViewCell.nib(), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        loadData();
        productCollection.delegate = self
        productCollection.dataSource = self
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        productCollection.deselectItem(at: indexPath, animated: true)
        let storyBoard : UIStoryboard = UIStoryboard(name: "ProductDetailStoryboard", bundle:nil)

        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
        
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.productId = products[indexPath.row].id
        self.present(secondViewController, animated:true, completion:nil)
        print("on click")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productCollection.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        
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
        
        db.collection("products").getDocuments(){ [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let docId = document.documentID
                    let nameValue: String = data["name"] as? String ?? ""
                    let priceValue: String = data["price_numerical"] as? String ?? ""
                    let imageUrlValue: String = data["main_image"] as? String ?? ""
                    let type : String = "product"
                    
                    products.append(ProductModel(id: docId, name: nameValue, price: priceValue, imageurl: imageUrlValue, type: type))
                }
                self.productCollection.reloadData()
            }
        }
        
    }

}

