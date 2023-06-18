//
//  WeatherViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/05/28.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Firebase
import Lottie

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var selectPhotoBtn: UIButton!
    @IBOutlet weak var lookOOTDBtn: UIButton!
    @IBOutlet weak var cLabel: UILabel!
    @IBOutlet weak var ootdLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let apiKey = "3c6dfac13c7fb9b176a407ef82b6a9a5"
    var temperature: String!  // 현재 기온을 담을 변수
    var image: UIImage! // 전달할 이미지
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Object들의 모서리 둥글기 설정
        takePhotoBtn.layer.cornerRadius = 15
        selectPhotoBtn.layer.cornerRadius = 15
        lookOOTDBtn.layer.cornerRadius = 15
        
        // JSON 파일
        guard let jsonPath = Bundle.main.path(forResource: "foundOOTD", ofType: "json") else {
            print("JSON file not found")
            return
        }

        // JSON 파일을 로드하여 애니메이션 뷰에 설정
        animationView.animation = LottieAnimation.filepath(jsonPath)

        // 애니메이션 재생
        animationView.loopMode = .loop  // 애니메이션 반복 재생
        animationView.animationSpeed = 1
        animationView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cLabel.text = " " // 이미지의 contraint가 cLabel과 연결되어 있기 때문에 빈칸을 삽입해준다.
        ootdLabel.text = " "
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cLabel.text = " "
        ootdLabel.text = " "
    }
}

extension WeatherViewController {
    @IBAction func takePhoto(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController() // 컨트롤러를 생성한다.
        imagePickerController.delegate = self // 이 딜리게이터를 설정하면 사진을 찍은후 호출된다
        imagePickerController.sourceType = .camera
        
        // UIImagePickerController가 활성화
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension WeatherViewController {
    @IBAction func selectPhoto(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController() // 컨트롤러를 생성한다.
        imagePickerController.delegate = self // 이 딜리게이터를 설정하면 사진을 찍은후 호출된다
        imagePickerController.sourceType = .photoLibrary
        
        // UIImagePickerController이 활성화
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension WeatherViewController {
    @IBAction func lookOOTD(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showLibrary", sender: self)
    }
}

extension WeatherViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = img
        }
        // imagePickerController를 닫고, 이후에 OOTDViewController를 표시
        picker.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showPhoto", sender: self)
            }
        }
    }

    // 사진 캡쳐를 취소하는 경우 호출 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // imagePickerController을 죽인다
        picker.dismiss(animated: true, completion: nil)
    }
}

extension WeatherViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            guard let ootdViewController = segue.destination as? OOTDViewController else {
                return
            }
            ootdViewController.image = image
        }
        if segue.identifier == "showLibrary" {
            guard let ootdLibraryViewController = segue.destination as? OOTDLibraryViewController else {
                return
            }
        }
    }
}

extension WeatherViewController {
    struct WeatherResponse: Codable {
        struct Main: Codable {
            let temp: Double
        }
        let main: Main
    }
    
    func requestWeather(latitude: Double, longitude: Double) {
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        AF.request(url).responseDecodable(of: WeatherResponse.self) { [self] response in
            switch response.result {
            case .success(let value):
                let celsiusValue = value.main.temp - 273
                temperature = String(Int(celsiusValue))
                recommendOutfit()
                
            case .failure(let error):
                print("requestWeather 에러 : \(error)")
            }
        }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        print(latitude, longitude)
        requestWeather(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager 에러 : \(error.localizedDescription)")
    }
}

extension WeatherViewController {
    func recommendOutfit(){
        cLabel.text = "현재 기온 : \(temperature!)℃"
        let temp:Int = Int(temperature)!
        
        if temp >= 24 {
            ootdLabel.text = "추천 OOTD : 반팔티, 반바지"
        }
        else if temp >= 20 && temp <= 23 {
            ootdLabel.text = "추천 OOTD : 가디건, 얇은 긴팔"
        }
        else if temp >= 17 && temp <= 19 {
            ootdLabel.text = "추천 OOTD : 얇은 니트, 후드 티셔츠"
        }
        else if temp >= 10 && temp <= 16 {
            ootdLabel.text = "추천 OOTD : 얇은 코트, 데님 자켓"
        }
        else if temp >= 6 && temp <= 9 {
            ootdLabel.text = "추천 OOTD : 겨울 코트, 히트텍, 레깅스"
        }
        else {
            ootdLabel.text = "추천 OOTD : 패딩, 목도리, 장갑"
        }
    }
}
