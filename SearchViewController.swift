//
//  SearchViewController.swift
//  SuperHeroDatabase
//
//  Created by Work on 4/13/17.
//  Copyright © 2017 mjdoiron. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    typealias JSONStandard = [String:AnyObject]
    
    struct TableViewCellIdentifiers {
        static let loadingCell = "LoadingCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let characterCell = "CharacterCell"
    }
    
    var isLoading = false
    var isEmpty = true
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var characters:[Character] = []
    
    var delegate: CharacterViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        register(for: TableViewCellIdentifiers.characterCell)
        register(for: TableViewCellIdentifiers.loadingCell)
        register(for: TableViewCellIdentifiers.nothingFoundCell)
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        
        DispatchQueue.main.async() {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func register(for nibName: String){
        let cellNib = UINib(nibName: nibName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: nibName)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEmpty {
            let cell = UITableViewCell()
            return cell
        } else if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            return cell
        } else if characters.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.characterCell, for: indexPath) as! CharacterCell
            let character = characters[indexPath.row]
            cell.configure(for: character)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEmpty {
            return 0
        } else if isLoading {
            return 1
        } else if characters.count == 0 {
            return 1
        } else {
            return characters.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEmpty {
            return 0
        } else if isLoading {
            return tableView.bounds.size.height
        } else if characters.count == 0 {
            return tableView.bounds.size.height
        } else {
            return 44
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            isEmpty = true
            tableView.reloadData()
        } else {
            isEmpty = false
            isLoading = true
            tableView.reloadData()
            
            let searchString = searchController.searchBar.text!
            let searchURLString = comicvineSearchURL(searchText: searchString)
            callAlamao(url: searchURLString)
        }
    }
    
    func comicvineSearchURL(searchText: String) -> String {
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "http://comicvine.gamespot.com/api/characters/?&api_key=29f1bcacd316d74219cbafb17dfbd73c8c8a6953&format=json&field_list=name,id,image,publisher&filter=name:" + escapedSearchText
        return urlString
    }
    
    
    
    
    func callAlamao(url: String) {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
        
        Alamofire.request(url).responseJSON {
            response in
                if let error = response.result.error {
                    print(error)
                } else {
                    self.parseData(JSONData: response.data!)
                }
        }
    }
    
    func parseData(JSONData: Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let results = readableJSON["results"] as? [AnyObject] {
                //Clear characters
                characters = []
                
                //Pupulate characters
                for characterJSON in results {
                    guard let publisherInfo = characterJSON["publisher"] as? JSONStandard else {
                        //Skip if missing publisher info
                        continue
                    }
                    guard let name = characterJSON["name"] as? String,
                        let id = characterJSON["id"] as? Int,
                        let publisherId = publisherInfo["id"] as? Int,
                        let imageDict = characterJSON["image"] as? JSONStandard
                        else {
                            //Skip Character if missing any vital info
                            continue
                    }
                    let publisher:Publisher?
                    
                    switch publisherId {
                    case 31:
                        publisher = .Marvel
                    case 10:
                        publisher = .DC
                    default:
                        //Skip character if not Marvel or DC
                        continue
                    }
                    
                    guard let thumbnailString = imageDict["thumb_url"] as? String,
                        let fullSizeString = imageDict["super_url"] as? String else {
                            //skip is missing image URLs
                            continue
                    }
                    //create Character
                    let character = Character(name: name, id: id, publisher: publisher!, thumbnailURL: URL(string: thumbnailString)!, fullSizeURL: URL(string: fullSizeString)!)
                    characters += [character]
                }
                isLoading = false
                tableView.reloadData()
            }
        } catch {
            print(error)
        }
        
    }
    
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: false, completion: nil)
    }
}
