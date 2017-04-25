//
//  TableViewController.swift
//  Sam_Goeman_Multec_werkstuk2v2
//
//  Created by Sam Goeman on 07/04/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    var trees: [Tree] = []
    
    var filteredTrees = [Tree]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    enum selectedScope:Int {
        case sort = 0
        case planting = 1
    }
   
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet var tblSearch: UITableView!
   

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            self.trees = try self.context.fetch(Tree.fetchRequest())
        } catch {
            print("fetching error")
        }
       
        self.filteredTrees = self.trees
        searchBarSetup()
        

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSetup(){
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 50))
        searchBar.placeholder = "Search on sort"
       /* searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["sort"]
        searchBar.selectedScopeButtonIndex = 0*/
        searchBar.delegate = self
        
        self.tblSearch.tableHeaderView = searchBar
    }
    
    
    // MARK: - search bar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.filteredTrees = self.trees
        } else {
            //filterTableView(ind: searchBar.selectedScopeButtonIndex, text: searchText)
            self.filteredTrees = self.trees.filter({ (Tree) -> Bool in
                return (Tree.soort?.lowercased().contains(searchText.lowercased()))!
            })
            self.tblSearch.reloadData()
        }
        
    }
    
    func filterTableView(ind:Int, text:String){
        switch ind {
        case selectedScope.sort.rawValue:
            self.filteredTrees = self.trees.filter({ (Tree) -> Bool in
                return (Tree.soort?.lowercased().contains(text.lowercased()))!
            })
            self.tblSearch.reloadData()
        case selectedScope.planting.rawValue:
            self.filteredTrees = self.trees.filter({ (Tree) -> Bool in
                return (Tree.beplanting?.lowercased().contains(text.lowercased()))!
            })
            self.tblSearch.reloadData()
        default:
            print("no type")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
    
  
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        if segue.identifier == "toDetailTree" {
            if let nextVC = segue.destination as? DetailTreeViewController {
                
                
                            }
        }

    }
 

}
