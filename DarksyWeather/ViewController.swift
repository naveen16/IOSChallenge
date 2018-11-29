//
//  ViewController.swift
//  DarksyWeather
//
//  Created by Naveen Raj on 11/29/18.
//  Copyright © 2018 Naveen Raj. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var myArray = [Any]()
    private var myTableView: UITableView!
    
    struct WeatherData: Decodable{
        let latitude:Double
        let longitude:Double
        let daily:DailyWeather
    }
    struct DailyWeather: Decodable{
        let summary:String
        let data:[DailyData]
    }
    struct DailyData: Decodable{
        let summary:String
        let temperatureHigh:Double
        let temperatureLow:Double
        let precipProbability:Double
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height+30
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        getWeather()
    }
    
    func getWeather(){
        getWeatherRequest { error in
            if let error = error {
                print("Oops! Something went wrong...",error)
            } else {
                print("It has finished")
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
            }
        }
    }
    
    func getWeatherRequest(completion: @escaping (Error?) -> Void){
        let urlString = "https://api.darksky.net/forecast/59c6b6b7efd5c3fc0f617338cfae6c48/37.8267,-122.4233"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            var dates = ["11/29/18","11/30/18","11/29/18","12/01/18","12/02/18","12/03/18","12/04/18","12/05/18"]
            guard let data = data else { return }
            do{
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                for i in 0...weatherData.daily.data.count-1 {
                    var date = dates[i]
                    var summary = weatherData.daily.data[i].summary
                    var high = weatherData.daily.data[i].temperatureHigh
                    var low = weatherData.daily.data[i].temperatureLow
                    var precip = weatherData.daily.data[i].precipProbability
                    self.myArray.append("\(date) \nSummary is \(summary).. The high is \(high) and the low is \(low). There's a \(precip*100)% of precipitation")
                }
                completion(nil)
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
        let newViewController = WeatherDetailsViewController()
        present(newViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(myArray[indexPath.row])"
        cell.textLabel!.numberOfLines = 5
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

