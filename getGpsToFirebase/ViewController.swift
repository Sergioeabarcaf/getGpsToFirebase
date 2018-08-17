//
//  ViewController.swift
//  getGpsToFirebase
//
//  Created by Sergio Abarca Flores on 09-08-18.
//  Copyright © 2018 sergioeabarcaf. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var actualLongitud: UILabel!
    @IBOutlet weak var actualLatitud: UILabel!
    @IBOutlet weak var nombreTextfield: UITextField!
    @IBOutlet weak var nombreTitulo: UILabel!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var headingStep = 0
    var userHeading = 0.0
    
    var ref: DatabaseReference!
    var handle: DatabaseHandle!
    var dispositivosFromFirebase:[NSDictionary] = []
    var dispositivoLocation:[String:Any] = [
        "lat":"",
        "lon":""
    ]
    
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        nombreTextfield.delegate = self
        
        ref = Database.database().reference()
        handle = ref?.child("locaciones").observe(.childAdded, with: { (snapshot) in
            if let item = snapshot.value {
                self.dispositivosFromFirebase.append(item as! NSDictionary)
                self.ref?.keepSynced(true)
            }
        })
        
        
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
    
    //MARK: Text Fiel Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.nombreTitulo.text = self.nombreTextfield.text
    }
    
    //MARK: Funciones propias de la APP
    @IBAction func getPosition() {
        self.actualLongitud.text = String(self.userLocation.coordinate.longitude)
        self.actualLatitud.text = String(self.userLocation.coordinate.latitude)
        self.dispositivoLocation.updateValue(self.actualLatitud.text!, forKey: "lat")
        self.dispositivoLocation.updateValue(self.actualLongitud.text!, forKey: "lon")
    }
    
    @IBAction func sendPosition() {
        if self.nombreTextfield.text != nil {
            self.ref.child("location").child(self.nombreTextfield.text!).setValue(self.dispositivoLocation)
        }
    }


}

