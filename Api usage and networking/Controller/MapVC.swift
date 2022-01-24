//
//  ViewController.swift
//  Api usage and networking
//
//  Created by Дмитро Волоховський on 22/01/2022.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomConstrain : NSLayoutConstraint!
    @IBOutlet weak var pullUpView : UIView!
    
    var locationManager = CLLocationManager()
    let regionRadius = 7000.0
    var spinner : UIActivityIndicatorView!
    var progressLabel : UILabel!
    
    let screenSize = UIScreen.main.bounds
    
    let flowLayout = UICollectionViewFlowLayout()
    var collectionView:UICollectionView?
    
    var imageUrlArray = [String] ()
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServises()
        pinAddGesture()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self , forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .green
        pullUpView.addSubview(collectionView!)
    }

    func pinAddGesture () {
        let pinAddGesture = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        pinAddGesture.numberOfTapsRequired = 1
        pinAddGesture.delegate = self
        mapView.addGestureRecognizer(pinAddGesture)
    }
    
    func addSwipe (){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector (animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    func animateViewUp (){
        mapViewBottomConstrain.constant = 250
        UIView.animate(withDuration: 0.3) {
            self.mapView.layoutIfNeeded()
        }
        
    }
    @objc func animateViewDown(){
        mapViewBottomConstrain.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner (){
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.center = CGPoint(x: (screenSize.width / 2) - (spinner.frame.width / 2), y: 125)
        spinner.color = .gray
        spinner.startAnimating()
        collectionView?.addSubview(spinner)
    }
    func removeSpinner () {
        if spinner != nil {
            spinner.removeFromSuperview()
        }
    }
    func addProgressLbl () {
        progressLabel = UILabel()
        progressLabel.frame = CGRect(x: (screenSize.width / 2) - 100 , y: 175, width: 200, height: 40)
        progressLabel.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel.textColor = UIColor.label
        progressLabel.textAlignment = .center
        progressLabel.text = "Loading Images!"
        collectionView?.addSubview(progressLabel)
    }
    
    @IBAction func centerMapBtn(_ sender: UIButton) {
        
            centerMapOnUserLocation()
    }
}

extension MapVC : MKMapViewDelegate {
    func centerMapOnUserLocation (){
        guard let coordinate = locationManager.location?.coordinate else{return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @objc func dropPin (sender : UITapGestureRecognizer){
        removePin()
        removeProgressLbl()
        removeSpinner()
        
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = droppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        print(flickrURL(forApiKey: K.ApiKey, withAnnotation: annotation, andNumberOfPhotos: 10))
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius / 3, longitudinalMeters: regionRadius / 3)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveURL(forAnnotation: annotation) { (true) in
            print(self.imageUrlArray)
        }
    }
    func removeProgressLbl () {
        if progressLabel != nil {
            progressLabel.removeFromSuperview()
        }
    }
    func removePin () {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    func retrieveURL ( forAnnotation annotation : droppablePin, handler : @escaping (_ status: Bool)-> ()) {
        imageUrlArray = []
        AF.request(flickrURL(forApiKey: K.ApiKey, withAnnotation: annotation, andNumberOfPhotos: 10)).responseJSON { responce in
            guard let json = responce.value as? Dictionary<String , AnyObject> else {return}
            let photosDict = json["photos"] as! Dictionary<String , AnyObject>
            let photosDictionaryArray = photosDict["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photosDictionaryArray {
                let postURL = "https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_c_d.jpg"
                self.imageUrlArray.append(postURL)
            }
            handler(true)
        }
        
    }
    
}
extension MapVC : CLLocationManagerDelegate {
    func configureLocationServises (){
        if locationManager.authorizationStatus == .restricted, locationManager.authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        centerMapOnUserLocation()
    }
}

extension MapVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        cell?.layer.backgroundColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        return cell!
        
    }
    
}
