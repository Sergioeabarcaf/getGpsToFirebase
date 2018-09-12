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
import CodableFirebase

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var actualLongitud: UILabel!
    @IBOutlet weak var actualLatitud: UILabel!
    @IBOutlet weak var nombreTextfield: UITextField!
    @IBOutlet weak var nombreTitulo: UILabel!
    @IBOutlet weak var horizontalAccurancy: UILabel!
    @IBOutlet weak var verticalAccurancy: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var bestUserLocation = CLLocation()
    var countGetsPosition = 0
    var userHeading = 0.0
    
    var ref: DatabaseReference!
    var handle: DatabaseHandle!

    var dispositivoLocation:[String:Any] = [
        "latitude":"",
        "longitude":"",
        "horizontalAccurancy": "",
        "verticalAccurancy":"",
        "nameDevice" : ""
    ]
    
    struct deviceData: Codable {
        var latitude: String
        var longitude: String
        var horizontalAccurancy: String
        var verticalAccurancy: String
        var nameDevice: String
    }
    
    var dispositivosFromFirebase:[String:deviceData] = [:]
    
    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        nombreTextfield.delegate = self
        
        Database.database().isPersistenceEnabled = true
        ref = Database.database().reference()
        handle = ref?.child("locaciones").observe(.value, with: { (snapshot) in
            guard let item = snapshot.value else { return }
            do{
                let auxItem = try FirebaseDecoder().decode([String:deviceData].self, from: item)
                print(auxItem)
                self.dispositivosFromFirebase = auxItem
                self.ref?.keepSynced(true)
            }
            catch let error{
                print("================   \(error)   ==============")
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
        locationManager.stopUpdatingLocation()
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

    }
    
    //MARK: Text Fiel Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.nombreTitulo.text = self.nombreTextfield.text
        textField.resignFirstResponder()
    }
    
    
    
    //MARK: Funciones propias de la APP
    @IBAction func getPosition(_ sender: UIButton) {
        self.countGetsPosition += 1
        
        for i in self.dispositivosFromFirebase{
            if i.value.nameDevice == "sillon2"{
                print(i)
            }
        }
        
        if self.bestUserLocation.horizontalAccuracy == 0.0 {
            self.bestUserLocation = self.userLocation
            self.statusLabel.backgroundColor = UIColor.yellow
            self.statusLabel.text = "Primera medición, intento: \(self.countGetsPosition)"
            self.updateLabels()
        }
        
        else if self.bestUserLocation.horizontalAccuracy > self.userLocation.horizontalAccuracy {
            self.bestUserLocation = self.userLocation
            self.statusLabel.backgroundColor = UIColor.green
            self.statusLabel.text = "Mayor presición, intento: \(self.countGetsPosition)"
            self.updateLabels()
        }
        
        else{
            self.statusLabel.backgroundColor = UIColor.red
            self.statusLabel.text = "Menor presición, intento: \(self.countGetsPosition)"
        }
    }
    
    @IBAction func sendPosition() {
        if self.nombreTextfield.text != nil {
            self.dispositivoLocation.updateValue(self.nombreTextfield.text!, forKey: "nameDevice")
            self.ref.child("locaciones").childByAutoId().setValue(self.dispositivoLocation)
        }
    }
    
    func updateLabels(){
        //Update de etiquetas
        self.horizontalAccurancy.text = String(self.bestUserLocation.horizontalAccuracy)
        self.verticalAccurancy.text = String(self.bestUserLocation.verticalAccuracy)
        self.actualLongitud.text = String(self.bestUserLocation.coordinate.longitude)
        self.actualLatitud.text = String(self.bestUserLocation.coordinate.latitude)
        
        //Update de valores para el JSON a enviar a Firebase
        self.dispositivoLocation.updateValue(self.actualLatitud.text!, forKey: "latitude")
        self.dispositivoLocation.updateValue(self.actualLongitud.text!, forKey: "longitude")
        self.dispositivoLocation.updateValue(self.horizontalAccurancy.text!, forKey: "horizontalAccurancy")
        self.dispositivoLocation.updateValue(self.verticalAccurancy.text!, forKey: "verticalAccurancy")
    }


}

