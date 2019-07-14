//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    func userEnteredANewCityName(cityName: String) {
        self.cityName = cityName
        clLocationManager.startUpdatingLocation()
    }
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "367537ee9e41d0bbae1a16dbd05e0425"
    
    let clLocationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    var cityName : String?
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(params: [String : String]){
        
        Alamofire.request(WEATHER_URL, method: .get, parameters: params).responseJSON{
            response in
            if response.result.isSuccess{
                print("Response is \(response.data)")
                let responseJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: responseJSON)
                
            }else{
                print("Network request failed with error:  \(response.error)")
            }
        }
    }
    
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    func updateWeatherData(json: JSON){
        if let temp = json["main"]["temp"].double{
            weatherDataModel.temparature = Int(temp - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather un available"
        }
    }
    
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temparature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get the most accurate location
        let location = locations[locations.count - 1]
        if (location.horizontalAccuracy > 0) {
            clLocationManager.stopUpdatingLocation()
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            var apiParams : [String : String] = [:]
            if let userEnteredCity = cityName {
                apiParams = ["q": userEnteredCity, "appid" : APP_ID]
            }else{
                apiParams = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            }
            
            getWeatherData(params: apiParams)
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location fetch failed with error: \(error)")
    }
    
    
    
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVc = segue.destination as! ChangeCityViewController
            destinationVc.delegate = self
        }
    }
    
    
    
    
}


