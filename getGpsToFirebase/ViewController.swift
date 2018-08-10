//
//  ViewController.swift
//  getGpsToFirebase
//
//  Created by Sergio Abarca Flores on 09-08-18.
//  Copyright © 2018 sergioeabarcaf. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var longitud: UILabel!
    @IBOutlet weak var latitud: UILabel!
    @IBOutlet weak var dispositivo: UITextField!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var headingStep = 0
    var userHeading = 0.0
    
    
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CoreLocation
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {locationManager.requestLocation()}
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.headingStep += 1
            print(self.headingStep)
            if self.headingStep < 5 { return }
            
            self.userHeading = newHeading.magneticHeading
            self.locationManager.stopUpdatingHeading()
        }
    }
    
    //MARK: Funciones propias de la APP
    @IBAction func getPosition() {
        self.longitud.text = String(self.userLocation.coordinate.longitude)
        self.latitud.text = String(self.userLocation.coordinate.latitude)
        print(self.dispositivo.text ?? "Default")
    }
    
    @IBAction func sendPosition() {
    }


}

