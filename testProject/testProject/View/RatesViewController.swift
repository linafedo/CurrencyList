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
    private var tableView: UITableView!
    private var canReload: Bool = true
}

// MARK: - Life сycle methods

extension RatesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.ratesViewModel.viewWillDisappear()
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
            cell.setup(model: item, completion: self.recalculateRate(with:))
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.canReload = false
        
        tableView.performBatchUpdates({
            let index = IndexPath(row: 0, section: 0)
            
            self.tableView.beginUpdates()

            tableView.moveRow(at: indexPath, to: index)
            tableView.scrollToRow(at: index, at: .none, animated: true)
            
            self.tableView.endUpdates()

        }) { (_) in
            self.canReload = true
            self.ratesViewModel.didSelectRow(at: indexPath.row)
            (tableView.cellForRow(at: indexPath) as? RateCell)?.makeInteractive()
        }
        
    }
    
}

// MARK: - View model delegate

extension RatesViewController: RatesVMDelegate {
    
    func refreshAll() {
        guard self.canReload else { return }
        self.tableView.reloadData()
    }
    
    func updateCurrentData() {
        guard self.canReload else { return }
        UIView.performWithoutAnimation {
            let allButFirst = (self.tableView.indexPathsForVisibleRows ?? []).filter { $0.row != 0 }
            self.tableView.reloadRows(at: allButFirst, with: .automatic)
        }
    }
    
    func recalculateRate(with value: String?) {
        self.ratesViewModel.recalculateRate(value: value)
    }
    
}
