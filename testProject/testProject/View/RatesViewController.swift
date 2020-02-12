//
//  RatesViewController.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import UIKit

class RatesViewController: UIViewController {

    lazy private var ratesViewModel = RatesViewModel(viewDelegate: self)
    var tableView: UITableView!

}

// MARK: - Life сycle methods

extension RatesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
}

// MARK: - Setup

extension RatesViewController {
    
    private func setup() {
        self.view.backgroundColor = .red
        self.setupTableView()
    }
    
    private func setupTableView() {
        self.tableView = UITableView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.tableView.register(UINib(nibName: "RateCell", bundle: nil), forCellReuseIdentifier: "RateCell")
    }

}

// MARK: - TableView data source and delegate

extension RatesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ratesViewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "RateCell",
                                                for: indexPath) as? RateCell {
            let item = self.ratesViewModel.items[indexPath.row]
            cell.setup(model: item)
            return cell
        }
        
        return UITableViewCell()
    }
    
}

// MARK: - View model delegate

extension RatesViewController: RatesVMDelegate {

    func reloadData() {
        self.tableView.reloadData()
    }

}
