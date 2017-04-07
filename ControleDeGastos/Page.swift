//
//  Page.swift
//  ControleDeGastos
//
//  Created by Tamara Martinelli de Campos on 06/04/17.
//  Copyright © 2017 Instituto de Pesquisas Eldorado. All rights reserved.
//

import UIKit

class Page: NSObject {
    
    var monthLabel: String
    
    public var items:[Item] = [Item(type: "", value: 0.0, category: "", description: "", payment: "", date: Date(), ifRepeats: 0, when: "", replayNumber: 0)]
    
    override init() {
        
        self.monthLabel = ""
        
        super.init()
    }
    
    public func setItems(_ items:[Item]){
        self.items = items
    }
    
    
    init(month title: String) {
        
        self.monthLabel  = title
        
        super.init()
        
//        for str in ["Alugel","Salario","Luz","Gás","Tv a Cabo"] {
//            
//            let item = Item(type: "Despesa", value: 20.0, category: "Alimentação", description: str + " de " + title, payment: "Dinheiro", date: Date(), ifRepeats: 1, when: "Mensalmente", replayNumber: 4)
//            
//            items.append(item)
//        }
        
        
    }


}
