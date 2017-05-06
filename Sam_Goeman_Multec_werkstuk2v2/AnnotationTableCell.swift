//
//  AnnotationTableCell.swift
//  Sam_Goeman_Multec_werkstuk2v2
//
//  Created by Sam Goeman on 02/05/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//

import UIKit

class AnnotationTableCell: UITableViewCell {

    @IBOutlet weak var lblNaam: UILabel!
    
    weak var delegate: CustomViewAnnotationDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickCell(_ sender: Any) {
        print("clickkkk cell")
        
        
        //delegate?.detailsRequestedTree(tree: "")
    }
}
