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
    @IBOutlet weak var horizontalAccurancy: UILabel!
    @IBOutlet weak var verticalAccurancy: UILabel!
    @IBOutlet weak var loadPosition: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var headingStep = 0
    var userHeading = 0.0
    
    var ref: DatabaseReference!
    var handle: DatabaseHandle!
    var dispositivosFromFirebase:[Any] = []
    var dispositivoLocation:[String:Any] = [
        "latitude":"",
        "longitude":"",
        "horizontalAccurancy": "",
        "verticalAccurancy":""
    ]
    
    
    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        nombreTextfield.delegate = self
        
        ref = Database.database().reference()
        handle = ref?.child("locaciones").observe(.value, with: { (snapshot) in
            if let item = snapshot.value {
                self.dispositivosFromFirebase.append(item as! NSDictionary)
                self.ref?.keepSynced(true)
            }
        })
        
        self.loadPosition.activityIndicatorViewStyle = .whiteLarge
        self.loadPosition.isHidden = true
        
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
    }
    
    //MARK: Funciones propias de la APP
    @IBAction func getPosition(_ sender: UIButton) {
        sender.isHidden = true
        self.loadPosition.isHidden = false
        self.loadPosition.startAnimating()
        
        var aux = CLLocation()
        
        for i in 1...10 {
            print(i)
            if i == 1{
                aux = self.userLocation
                sleep(1)
            }
            if self.userLocation.horizontalAccuracy < aux.horizontalAccuracy {
                aux = self.userLocation
                print("menor horizontal \(i)")
            }
            sleep(5)
        }
        
        //Update de etiquetas
        self.horizontalAccurancy.text = String(aux.horizontalAccuracy)
        self.verticalAccurancy.text = String(aux.verticalAccuracy)
        self.actualLongitud.text = String(aux.coordinate.longitude)
        self.actualLatitud.text = String(aux.coordinate.latitude)
        
        //Update de valores para el JSON a enviar a Firebase
        self.dispositivoLocation.updateValue(self.actualLatitud.text!, forKey: "latitude")
        self.dispositivoLocation.updateValue(self.actualLongitud.text!, forKey: "longitude")
        self.dispositivoLocation.updateValue(self.horizontalAccurancy.text!, forKey: "horizontalAccurancy")
        self.dispositivoLocation.updateValue(self.verticalAccurancy.text!, forKey: "verticalAccurancy")
        
        self.loadPosition.isHidden = true
        sender.isHidden = false
    }
    
    @IBAction func sendPosition() {
        if self.nombreTextfield.text != nil {
            self.ref.child("locaciones").child(self.nombreTextfield.text!).setValue(self.dispositivoLocation)
        }
    }


}

