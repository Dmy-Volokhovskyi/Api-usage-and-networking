//
//  ViewController.swift
//  Api usage and networking
//
//  Created by Дмитро Волоховський on 22/01/2022.
//

import UIKit
import MapKit
import CoreLocation

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServises()
        pinAddGesture()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        // Do any additional setup after loading the view.
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
        pullUpView.addSubview(spinner)
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
        pullUpView.addSubview(progressLabel)
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
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius / 3, longitudinalMeters: regionRadius / 3)
        mapView.setRegion(coordinateRegion, animated: true)
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
