//
//  droppablePin.swift
//  Api usage and networking
//
//  Created by Дмитро Волоховський on 22/01/2022.
//

import UIKit
import MapKit

class droppablePin : NSObject,MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier : String!
    init(coordinate : CLLocationCoordinate2D, identifier : String){
        self.coordinate = coordinate
        self.identifier = identifier
    }
}
