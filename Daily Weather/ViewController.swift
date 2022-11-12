//
//  ViewController.swift
//  Daily Weather
//
//  Created by M.Ömer Ünver on 13.11.2022.
//

import UIKit
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var locationManager = CLLocationManager()
    var latitude = Double()
    var longitude = Double()
    var weatherArray : [weatherModel]? = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        locationSetup()
    }
    func locationSetup(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        let url = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=0cf0b8aec57f0673aa317cfae9353996&lang=tr&units=metric")!)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                self.alertFunc(title: "Error!", message: error?.localizedDescription ?? "Error")
            }
            do {
                let json = try! JSONSerialization.jsonObject(with: data!) as! [String : Any]
                if let locationName = json["name"] as? String {
                    DispatchQueue.main.async {
                    self.cityName.text = locationName
                    }
                }
                if let main = json["main"] as? [String : Any] {
                    if let temp = main["temp"] as? Double {
                        DispatchQueue.main.async {
                            self.temp.text = "\(temp) C°"
                        }
                    }
                        if let icon = json["weather"] as? [[String : Any]]{
                            for weatherIcon in icon {
                                if let icon = weatherIcon["icon"] as? String {
                                    DispatchQueue.main.async {
                                        self.imageView.image = UIImage(named: icon)
                                    }
                                }
                            }
                        }
                }
            } catch {
                self.alertFunc(title: "Error!!", message: "Error!!")
            }
        }
        task.resume()
        
        let url2 = URLRequest(url: URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=hourly&appid=0cf0b8aec57f0673aa317cfae9353996&units=metric")!)
        
        let task2 = URLSession.shared.dataTask(with: url2) { data, response, error in
            if error != nil {
                self.alertFunc(title: "ERROR!!!", message: error?.localizedDescription ?? "ERROR!!!")
            }
            
            self.weatherArray = [weatherModel]()
            do {
                let json2 = try JSONSerialization.jsonObject(with: data!) as! [String : Any]
                if let daily = json2["daily"] as? [[String : Any]] {
                    for weatherDaily in daily {
                        var weather = weatherModel()
                        if let dt = weatherDaily["dt"] as? Double {
                            weather.dt = dt
                        }
                        if let temp = weatherDaily["temp"] as? [String : Any] {
                            if let min = temp["min"] as? Double, let max = temp["max"] as? Double{
                                weather.tempMax = max
                                weather.tempMin = min
                            }
                        }
                       
                        if let apiWeather = weatherDaily["weather"] as? [[String : Any]] {
                            for weatherIcons in apiWeather {
                                if let weathersIcon = weatherIcons["icon"] as? String {
                                        weather.weatherIcons = weathersIcon
                                    
                                }
                            }
                        }
                        self.weatherArray?.append(weather)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                self.alertFunc(title: "ERROR!!!!", message: "error!!!!")
            }
        }
            task2.resume()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! weatherTableViewCell
        let date = Date(timeIntervalSince1970: weatherArray![indexPath.item].dt!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "EEEE"
        let strDate = dateFormatter.string(from: date)
        cell.gunLabel.text = strDate
        cell.gunImageView.image = UIImage(named: (weatherArray?[indexPath.item].weatherIcons)!)
        cell.tempMax.text = String(format: "%.1f", weatherArray![indexPath.item].tempMax!)
        cell.tempMin.text = String(format: "%.1f", weatherArray![indexPath.item].tempMin!)
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherArray!.count
    }
    func alertFunc(title : String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    

}

