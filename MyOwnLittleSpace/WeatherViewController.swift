//
//  ViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/05/28.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseStorage

class WeatherViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let apiKey = "3c6dfac13c7fb9b176a407ef82b6a9a5"
    var temperature: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func requestWeather(latitude: Double, longitude: Double) {
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        AF.request(url).responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let celsiusValue = json["main"]["temp"].doubleValue - 273.15
                self.temperature = Int(celsiusValue)
                print(self.temperature)
                
                self.recommendOutfit()
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func recommendOutfit() {
        var outfit = ""
        
        if temperature < 10 {
            outfit = "Coat, hat, and gloves"
        } else if temperature < 20 {
            outfit = "Sweater and jeans"
        } else {
            outfit = "T-shirt and shorts"
        }
        
        let alertController = UIAlertController(title: "Today's Outfit", message: "Recommended outfit: \(outfit)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func savePhotoToCategory(category: String, photo: UIImage) {
        guard let imageData = photo.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child(category).child(imageName)
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error retrieving download URL: \(error.localizedDescription)")
                    return
                }
                
                guard let downloadURL = url else {
                    print("Download URL is nil")
                    return
                }
                
                let imageURL = downloadURL.absoluteString
                print("Download URL: \(imageURL)")
                
                // Save the imageURL to Firebase Realtime Database
                let databaseRef = Database.database().reference().child("photos").child(category).childByAutoId()
                databaseRef.setValue(imageURL) { (error, databaseRef) in
                    if let error = error {
                        print("Error saving imageURL to database: \(error.localizedDescription)")
                    } else {
                        print("ImageURL saved to database")
                    }
                }
            }
        }
    }

    
    @IBAction func choosePhotoButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        let latitude = location.coordinate.latitude
        let longitude = -location.coordinate.longitude
        requestWeather(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

extension WeatherViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("Failed to retrieve image")
            return
        }
        
        let category = "\(Int(temperature))°"
        savePhotoToCategory(category: category, photo: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
