//
//  ViewController.swift
//  Daily Weather
//
//  Created by M.Ömer Ünver on 13.11.2022.
//

import UIKit
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
   
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var locationManager = CLLocationManager()
    var latitude = Double()
    var longitude = Double()
    
    @IBOutlet weak var haftalikHavaDurumuLabel: UILabel!
    @IBOutlet weak var yuksekLabel: UILabel!
    @IBOutlet weak var saatlikHavaDurumuLabel: UILabel!
    @IBOutlet weak var dusuk: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var weatherArray : [weatherModel]? = []
    var hourlyArray : [hourlyModel]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidenFunc()
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80.0
        tableView.estimatedRowHeight = 80.0
        loading.startAnimating()
        locationSetup()
    }
    func hidenFunc(){
        haftalikHavaDurumuLabel.isHidden = true
        saatlikHavaDurumuLabel.isHidden = true
        dusuk.isHidden = true
        yuksekLabel.isHidden = true
        temp.isHidden = true
        cityName.isHidden = true
        imageView.isHidden = true
    }
    func falseHidenFunc(){
        haftalikHavaDurumuLabel.isHidden = false
        saatlikHavaDurumuLabel.isHidden = false
        dusuk.isHidden = false
        yuksekLabel.isHidden = false
        temp.isHidden = false
        cityName.isHidden = false
        imageView.isHidden = false
    }
    func locationSetup(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
//    Update locations and url request
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        falseHidenFunc()
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
        
        //Daily
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
        
        //hourly
        let url3 = URLRequest(url: URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=daily&appid=0cf0b8aec57f0673aa317cfae9353996&units=metric")!)
        let task3 = URLSession.shared.dataTask(with: url3) { data, response, error in
            if error != nil {
                self.alertFunc(title: "Error", message: error?.localizedDescription ?? "Error")
            }
            do {
                let json3 = try JSONSerialization.jsonObject(with: data!) as! [String : Any]
                if let hourly = json3["hourly"] as? [[String : Any]] {
                    for hourlyWeather in hourly {
                        var hourly = hourlyModel()
                        if let dt = hourlyWeather["dt"] as? Double {
                            hourly.dt = dt
                        }
                        if let temp = hourlyWeather["temp"] as? Double {
                            hourly.temp = temp
                        }
                        if let ApiIcon = hourlyWeather["weather"] as? [[String : Any]]{
                            for weatherIcon in ApiIcon {
                                if let icon = weatherIcon["icon"] as? String {
                                    hourly.icon = icon
                                }
                            }
                        }
                        self.hourlyArray?.append(hourly)
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                self.alertFunc(title: "Error", message: "Error")
            }
        }
        task3.resume()
    }
    
// TableView
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
        return min(weatherArray!.count, 7)
    }
    
//    CollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCell", for: indexPath) as! weatherCollectionViewCell
        let date = Date(timeIntervalSince1970: hourlyArray![indexPath.item].dt!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        let strDate = dateFormatter.string(from: date)
        cell.hourlyLabel.text = strDate
        cell.collectionTemp.text = String(format: "%.1f", hourlyArray![indexPath.item].temp!)
        cell.collectionImageView.image = UIImage(named: (hourlyArray?[indexPath.item].icon)!)
        loading.stopAnimating()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(hourlyArray!.count, 24)
    }
    
//alert func
    func alertFunc(title : String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

