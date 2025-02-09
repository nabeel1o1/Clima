//
//  WeatherManager.swift
//  Clima
//
//  Created by Nabeel Ahmed on 01/02/2025.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=52e56b010c758ca1357140b66d32d179&units=metric&q="
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        
        let urlString = "\(weatherURL)\(cityName)"
        performRequest(with : urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with url: String) {
        if let url = URL(string: url) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url, completionHandler: {
                (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let hasData = data {
                    if let weather = parseJson(hasData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            })
            
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let city = decodedData.name
            
            let weatherModel = WeatherModel(conditionId: id, cityName: city, temperature: temp)
            return weatherModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
