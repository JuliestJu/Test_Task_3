//
//  CitiesListViewController.swift
//  Test_Task_3
//
//  Created by Юлия Воротченко on 27.08.2020.
//  Copyright © 2020 Юлия Воротченко. All rights reserved.
//

import UIKit

enum CitiesListEvents {
    case cityDetails(CityModel)
}

final class CitiesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var rootView: CitiesListView!
    
    // MARK: - Private Properties
    
    let eventHandler: ((CitiesListEvents) -> ())?
    private let jsonParser: JSONParser
    private var cityModels: [CityModel] = []
    
    // MARK: - Initialization
    
    init(eventHandler: ((CitiesListEvents) -> ())?, jsonParser: JSONParser = JSONParserImpl()) {
        self.jsonParser = jsonParser
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(Self.self)
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTableView()
        self.getCities()
    }
    
    // MARK: - Private Methods
    
    private func setTableView() {
        self.rootView.citySearchBar.delegate = self
        self.rootView?.tableView.delegate = self
        self.rootView?.tableView.dataSource = self
        self.rootView.tableView.register(UINib(nibName: "CityTableViewCell", bundle: nil), forCellReuseIdentifier: "CityTableViewCell")
    }
    
    private func getCities() {
        let data = self.jsonParser.parseJSON(file: "cityList")
        switch data {
        case .success(let models):
            self.cityModels = models
        case .failure(let error):
            print(error)
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cityModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as? CityTableViewCell else { return UITableViewCell() }
        
        cell.fill(with: self.cityModels[indexPath.row], index: indexPath.item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.eventHandler?(.cityDetails(self.cityModels[indexPath.row]))
    }
    
    // MARK: - UISearchBarDelegate Mehtods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchQuery = self.rootView.citySearchBar.text else { return }
        let filteredArr = self.cityModels.filter { $0.name.lowercased().contains(searchQuery.lowercased()) }
        
        if !searchQuery.isEmpty {
            self.cityModels = filteredArr
        } else {
            self.getCities()
        }
    
        self.rootView.tableView.reloadData()
    }
}
