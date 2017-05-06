//
//  CustomViewAnnotation.swift
//  Sam_Goeman_Multec_werkstuk2v2
//
//  Created by Sam Goeman on 02/05/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//  http://stackoverflow.com/questions/25541786/custom-uitableviewcell-from-nib-in-swift

import UIKit

protocol CustomViewAnnotationDelegate: class {
    func performSegueFromView(tree:Tree)
}

class CustomViewAnnotation: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundContentButton: UIButton!
    
    let tableCellId = "myAnnotationCell"
    
    var tree:Tree!
    
    var trees:[Tree] = [Tree]()
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: CustomViewAnnotationDelegate?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // setup list
        self.tableView.register(UINib(nibName: "AnnotationTableCell", bundle: nil), forCellReuseIdentifier: "myAnnotationCell")
        self.tableView.delegate = self   // 2
        self.tableView.dataSource = self // 2
        
    self.backgroundContentButton.applyArrowDialogAppearanceWithOrientation(arrowOrientation: .down)
        
    }
  
    func configureWithTrees(tree: [Tree]) { // 5
        self.trees = tree
        
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate/DataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // 6
        let cell = tableView.dequeueReusableCell(withIdentifier: "myAnnotationCell", for: indexPath) as! AnnotationTableCell
        
        cell.lblNaam.text = self.trees[indexPath.row].soort
        cell.lblNaam.sizeToFit()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableview did select row at")
        self.delegate?.performSegueFromView(tree: self.trees[indexPath.row])
    }

    /*func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("juiste segue")
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        if segue.identifier == "toDetailTree" {
            if let nextVC = segue.destination as? DetailTreeViewController {
                nextVC.treeSeg = self.trees[indexPath.row]
            }
        }
        
    }*/
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let result = tableView.hitTest(convert(point, to:tableView), with: event) {
            
            return result
        }
         return backgroundContentButton.hitTest(convert(point, to: backgroundContentButton), with: event)
    }
    
    





}
