//
//  ShoppingTableViewController.swift
//  BoringSSL-GRPC
//
//  Created by Pedro Lopes on 23/03/19.
//  Copyright © 2019 Pedro Lopes. All rights reserved.
//

import UIKit
import Firebase


class ShoppingTableViewController: UITableViewController {
    
    let collection = "shoppingList"
    var firestoreListener: ListenerRegistration!
    var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        var firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    var shoppingList: [ShoppingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Auth.auth().currentUser?.displayName
        listItems()
    }
    
    func listItems() {
        
        firestoreListener = firestore.collection(collection).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            if error != nil {
                print(error!)
            }
            
            guard let snapshot = snapshot else {return}
            print("Total de mudanças: ", snapshot.documentChanges.count)
            
            
            if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                self.showItems(snapshot: snapshot)
            }
        }
    }
    
    func showItems(snapshot: QuerySnapshot) {
        
        shoppingList.removeAll()
        for document in snapshot.documents{
            if let newItem = FirestoreConvert().fromDocument(document) {
                shoppingList.append(newItem)
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let shoppintItem = shoppingList[indexPath.row]
        cell.textLabel?.text = shoppintItem.name
        cell.detailTextLabel?.text = "\(shoppintItem.quantity)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let item = shoppingList[indexPath.row]
            
            firestore.collection(collection).document(item.id).delete()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = shoppingList[indexPath.row]
        addItem(item)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @IBAction func add(_ sender: Any) {
        self.addEdit()
    }
    
    func addEdit(shoppingItem: ShoppingItem? = nil) {
        
        let title = shoppingItem == nil ? "Adicionar" : "Editar"
        let message = shoppingItem == nil ? "adicionado" : "editado"
        
        let alert = UIAlertController(title: title, message: "Insira os dados do item a ser \(message)", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome"
            textField.text = shoppingItem?.name
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Quantidade"
            textField.text = shoppingItem?.quantity.description
            textField.keyboardType = .numberPad
        }
        
        let addAction = UIAlertAction(title: title, style: .default, handler: { (_) in
            
            guard let name = alert.textFields?.first?.text,
                let quantity = alert.textFields?.last?.text,
                !name.isEmpty, !quantity.isEmpty else {return}
            
            var item = shoppingItem ?? ShoppingItem()
            item.name = name
            item.quantity = Int(quantity) ?? 1
            
            self.addItem(item)
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addItem(_ item: ShoppingItem) {
        
        let doc = FirestoreConvert().toDocument(item)
        
        if item.id.isEmpty{
            firestore.collection(collection).addDocument(data: doc, completion: {(error) in
                if error != nil {
                    print (error!)
                }
            })
        } else {
            firestore.collection(collection).document(item.id).updateData(doc) { error in
                if error != nil {
                    print (error!)
                }
            }
        }
    }
}
