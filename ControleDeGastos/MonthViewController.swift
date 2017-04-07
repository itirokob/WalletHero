//
//  MonthViewController.swift
//  ControleDeGastos
//
//  Created by Tamara Martinelli de Campos on 06/04/17.
//  Copyright © 2017 Instituto de Pesquisas Eldorado. All rights reserved.
//

import UIKit

class MonthViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var categoryIcon: UIImageView!
    var refresh: UIRefreshControl!
    let manager = DatabaseManager.shared
    var month: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(MonthViewController.loadDataRefresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresh)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let page = DatabaseManager.shared.page(forMonth: month)
        
        monthLabel.text = page?.monthLabel
    }
    
    func updateSaldoLabel(){
        let saldo = manager.getSaldo { (saldo) in
            if let saldoCorrente = saldo {
                OperationQueue.main.addOperation({
                    if saldoCorrente < 0 {
                        self.saldoLabel.text = "-R$\(-1*saldoCorrente)"
                    } else {
                        self.saldoLabel.text = "R$\(saldoCorrente)"
                    }
                })
            }
        }
    }
    
    func loadData(){
        self.activityIndicator.startAnimating()
        let currentMonth = DatabaseManager.shared.page(forMonth: month)
        
        manager.loadData(monthIndex: self.month, completionHandler: { (items) in
            currentMonth?.setItems(items)
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
            self.tableView.isHidden = false
            self.refresh.endRefreshing()
        })
        updateSaldoLabel()
        
    }
    
    func loadDataRefresh(){
        let currentMonth = DatabaseManager.shared.page(forMonth: self.month)

        manager.loadData (monthIndex:self.month, completionHandler: { (items) in
            
            currentMonth?.setItems(items)
            self.tableView.reloadData()
            self.tableView.isHidden = false
            self.refresh.endRefreshing()
        })
        updateSaldoLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func formatDate(_ date:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let currentMonth = DatabaseManager.shared.page(forMonth: month)
        
        return currentMonth!.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! ItemCell
        
        let currentMonth = DatabaseManager.shared.page(forMonth: month)
        
        cell.descriptionLabel.text = currentMonth?.items[indexPath.row].description
        cell.paymentLabel.text = currentMonth?.items[indexPath.row].payment
        
        let type = currentMonth?.items[indexPath.row].type
        
        if(type == "Despesa") {
            cell.valueLabel.textColor = UIColor(red:160/255, green:210/255, blue:110/255, alpha:1.0)
            cell.valueLabel.text = "R$\(String(describing: currentMonth!.items[indexPath.row].value))"
        } else {
            cell.valueLabel.textColor = UIColor(red:213.0/255, green:96.0/255, blue:81.0/255, alpha:1.0)
            cell.valueLabel.text = "R$\(String(describing: currentMonth!.items[indexPath.row].value))"
        }
        
        cell.dateLabel.text = formatDate(currentMonth!.items[indexPath.row].date)
        //ADD IMAGEM CATEGORIA
        
        return cell
    }
    
    func updatePage() {
        self.pageControl.currentPage = self.month - 1
    }
    
    
}
