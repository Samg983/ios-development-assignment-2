//
//  DetailTreeViewController.swift
//  Sam_Goeman_Multec_werkstuk2v2
//
//  Created by Sam Goeman on 07/04/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailTreeViewController: UIViewController, MKMapViewDelegate {
    

    //var tree = Tree(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    
    var annotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(), title: "", tree: Tree(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext))

    @IBOutlet weak var adres: UILabel!
    @IBOutlet weak var beplanting: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var soort: UILabel!
    @IBOutlet weak var positie: UILabel!
    @IBOutlet weak var omtrek: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tree = annotation.tree!

        self.title = tree.soort
        
        adres.text = tree.adres
        adres.sizeToFit()
        beplanting.text = tree.beplanting
        beplanting.sizeToFit()
        status.text = tree.status
        status.sizeToFit()
        soort.text = tree.soort
        soort.sizeToFit()
        positie.text = tree.positie
        positie.sizeToFit()
        omtrek.text = String(tree.omtrek)
        omtrek.sizeToFit()
        
        self.mapView.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMapForPlace() {
        let regionDistance:CLLocationDistance = 10000
        let coordinates = self.annotation.coordinate
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.annotation.tree.adres
        mapItem.openInMaps(launchOptions: options)
    }
    
    

}
