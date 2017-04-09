//
//  CustomAnnontation.swift
//  Sam_Goeman_Multec_werkstuk2v2
//
//  Created by Sam Goeman on 07/04/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var tree:Tree!
    var title:String?
    var coordinate:CLLocationCoordinate2D
    
    init(coordinate:CLLocationCoordinate2D, title:String, tree:Tree) {
        self.tree = tree
        self.title = title
        self.coordinate = coordinate
    }
}
