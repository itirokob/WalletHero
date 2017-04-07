//
//  FirstViewController.swift
//  ControleDeGastos
//
//  Created by Julianny Favinha on 3/29/17.
//  Copyright © 2017 Instituto de Pesquisas Eldorado. All rights reserved.
//

import UIKit
import PieCharts

class FirstViewController: UIViewController {
    
    @IBOutlet weak var expenseImageView: UIImageView!
    @IBOutlet weak var incomeImageView: UIImageView!
    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var despesasTotais: UILabel!
    @IBOutlet weak var receitasTotais: UILabel!
    
    @IBOutlet weak var saldoLabel: UILabel!
    let manager = DatabaseManager.shared
    
    fileprivate let colors:[UIColor] = [UIColor(red:0.78, green:0.83, blue:0.65, alpha:1.0), UIColor(red:0.91, green:0.68, blue:0.67, alpha:1.0), UIColor(red:0.89, green:0.87, blue:0.42, alpha:1.0), UIColor(red:0.38, green:0.78, blue:0.88, alpha:1.0), UIColor(red:0.42, green:0.47, blue:0.85, alpha:1.0), UIColor(red:0.92, green:0.68, blue:0.38, alpha:1.0), UIColor(red:0.83, green:0.83, blue:0.83, alpha:1.0), UIColor(red:0.90, green:0.39, blue:0.39, alpha:1.0), UIColor(red:0.42, green:0.90, blue:0.54, alpha:1.0), UIColor(red:0.63, green:0.41, blue:0.77, alpha:1.0), UIColor(red:0.73, green:0.76, blue:1.00, alpha:1.0), UIColor(red:0.61, green:0.80, blue:0.51, alpha:1.0), UIColor(red:1.00, green:0.67, blue:0.54, alpha:1.0), UIColor(red:0.55, green:0.70, blue:0.48, alpha:1.0), UIColor(red:0.44, green:0.46, blue:0.70, alpha:1.0)]
    
    fileprivate var categories:[String] = ["Sem categoria", "Alimentação", "Aluguel", "Farmácia", "Lazer", "Salário", "Saúde", "Telefonia", "Transporte", "Vestuário"]
    
    fileprivate var quantity:[Int] = [20, 10, 15, 12, 24, 13, 15, 18, 17, 20]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // line
        let line:UIView = UIView(frame: CGRect(x: 15, y: 285, width: 345, height: 1))
        line.backgroundColor = UIColor.lightGray
        self.view.addSubview(line)
        
        // images to "Despesas totais" and "Receitas totais"
        self.incomeImageView.image = UIImage(named: "piggy-bank.png")
        self.expenseImageView.image = UIImage(named: "wallet.png")
        
        /* ***************************************************************************************************************************************************************************************
        ****************************************************** TODO: PEGAR INFO DO BANCO E ATUALIZAR OS ARRAYS categories E quantity ****************************************************
        ****************************************************************************************************************************************************************************************** */
        
        // pie chart
        self.view.addSubview(pieChart)
        pieChart.layers = [createCustomViewsLayer(), createTextLayer()]
        pieChart.models = createModels()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSaldoLabel()
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Creates all slices in pie chart, each one with a color
    ///
    /// - Returns: array of slices in pie chart
    fileprivate func createModels() -> [PieSliceModel] {
        var modelsArray:[PieSliceModel] = []
        
        for i in 0..<quantity.count {
            modelsArray.append(PieSliceModel(value: Double(quantity[i]), color: self.colors[i]))
        }
        
        return modelsArray
    }
    
    /// View to labels of categories
    ///
    /// - Returns: view that contains labels of categories
    fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
        let viewLayer = PieCustomViewsLayer()
        
        let settings = PieCustomViewsLayerSettings()
        settings.viewRadius = 130
        settings.hideOnOverflow = false
        viewLayer.settings = settings
        
        viewLayer.viewGenerator = createViewGenerator()
        
        return viewLayer
    }
    
    /// Creates labels of percentage and puts into each piece of pie chart
    ///
    /// - Returns: labels of percentage
    fileprivate func createTextLayer() -> PiePlainTextLayer {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 75
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 11)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        textLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.percentage * 100 as NSNumber).map{"\($0)%"} ?? ""
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        
        return textLayer
    }
    
    /// Creates labels of categories and puts into each piece of pie chart
    ///
    /// - Returns: labels of categories
    fileprivate func createViewGenerator() -> (PieSlice, CGPoint) -> UIView {
        return {slice, center in
            let container = UIView()
            container.frame.size = CGSize(width: 240, height: 240)
            container.center = center
            let view = UIImageView()
            view.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
            container.addSubview(view)
            
            let specialTextLabel = UILabel()
            specialTextLabel.textAlignment = .center
            specialTextLabel.font = UIFont.systemFont(ofSize: 12)
            specialTextLabel.text = self.categories[slice.data.id]
            specialTextLabel.sizeToFit()
            specialTextLabel.frame = CGRect(x: 0, y: -3, width: 240, height: 240)
            
            container.addSubview(specialTextLabel)
            container.frame.size = CGSize(width: 240, height: 240)
            
            return container
        }
    }
}

