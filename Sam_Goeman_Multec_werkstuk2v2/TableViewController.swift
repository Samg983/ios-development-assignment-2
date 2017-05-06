//
//  TableViewController.swift
//  Sam_Goeman_Multec_werkstuk2v2
//
//  Created by Sam Goeman on 07/04/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.

// https://www.youtube.com/watch?v=TMo7PuggHlc&t=934s searchbalk
// http://stackoverflow.com/questions/29192579/fixed-uisearchbar-using-uisearchcontroller-not-using-header-view-of-uitablevie

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    var trees: [Tree] = []
    
    var filteredTrees = [Tree]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet var tblSearch: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Trees", comment: "")
        
        do {
            self.trees = try self.context.fetch(Tree.fetchRequest())
        } catch {
            print("fetching error")
        }
        
        self.filteredTrees = self.trees
        
        searchBarSetup()
        
    }
    
    
    func searchBarSetup(){
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 50))
        searchBar.placeholder = NSLocalizedString("Search on sort", comment: "")
        //searchBar.showsCancelButton = true
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        //self.tblSearch.tableHeaderView = searchBar
    }
    
    
    
    // MARK: - search bar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filteredTrees = self.trees
        } else {
            self.filteredTrees = self.trees.filter({ (Tree) -> Bool in
                return (Tree.soort?.lowercased().contains(searchText.lowercased()))!
            })
            self.tblSearch.reloadData()
        }
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("tap cancel")
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredTrees.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "treeCell", for: indexPath)
        
        let tree:Tree = self.filteredTrees[indexPath.row]
        
        cell.textLabel?.text = tree.soort
        cell.detailTextLabel?.text = tree.adres
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        if segue.identifier == "toDetailTree" {
            if let nextVC = segue.destination as? DetailTreeViewController {
                nextVC.tree = self.trees[indexPath.row]
            }
        }
        
    }
    
    
}
