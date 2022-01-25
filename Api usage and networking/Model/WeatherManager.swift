//
//  WeatherManager.swift
//  Api usage and networking
//
//  Created by Дмитро Волоховський on 24/01/2022.
//


import Foundation
import CoreLocation


protocol WeathermanagerDelegate {
   func didUpdateWeather (_ weatherManager: WeatherManager,weather: WeatherModel)
   func didFailWithError(error:Error)
}
struct WeatherManager {

    
    var delegate :WeathermanagerDelegate?
    
    func fetchWeather(cityName : String){
        performRequest(with: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=3f4a49c38eacb97fcd4170702c9ea04a&units=metric&q=" )
        
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude : CLLocationDegrees) {
        performRequest(with: "https://api.openweathermap.org/data/2.5/weather?&lat=\(latitude)&lon=\(longitude)&appid=3f4a49c38eacb97fcd4170702c9ea04a&units=metric&q=")
    }
    
    func performRequest( with urlString : String){
        
        if  let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, responce, error in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather =  self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weatherFormInt = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weatherFormInt
        } catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
