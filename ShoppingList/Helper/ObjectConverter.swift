//
//  ObjectConverter.swift
//  ShoppingList
//
//  Created by Usuário Convidado on 23/03/19.
//  Copyright © 2019 FIAP. All rights reserved.
//

import Foundation
import Firebase

class FirestoreConvert {
    
    func fromDocument(_ document: QueryDocumentSnapshot) -> ShoppingItem? {
        
        let data = document.data()
        if let name = data["name"] as? String, let quantity = data["quantity"] as? Int {
            let shoppintItem = ShoppingItem(name: name, quantity: quantity, id: document.documentID)
            return shoppintItem
        }
        return nil
    }
    
    func toDocument(_ item: ShoppingItem) -> [String: Any] {
        
        let data: [String: Any] = [
            "name" : item.name,
            "quantity" : item.quantity
        ]
        
        return data
    }
}
