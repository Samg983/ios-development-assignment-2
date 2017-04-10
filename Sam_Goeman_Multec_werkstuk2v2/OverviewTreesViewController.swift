//
//  OverviewTreesViewController.swift
//  Sam_Goeman_Multec_werkstuk2
//
//  Created by Sam Goeman on 06/04/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class OverviewTreesViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager = CLLocationManager()
    
    var trees: [Tree] = []
    
    var adres:String = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //outlets
    
    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.deleteAllRecords()
        self.setUpMap()
        
        //self.makeRequestAndGetData()
        //Test
        self.getData()
        
       // let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: /*#selector(makeRequestAndGetData)*/)
        //navigationItem.rightBarButtonItem = button
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeRequestAndGetData(){
        //url request
        let url = URL(string: "https://opendata.brussel.be/api/records/1.0/search/?dataset=opmerkelijke-bomen&lang=en&rows=5000")
        let urlRequest = URLRequest(url: url!)
        
        //setup session
        let session = URLSession(configuration:
            URLSessionConfiguration.default)
        
        //request maken
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for errors
            guard error == nil else {
                print("error calling GET")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            //json serializen naar string
            do {
                let json = try JSONSerialization.jsonObject(
                    with: responseData, options: [])
                    as? [String: Any]
                
                
                if let records = json?["records"] as? [[String : Any]] {
                    for element in records {
                        //print(element)
                        
                        let tree = Tree(context: self.context)
                        
                        
                        
                        if let fields = element["fields"] as? [String: Any] {
                            
                            if let beplanting = fields["beplanting"] {
                                tree.beplanting = beplanting as? String
                            }
                            
                            if let straat = fields["straat"] {
                                tree.adres = (straat as? String)! + ", Brussel"
                            }
                            
                            if let status = fields["status"] {
                                tree.status = status as? String
                            }
                            
                            if let soort = fields["soort"] {
                                tree.soort = soort as? String
                            }
                            
                            if let positie = fields["positie"] {
                                tree.positie = positie as? String
                            }
                            
                            if let omtrek = fields["omtrek"] {
                                tree.omtrek = (omtrek as? Float)!
                            }
                            
                            if let id = fields["id"] {
                                tree.id = (id as? Float)!
                            }
                            
                            
                            
                            /*if let gemeente = fields["gemeente"] {
                             tree.setValue(gemeente, forKey: "gemeente")
                             self.adres += String(describing: gemeente)
                             print(self.adres)
                             }*/
                            
                        }
                        self.appDelegate.saveContext()
                        
                    }
                    self.getData()
                }
                
            } catch {
                
            }
        }
        task.resume()
        
    }
    
    func getData() {
        do {
            self.trees = try context.fetch(Tree.fetchRequest())
            print(self.trees.count)
            var teller = 0
            if self.trees.count > 0{
                for item in self.trees {
                    
                    if(item.adres != nil) {
                        teller += 1
                        self.convertStringToCoordinateAndAddAnnotation(adres: item.adres!, title: item.soort!, tree: item)
                    }
                }
                print("Teller: " + String(teller))
            }
        } catch {
            print("Fetching Failed")
        }
    }
    
    func convertStringToCoordinateAndAddAnnotation(adres:String, title:String, tree:Tree){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(adres) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            let annotation = CustomAnnotation(coordinate: location.coordinate, title: title, tree: tree)
            // annotation.coordinate = location.coordinate
            //annotation.title = title
            //annotation.tree = tree
            
            self.mapView.addAnnotation(annotation)
            
        }
    }
    
    
    func checkFirstRun(){
        if(UserDefaults.standard.bool(forKey: "HasLaunchedOnce")){
            self.getData()
        } else {
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            self.makeRequestAndGetData()
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
           
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            //.detailDisclosure
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "tree")
        }
        return annotationView
    }
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "toDetailTree", sender: view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailTree" {
            if let nextVC = segue.destination as? DetailTreeViewController {
                let view = sender as! MKAnnotationView
                let a = view.annotation as! CustomAnnotation
            
                nextVC.annotation = a
            }
        }
    }
    
    func setUpMap(){
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func deleteAllRecords() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tree")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
        } catch {
            print ("There was an error")
        }
    }

    
    /*func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
     let center = CLLocationCoordinate2D(latitude : userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
     
     let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
     
     mapView.setRegion(region, animated: true)
     }*/
    
}
