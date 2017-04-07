//
//  PageViewController.swift
//  ControleDeGastos
//
//  Created by Tamara Martinelli de Campos on 06/04/17.
//  Copyright © 2017 Instituto de Pesquisas Eldorado. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController,  UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var currentPage = 1
    
    var MONTHS_COUNT = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setViewControllers([monthViewController(forPage: currentPage)], direction: .forward, animated: false, completion: nil)
        
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return MONTHS_COUNT
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    {
        let monthViewController = pendingViewControllers.first as! MonthViewController
        
        
        monthViewController.updatePage()
        currentPage = monthViewController.month
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var previousPage = currentPage - 1
        
        
        if previousPage <= 0
        {
            previousPage = 12
        }
        
        
        return monthViewController(forPage: previousPage)
    }
    
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        var nextPage = currentPage + 1
        
        
        if nextPage > 12
        {
            nextPage = 1
        }
        
        
        return monthViewController(forPage: nextPage)
    }
    
    private func monthViewController(forPage pageIndex: Int) -> MonthViewController {
        
        // Instantiate and configure a `DataItemViewController` for the `DataItem`.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "MonthViewController") as? MonthViewController else { fatalError("Unable to instantiate a MonthViewController.") }
        
        // TODO: reloadData
        //controller.tableView.reloadData()
        
        
        controller.month = pageIndex //+ 1 // page starts with 0 and month starts with 1
        
        let _ = controller.view
        
        return controller
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
