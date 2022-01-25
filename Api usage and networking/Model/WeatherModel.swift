//
//  WeatherModel.swift
//  Api usage and networking
//
//  Created by Дмитро Волоховський on 24/01/2022.
//

import Foundation

struct WeatherModel
{
    let conditionId : Int
    let cityName : String
    let temperature : Double
    
    var temperatureString : String{
        return String(format: "%1.f", temperature)
    }
    
    var conditionName : String{
        print(conditionId)
        switch conditionId {
        case 200...232:
                    return "cloud.bolt"
                case 300...321:
                    return "cloud.drizzle"
                case 500...531:
                    return "cloud.rain"
                case 600...622:
                    return "cloud.snow"
                case 701...781:
                    return "cloud.fog"
                case 800:
                    return "sun.max"
                case 801...804:
                    return "cloud.bolt"
                default:
                    return "cloud"
}
}
}
