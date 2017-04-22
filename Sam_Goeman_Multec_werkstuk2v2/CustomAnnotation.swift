//
//  CustomAnnontation.swift
//  Sam_Goeman_Multec_werkstuk2v2
//
//  Created by Sam Goeman on 07/04/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation, NSCoding {
    var tree:Tree!
    var title:String?
    var coordinate:CLLocationCoordinate2D
    
    private static let KeyTree = "key_tree"
    private static let KeyTitle = "key_title"
    private static let KeyCoordinate = "key_coordinate"
    
    init(coordinate:CLLocationCoordinate2D, title:String, tree:Tree) {
        self.tree = tree
        self.title = title
        self.coordinate = coordinate
    }
    
    required init? (coder aDecoder: NSCoder){
        self.tree = aDecoder.decodeObject(forKey: CustomAnnotation.KeyTree) as! Tree
        self.title = aDecoder.decodeObject(forKey: CustomAnnotation.KeyTitle) as? String
        self.coordinate = (aDecoder.decodeObject(forKey: CustomAnnotation.KeyCoordinate) as? CLLocationCoordinate2D)!
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(tree, forKey: CustomAnnotation.KeyTree)
        aCoder.encode(title, forKey: CustomAnnotation.KeyTitle)
        aCoder.encode(coordinate, forKey: CustomAnnotation.KeyCoordinate)
    }
}
