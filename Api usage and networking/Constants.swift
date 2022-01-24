//
//  Constants.swift
//  Api usage and networking
//
//  Created by Дмитро Волоховський on 23/01/2022.
//

import Foundation
struct K {
    static let ApiKey = "7678bbcf1ba0faa0a79ecb7891aedb7b"
    
   
}
func flickrURL(forApiKey key : String, withAnnotation annotation : droppablePin,andNumberOfPhotos number : Int) -> String {
    
    return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}
