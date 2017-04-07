//
//  DatabaseManager.swift
//  ControleDeGastos
//
//  Created by Tamara Martinelli de Campos on 06/04/17.
//  Copyright © 2017 Instituto de Pesquisas Eldorado. All rights reserved.
//

import UIKit
import CloudKit

class DatabaseManager: NSObject {
    
    static let shared = DatabaseManager()
    let publicDataBase = CKContainer.default().publicCloudDatabase

    private var pages = [Page]()
    
    private override init() {
        super.init()
        
        for str in ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set", "Out", "Nov", "Dez"] {
            
            let page = Page(month: str)
            
            pages.append(page)
        }
        
    }
    
    
    /// Page for month
    ///
    /// - Parameter forMonth: 1 to 12 with the month number
    func page(forMonth month:Int) -> Page?
    {
        guard month > 0 && month <= 12 else {
            return nil
        }
        
        return pages[month - 1] // pages index starts at 0
        
    }
    
    public func loadData(monthIndex:Int, completionHandler: @escaping ([Item]) -> Swift.Void) {
        var soughtItems = [Item]()
        
        let firstDate = firstDateOf(month: monthIndex)
        let lastDate = lastDateOf(month: monthIndex)
        
        let dataPublicDataBase = CKContainer.default().publicCloudDatabase
        
        //in order to see all the data, true
        let predicate = NSPredicate(format: "(occurrenceDate >= %@) AND (occurrenceDate <= %@)", firstDate as CVarArg, lastDate as CVarArg)
        
        let query = CKQuery(recordType: "Item", predicate: predicate)
        
        //query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        dataPublicDataBase.perform(query, inZoneWith: nil) { (results, error) in
            
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                for record in results! {
                    let type = record.value(forKey: "itemsType") as! String
                    let value = record.value(forKey: "value") as! Double
                    let category = record.value(forKey: "categoryType") as! String
                    let description = record.value(forKey: "description") as! String
                    let payment = record.value(forKey: "paymentType") as! String
                    let occurrenceDate = record.value(forKey: "occurrenceDate") as! Date
                    let ifRepeats = record.value(forKey: "ifRepeats") as! Int
                    let when = record.value(forKey: "frequencyType") as! String
                    let replayNumber = record.value(forKey: "replayNumber") as! Int
                    
                    
                    soughtItems.append(
                        Item(type: type,
                             value: value,
                             category: category,
                             description: description,
                             payment: payment,
                             date: occurrenceDate,
                             ifRepeats: ifRepeats,
                             when: when,
                             replayNumber: replayNumber)
                    )
                    
                }
            }
            OperationQueue.main.addOperation ({ () -> Void in
                completionHandler(soughtItems)
            })

        }
    }
    
    public func updateSaldoWithNewItem (_ value:Double, _ type:String){
        let dataPublicDataBase = CKContainer.default().publicCloudDatabase
        
        //in order to see all the data, true
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "UserData", predicate: predicate)
        
        //query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        dataPublicDataBase.perform(query, inZoneWith: nil) { (results, error) in
            
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                if results!.count > 0{
                    let userData = (results?[0])! as CKRecord
                    var saldo = userData.value(forKey: "Saldo") as! Double
                    
                    if(type == "Despesa"){
                        saldo = saldo - value
                    } else if (type == "Receita"){
                        saldo = saldo + value
                    }
                    
                    userData.setObject(saldo as CKRecordValue?, forKey: "Saldo")
                    dataPublicDataBase.save(userData, completionHandler: { (result, error) in
                        if error != nil{
                            print("error-->" + error.debugDescription)
                        } else {
                            print("Saldo atualizado")
                        }
                    })
                }
            }
        }
        
    }
    
    public func addNewItem(_ item:Item, completionHandler: @escaping () -> Swift.Void){
        let newItem = CKRecord(recordType: "Item")
        
        newItem.setObject(item.type as CKRecordValue?, forKey: "itemsType")
        newItem.setObject(item.value as CKRecordValue?, forKey: "value")
        newItem.setObject(item.category as CKRecordValue?, forKey: "categoryType")
        newItem.setObject(item.description as CKRecordValue?, forKey: "description")
        newItem.setObject(item.date as CKRecordValue?, forKey: "occurrenceDate")
        newItem.setObject(item.payment as CKRecordValue?, forKey: "paymentType")
        newItem.setObject(item.when as CKRecordValue?, forKey: "frequencyType")
        newItem.setObject(item.ifRepeats as CKRecordValue?, forKey: "ifRepeats")
        newItem.setObject(item.replayNumber as CKRecordValue?, forKey: "replayNumber")
        
        self.updateSaldoWithNewItem(item.value, item.type)
        
        //Uploading to CloudKit
        let publicData = CKContainer.default().publicCloudDatabase
        
        publicData.save(newItem, completionHandler: {(record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Error --->" + (error!.localizedDescription))
            }
            
            OperationQueue.main.addOperation ({ () -> Void in
                completionHandler()
            })
        })
        
    }
    
    func firstDateOf(month: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = month
        
        let userCalendar = Calendar.current
        let firstDate = userCalendar.date(from: dateComponents)
            
        return firstDate!
    }
    
    func lastDateOf(month: Int) -> Date {
        return firstDateOf(month:month+1) - 1
    }
    
    public func getAMonth(monthIndex:Int)-> [Item]{
        var soughtItems = [Item]()
        
        let firstDate = firstDateOf(month: monthIndex)
        let lastDate = lastDateOf(month: monthIndex)
        
        let dataPublicDataBase = CKContainer.default().publicCloudDatabase
        
        //in order to see all the data, true
        let predicate = NSPredicate(format: "(occurrenceDate >= %@) AND (occurrenceDate <= %@)", firstDate as CVarArg, lastDate as CVarArg)
        
        let query = CKQuery(recordType: "Item", predicate: predicate)
        
        //query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        dataPublicDataBase.perform(query, inZoneWith: nil) { (results, error) in
            
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                for record in results! {
                    let type = record.value(forKey: "itemsType") as! String
                    let value = record.value(forKey: "value") as! Double
                    let category = record.value(forKey: "categoryType") as! String
                    let description = record.value(forKey: "description") as! String
                    let payment = record.value(forKey: "paymentType") as! String
                    let occurrenceDate = record.value(forKey: "occurrenceDate") as! Date
                    let ifRepeats = record.value(forKey: "ifRepeats") as! Int
                    let when = record.value(forKey: "frequencyType") as! String
                    let replayNumber = record.value(forKey: "replayNumber") as! Int
                        
                        
                    soughtItems.append(
                        Item(type: type,
                            value: value,
                            category: category,
                            description: description,
                            payment: payment,
                            date: occurrenceDate,
                            ifRepeats: ifRepeats,
                            when: when,
                            replayNumber: replayNumber)
                    )
                }
            }
        }
        return soughtItems
    }
    
    public func getSaldo(completionHandler:@escaping (Double?)->Void) -> Double {
        let dataPublicDataBase = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserData", predicate: predicate)
        var saldo:Double = -1
        
        dataPublicDataBase.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                print("Error" + error.debugDescription)
                completionHandler(nil)
            } else {
                if results!.count > 0 {
                    let userData = (results?[0])! as CKRecord
                    saldo = userData.value(forKey: "Saldo") as! Double
                    completionHandler(saldo)
                }
            }
        }
        return saldo
        
    }
    
    func updateSaldo (completionHandler:@escaping ()->Void) {
        let dataPublicDataBase = CKContainer.default().publicCloudDatabase
        
        //in order to see all the data, true
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "UserData", predicate: predicate)
        
        //query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        dataPublicDataBase.perform(query, inZoneWith: nil) { (results, error) in
            
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                if results!.count > 0{
                    let userData = (results?[0])! as CKRecord
                    var saldo = userData.value(forKey: "Saldo") as! Double
                    
                    let queryCountingSaldo = CKQuery(recordType: "Item", predicate: predicate)
                    
                    dataPublicDataBase.perform(queryCountingSaldo, inZoneWith: nil, completionHandler: { (results2, error2) in
                        if error2 != nil{
                            print("Error" + error2.debugDescription)
                        } else {
                            for record in results2!{
                                let type = record.value(forKey: "itemsType") as! String
                                let value = record.value(forKey: "value") as! Double
                                
                                if(type == "Despesa"){
                                    saldo = saldo - value
                                } else if (type == "Receita"){
                                    saldo = saldo + value
                                }
                            }
                            
                            userData.setObject(saldo as CKRecordValue?, forKey: "Saldo")
                            self.publicDataBase.save(userData, completionHandler: { (result, error) in
                                if error != nil{
                                    print("error-->" + error.debugDescription)
                                } else {
                                    print("Saldo atualizado")
                                    completionHandler()
                                }
                            })
                        }
                    })
                } else {
                    //The user doesn't have a UserData field yet
                    let userData = CKRecord(recordType: "UserData")
                    
                    userData.setObject(Double(0.0) as CKRecordValue?, forKey: "Saldo")
                    self.publicDataBase.save(userData, completionHandler: { (result, error) in
                        if error != nil{
                            print("error-->" + error.debugDescription)
                        } else {
                            print("Saldo inicializado")
                        }
                    })
                }
            }
        }
    }
}
