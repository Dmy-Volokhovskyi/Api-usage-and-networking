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
    
    
    @IBOutlet weak var citySearchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomConstrain : NSLayoutConstraint!
    @IBOutlet weak var pullUpView : UIView!
    
    var locationManager = CLLocationManager()
    let regionRadius = 7000.0
    var spinner : UIActivityIndicatorView!
    var progressLabel : UILabel!
    var weatherSymbol : UIImageView!
    var cityLabel : UILabel!
    var temperatureLabel : UILabel!
    var weatherManager = WeatherManager()
    let screenSize = UIScreen.main.bounds
    
    
    let flowLayout = UICollectionViewFlowLayout()
    var collectionView:UICollectionView?
    
    var imageUrlArray = [String] ()
    var imageArray = [UIImage]()
    var mapItems: [MKMapItem] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        citySearchTextField.delegate = self
        mapView.delegate = self
        locationManager.delegate = self
        weatherManager.delegate = self
        configureLocationServises()
        pinAddGesture()
        pullUpView.backgroundColor = UIColor(named: "UIColor Orange")
        
        let collectionViewFrame = CGRect(x: 0 , y: 100, width: view.frame.width, height: view.frame.height/2)
        
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self , forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor(named: "UIColor Orange")
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
        cancelAllSessions()
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
    func addWeatherSymbol () {
        weatherSymbol = UIImageView()
        weatherSymbol.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        weatherSymbol.contentMode = .scaleAspectFit
        pullUpView.addSubview(weatherSymbol)
    }
    func addTemperatureLabel () {
        temperatureLabel = UILabel()
        temperatureLabel.frame = CGRect(x: 100, y: 0, width: 100, height: 100)
        temperatureLabel.text = ""
        temperatureLabel.font = UIFont(name: "Avenir", size: 40)
        temperatureLabel.contentMode = .center
        temperatureLabel.textAlignment = .center
        pullUpView.addSubview(temperatureLabel)
    }
    func addCityNameLable () {
        cityLabel = UILabel ()
        cityLabel.frame = CGRect(x: 200, y: 0, width: 200, height: 100)
        cityLabel.text = ""
        cityLabel.font = UIFont(name: "Avenir", size: 21)
        cityLabel.allowsDefaultTighteningForTruncation = true
        pullUpView.addSubview(cityLabel)
        
    }
    
    @IBAction func centerMapBtn(_ sender: UIButton) {
        
        centerMapOnUserLocation()
    }
    
    @IBAction func searchForCity(_ sender: UIButton) {
        if citySearchTextField.text != nil {
        let city = citySearchTextField.text!
        citySearch(withName: city)
        }
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
        removeCitynameLabel()
        removeWeatherSymbol()
        removeTemperatureLabel()
        cancelAllSessions()
       
        
        imageUrlArray = []
        imageArray = []
        collectionView?.reloadData()
        
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        weatherManager.fetchWeather(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
        addWeatherSymbol()
        addTemperatureLabel()
        addCityNameLable()
        let annotation = droppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        // print(flickrURL(forApiKey: K.ApiKey, withAnnotation: annotation, andNumberOfPhotos: 10))
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius / 3, longitudinalMeters: regionRadius / 3)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveURL(forAnnotation: annotation) { (finished ) in
            if finished {
                self.retrieveImages(handler: {(finished) in
                    if finished {
                        self.removeProgressLbl()
                        self.removeSpinner()
                        self.collectionView?.reloadData()
                    }
                })
            }
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
    func removeWeatherSymbol () {
        if weatherSymbol != nil {
            weatherSymbol.removeFromSuperview()
        }
    }
    func removeCitynameLabel (){
        if cityLabel != nil {
            cityLabel.removeFromSuperview()
        }
    }
    func removeTemperatureLabel () {
        if temperatureLabel != nil {
            temperatureLabel.removeFromSuperview()
        }
    }
    func retrieveURL ( forAnnotation annotation : droppablePin, handler : @escaping (_ status: Bool)-> ()) {
        AF.request(flickrURL(forApiKey: K.ApiKey, withAnnotation: annotation, andNumberOfPhotos: 20)).responseJSON { responce in
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
    
    func retrieveImages (handler : @escaping (_ status : Bool)-> ()) {
        for url in imageUrlArray {
            AF.request(url).responseImage { responce in
                guard let image = responce.value else{return}
                self.imageArray.append(image)
                self.progressLabel.text = "\(self.imageArray.count) of 20 images downloaded"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            }
        }
    }
    
    
    func cancelAllSessions () {
        Alamofire.Session.default.session.getTasksWithCompletionHandler { sessionTask, uploadData, downloadData in
            sessionTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
    func citySearch (withName name : String) {
        var lat = 0.0
        var lon = 0.0
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = name
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            for item in response.mapItems {
                lat = item.placemark.coordinate.latitude
                lon = item.placemark.coordinate.longitude
                
            }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.regionRadius, longitudinalMeters: self.regionRadius)
            self.mapView.setRegion(coordinateRegion, animated: true)
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
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell ()}
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        imageView.contentMode = .scaleAspectFit
        cell.addSubview(imageView)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row])
        popVC.modalPresentationStyle = .fullScreen
        present(popVC, animated: true,completion: nil)
    }
}

extension MapVC : WeathermanagerDelegate {
    
        func didUpdateWeather(_ weatherManager: WeatherManager,weather: WeatherModel) {
            DispatchQueue.main.async {
                self.temperatureLabel.text = weather.temperatureString
                self.cityLabel.text = weather.cityName
                self.weatherSymbol.image = UIImage(systemName: weather.conditionName)?.withTintColor(.black)
                self.weatherSymbol.tintColor = .black
            }
        }
    
    
    func didFailWithError(error: Error) {
        print (error)
    }
    
    
}
extension MapVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Tell the keyboard where to go on next / go button.
        if citySearchTextField.text != nil {
            citySearch(withName: citySearchTextField.text!)
            citySearchTextField.text = ""
        }
        citySearchTextField.resignFirstResponder()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }else{
            textField.placeholder = "Type the name of city"
            return true
        }
    }
}
