//
//  NewItemViewController.swift
//  ControleDeGastos
//
//  Created by Julianny Favinha on 3/31/17.
//  Copyright © 2017 Instituto de Pesquisas Eldorado. All rights reserved.
//

import UIKit
import CloudKit

class NewItemViewController: UIViewController, KPDropMenuDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // INICIO MENU CATEGORIA
    @IBOutlet weak var dropMenu: KPDropMenu!
    var dropMenuSelected:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = 1000
     
        dropMenu.title = "Selecione"
        dropMenu.items = ["Sem categoria", "Alimentação", "Aluguel", "Farmácia", "Lazer", "Salário", "Saúde", "Telefonia", "Transporte", "Vestuário"]
        dropMenu.itemsIDs = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        dropMenu.itemsFont = UIFont(name: "Helvetica-Regular", size: 12.0)
        dropMenu.titleTextAlignment = .center
        
        //dropMenu.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewItemViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.dismissKeyboard()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didShow( _ dropMenu: KPDropMenu!) {
        print("didShow")
    }
    
    func didHide(_ dropMenu: KPDropMenu!) {
        print("didHide")
    }
    
    func didSelectItem(_ dropMenu: KPDropMenu!, at atIntedex: Int32) {
        
        if (dropMenu == self.dropMenu) {
            print(atIntedex)
            print("\(dropMenu.items[Int(atIntedex)]), with TAG: \(dropMenu.tag)")
        }
        
        dropMenuSelected = Int(atIntedex)
    }
    
    func getCategoryName(_ index:Int) -> String{
        return String(describing: dropMenu.items[index])
    }
    
    // FIM MENU CATEGORIA
    
    /* 0 -> Despesa
     1 -> Receita */
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    /* 0 -> Dinheiro
     1 -> Crédito
     2 -> Débito */
    @IBOutlet weak var paymentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var replaySwitch: UISwitch!
    
    /* 0 -> Semanalmente
     1 -> Mensalmente */
    @IBOutlet weak var whenSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var replayNumberTextField: UITextField!
    
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var replayNumberLabel: UILabel!
    
    
    @IBAction func savePressed(_ sender: Any) {
        var itemsType = String()
        var value = Double()
        var description = String()
        var paymentType = String()
        var categoryType = String()
        var occurrenceDate = Date()
        var frequencyType = String()
        var ifRepeats = Int()
        var replayNumber = Int()
        
        
        if(typeSegmentedControl.selectedSegmentIndex == 0){
            itemsType = "Despesa"
        } else {
            itemsType = "Receita"
        }
        
        if let value2 = valueTextField.text {
            value = Double(value2)!
        } else {
            value = Double(-1)
        }
        
        if let description2 = descriptionTextField.text {
            description = description2
        } else {
            description = "No description"
        }
        
        if paymentSegmentedControl.selectedSegmentIndex == 0 {
            paymentType = "Dinheiro"
        } else if paymentSegmentedControl.selectedSegmentIndex == 1{
            paymentType = "Crédito"
        } else {
            paymentType = "Débito"
        }
        
        if dropMenuSelected != -1 {
            categoryType = getCategoryName(dropMenuSelected)
        } else {
            categoryType = "Sem categoria"
        }
        
        let formatDate:Date = datePicker.date
        occurrenceDate = formatDate
        
        if(whenSegmentedControl.selectedSegmentIndex == 0){
            frequencyType = "Semanalmente"
        } else {
            frequencyType = "Mensalmente"
        }
        
        if(replaySwitch.isOn){
            ifRepeats = 1
        } else {
            ifRepeats = 0
        }
        
        if replayNumberTextField.text != nil && !replayNumberTextField.text!.isEmpty {
            replayNumber = Int(replayNumberTextField.text!)!
        } else {
            replayNumber = Int(0)
        }
        
        let item = Item(type: itemsType, value: value, category: categoryType, description: description, payment: paymentType, date: occurrenceDate, ifRepeats: ifRepeats, when: frequencyType, replayNumber: replayNumber)
        
        let manager = DatabaseManager.shared
        
        manager.addNewItem(item, completionHandler: { () in
            self.dismiss(animated: true, completion: nil)
            
            
        })
    }
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var replayLabel: UILabel!
    
    @IBAction func typeValueChanged(_ sender: UISegmentedControl) {
        if typeSegmentedControl.selectedSegmentIndex == 1 {
            scrollView.contentSize.height = 700
            paymentLabel.isHidden = true
            paymentSegmentedControl.isHidden = true
            replayLabel.isHidden = true
            replaySwitch.isOn = false // return default value
            replaySwitch.isHidden = true
            whenLabel.isHidden = true
            whenSegmentedControl.isHidden = true
            replayNumberLabel.isHidden = true
            replayNumberTextField.isHidden = true
        }
        else {
            paymentLabel.isHidden = false
            paymentSegmentedControl.isHidden = false
            replayLabel.isHidden = false
            replaySwitch.isHidden = false
        }
    }
    
    @IBAction func replayValueChanged(_ sender: UISwitch) {
        scrollView.contentSize.height = 1300
        //let cg:CGPoint = CGPoint(x: 0, y: 400)
        if sender.isOn {
            //scrollView.setContentOffset(CGPoint(x: 0 , y: 400), animated: true)
            whenLabel.isHidden = false
            whenSegmentedControl.isHidden = false
            replayNumberLabel.isHidden = false
            replayNumberTextField.isHidden = false
        }
        else {
            scrollView.setContentOffset(CGPoint(x: 0 , y: 0), animated: true)
            whenLabel.isHidden = true
            whenSegmentedControl.isHidden = true
            replayNumberLabel.isHidden = true
            replayNumberTextField.isHidden = true
        }
    }
}
