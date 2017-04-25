//
//  CustomAnnontation.swift
//  Sam_Goeman_Multec_werkstuk2v2
//
//  Created by Sam Goeman on 07/04/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//

import UIKit
import MapKit


class CustomAnnotation: NSObject, NSCoding, MKAnnotation {
    
    var tree:Tree!
    var title:String?
    var coordinate: CLLocationCoordinate2D
    var latitude:CLLocationDegrees
    var longitude:CLLocationDegrees
    
    
    init(coordinate:CLLocationCoordinate2D, title:String, tree:Tree) {
        self.tree = tree
        self.title = title
        self.coordinate = coordinate
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    required init? (coder aDecoder: NSCoder){
        self.tree = aDecoder.decodeObject(forKey: "tree") as! Tree
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.latitude = aDecoder.decodeDouble(forKey: "latitude")
        self.longitude = aDecoder.decodeDouble(forKey: "longitude")
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(tree, forKey: "tree")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
    }
}
