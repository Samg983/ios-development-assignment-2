//
//  OverviewTreesViewController.swift
//  Sam_Goeman_Multec_werkstuk2
//
//  Created by Sam Goeman on 06/04/2017.
//  Copyright © 2017 Sam Goeman. All rights reserved.
//  http://stackoverflow.com/questions/39825278/how-to-remove-mutable-array-element-from-nsuserdefaults
//  http://stackoverflow.com/questions/28489227/swift-ios-dates-and-times-in-different-format
//  http://stackoverflow.com/questions/30635160/how-to-check-if-the-ios-app-is-running-for-the-first-time-using-swift
//  http://stackoverflow.com/questions/32850094/how-do-i-remove-all-map-annotations-in-swift-2
//  http://stackoverflow.com/questions/27960556/loading-an-overlay-when-running-long-tasks-in-ios
//  https://digitalleaves.com/blog/2016/12/building-the-perfect-ios-map-ii-completely-custom-annotation-views/
// http://stackoverflow.com/questions/36095510/how-to-call-performseguewithidentifier-from-xib

import UIKit
import MapKit
import CoreLocation
import CoreData

class OverviewTreesViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CustomViewAnnotationDelegate {
    
    var locationManager:CLLocationManager = CLLocationManager()
    
    var trees: [Tree] = []
    
    var annotations: [CustomAnnotation] = []
    
    var treesWithAddress:[Tree] = []
    
    var selectedTree:Tree?
    
    var adres:String = ""
    
    let annotationIdentifier = "Identifier"
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let defaults = UserDefaults.standard
    
    
    //outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDatumLaatstBijgewerkt: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpMap()
        
        self.checkFirstRun()
        
        self.getCurrentTime()
        
        
        let customViewAnnotation = CustomViewAnnotation()
        customViewAnnotation.delegate = self
        
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = button
    }
    
    
    
    func checkFirstRun(){
        if(UserDefaults.standard.bool(forKey: "HasLaunchedOnce")){
            print("not first run")
            self.getData()
        } else {
            print("first run")
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            self.deleteAllRecords()
            self.makeRequestAndGetData()
        }
    }
    
    
    
    func setCurrentDateAndTime(){
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        let convertedDate: String = dateFormatter.string(from: currentDate)
        
        self.defaults.setValue(convertedDate, forKey: "lastUpdate")
        self.defaults.synchronize()
        
        self.lblDatumLaatstBijgewerkt.text = NSLocalizedString("Last update: ", comment: "") + convertedDate
        
    }
    
    func getCurrentTime(){
        if let stringDate:String = self.defaults.value(forKey: "lastUpdate") as? String {
            lblDatumLaatstBijgewerkt.text = NSLocalizedString("Last update: ", comment: "") + stringDate
            lblDatumLaatstBijgewerkt.sizeToFit()
        }
        
    }
    
    func refresh(){
        let allPlacedAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allPlacedAnnotations)
        self.deleteAllRecords()
        self.makeRequestAndGetData()
        
        
    }
    
    func makeRequestAndGetData(){
        self.setCurrentDateAndTime()
        //url request
        let url = URL(string: "https://opendata.brussel.be/api/records/1.0/search/?dataset=opmerkelijke-bomen&lang=en&rows=1050")
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
                            print(fields);
                            if let beplanting = fields["beplanting"] {
                                tree.beplanting = beplanting as? String
                            }
                            
                            if let straat = fields["straat"] {
                                tree.adres = (straat as? String)! + ", Brussel"
                                self.convertStringToCoordinate(adres: tree.adres!, tree: tree)
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
                            
                            
                            
                        }
                        self.appDelegate.saveContext()
                        
                    }
                    
                }
                
            } catch {
                
            }
            self.getData()
            
        }
        task.resume()
        
        
        
    }
    
    func getData() {
        print("getdata")
        do {
            self.trees = try self.context.fetch(Tree.fetchRequest())
            print(self.trees.count)
            var teller = 0
            if self.trees.count > 0{
                for item in self.trees {
                    
                    if(item.adres != nil) {
                        teller += 1
                        self.placeAnnotationsOnMap(tree: item)
                    }
                }
                
                
                print("Teller: " + String(teller))
            }
        } catch {
            print("Fetching Failed")
        }
    }
    
    
    
    func convertStringToCoordinate(adres:String, tree:Tree){
        let geoCoder = CLGeocoder()
        sleep(1)
        geoCoder.geocodeAddressString(adres) { (placemarks, error) in
            guard
                
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    print("kan niet vinden: " + adres)
                    
                    return
            }
            
            tree.latitude = location.coordinate.latitude
            tree.longitude = location.coordinate.longitude
            
            print(tree.latitude);
        }
    }
    
    
    func placeAnnotationsOnMap(tree:Tree){
        let allAnnotations = self.mapView.annotations
        
        
        if allAnnotations.isEmpty {
            var array = [Tree]()
            array.append(tree)
            let annotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: tree.latitude, longitude: tree.longitude), title: tree.soort!, elements: array)
            self.mapView.addAnnotation(annotation)
            
            
        } else {
            let dubbelePins = self.mapView.annotations.filter( { return $0.coordinate.latitude == tree.latitude  && $0.coordinate.longitude == tree.longitude} )
            
            if dubbelePins.count != 0 {
                
                let onMapAnnotations = self.mapView.annotations.filter( { return $0.coordinate.latitude == tree.latitude  } )
                
                if !onMapAnnotations.isEmpty {
                    if let onMapAnnotation = onMapAnnotations[0] as? CustomAnnotation {
                        
                        onMapAnnotation.elements.append(tree)
                    }
                }
                
                
                
            }
            else{
                //print("PIN bestaat nog niet")
                var array = [Tree]()
                array.append(tree)
                let annotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: tree.latitude, longitude: tree.longitude), title: tree.soort!, elements: array)
                self.mapView.addAnnotation(annotation)
                
            }
            
            
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: self.annotationIdentifier)
        
        if annotationView == nil {
            annotationView = TreesAnnotationView(annotation: annotation, reuseIdentifier: self.annotationIdentifier)
            (annotationView as! TreesAnnotationView).customViewAnnotationDelegate = self        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
        
    }
    
    
    func performSegueFromView(tree:Tree){
        self.selectedTree = tree
        self.performSegue(withIdentifier: "toDetailTree", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailTree" {
            if let nextVC = segue.destination as? DetailTreeViewController {
                nextVC.tree = self.selectedTree!
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
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        present(alert, animated: true, completion: nil)
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tree")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
            dismiss(animated: false, completion: nil)
        } catch {
            print ("There was an error")
        }
    }
    
    
}
