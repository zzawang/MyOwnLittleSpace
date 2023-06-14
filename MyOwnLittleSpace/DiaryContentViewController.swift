//
//  DiaryContentViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/06/10.
//

import UIKit
import Lottie
import CoreLocation
import SwiftyJSON
import Alamofire

// 반복적인 부분들도 많고 수업에서 배운 것들을 사용하기 위해 programming으로 view 생성
class DiaryContentViewController: UIViewController {
    // moodContainerView들을 담을 배열
    var moodViews: [UIView] = []
    // weatherContainerView들을 담을 배열
    var weatherViews: [UIView] = []

    // 감정 단어들을 담을 배열
    var moodArr: [String] = ["행복", "사랑을 느낌", "평범함", "슬픔", "화남", "감동 받음", "월급날", "기분 최고", "킹받음", "난처함", "너무 웃김", "속상함", "정신없음", "빡공중", "해탈", "축하", "주눅", "못마땅", "머리 아픔", "졸림", "부끄러움", "아픔", "소름", "없음"]
    // 날씨 단어들을 담을 배열
    var weatherArr: [String] = ["날씨 좋음", "눈", "비", "태풍", "천둥 번개", "흐림", "폭염", "강추위"]
    
    var clickedMood : String = ""  // 클릭한 감정
    var clickedWeather : String = ""  // 클릭한 날씨
    var diaryContent : String = ""  // 일기 내용
    
    var continueBtn = UIButton(type: .system) // 계속 버튼
    var firstContainerView: UIView! // // Continue 버튼을 제외하는 첫 번째 페이지의 모든 뷰를 감싸는 firstContainerView
    var secondContainerView: UIView! // 두 번째 페이지의 모든 뷰를 감싸는 secondContainerView
    var thirdContainerView: UIView! // 세 번째 페이지의 모든 뷰를 감싸는 thirdContainerView
    var completeContainerView: UIView! // 마지막 페이지의 모든 뷰를 감싸는 completeContainerView
    
    var viewCount:Int = 1  // 현재 무슨 페이지인지 알려줄 변수
    var selectedDate:String = "" // 현재 선택된 날짜
    
    let locationManager = CLLocationManager()
    let apiKey = "3c6dfac13c7fb9b176a407ef82b6a9a5"
    var temperature: String?  // 현재 기온을 담을 변수
    
    var weatherLabel: UILabel! // 기온 레이블 (현재 기온을 담기 위해)
    var dateLabel: UILabel! // 날짜 레이블
    
    var moodImg: UIImage!
    var moodImgView: UIImageView!
    
    var weatherImg: UIImage!
    var weatherImgView: UIImageView!
    
    var contentTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // 커스텀한 색상 정의
        let yellowColor = UIColor(hex: "#FFF096")
        let orangeColor = UIColor(hex: "#FFC800")
        
        view.backgroundColor = yellowColor

        // 첫 번째 페이지
        firstContainerView = UIView()
        firstContainerView.translatesAutoresizingMaskIntoConstraints = false
        firstContainerView.backgroundColor = yellowColor
        view.addSubview(firstContainerView)

        // firstContainerView의 제약 조건 설정
        NSLayoutConstraint.activate([
            firstContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            firstContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            firstContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            firstContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])

        // 이름 레이블 생성 및 설정
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textAlignment = .left
        nameLabel.text = "호빈"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 35) // 폰트 크기 설정
        firstContainerView.addSubview(nameLabel)

        // 인사 레이블 생성 및 설정
        let helloLabel = UILabel()
        helloLabel.translatesAutoresizingMaskIntoConstraints = false
        helloLabel.textAlignment = .left
        helloLabel.text = "님, 오늘 하루는 어떠셨나요?"
        firstContainerView.addSubview(helloLabel)

        // 감정 스크롤 뷰 생성 및 설정
        let moodScrollView = UIScrollView()
        moodScrollView.translatesAutoresizingMaskIntoConstraints = false
        firstContainerView.addSubview(moodScrollView)

        // 이름 레이블, 인사 레이블, 스크롤 뷰의 제약 조건 설정
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: firstContainerView.leadingAnchor, constant: 30),
            nameLabel.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 40),
            helloLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 5),
            helloLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: -5),
            moodScrollView.leadingAnchor.constraint(equalTo: firstContainerView.leadingAnchor),
            moodScrollView.trailingAnchor.constraint(equalTo: firstContainerView.trailingAnchor),
            moodScrollView.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 100),
            moodScrollView.bottomAnchor.constraint(equalTo: firstContainerView.bottomAnchor)
        ])

        // 이미지뷰와 레이블이 가운데에 정렬된 뷰 생성 후 스크롤 뷰에 추가
        for i in 0..<24 {
            // 이미지뷰 생성
            let image = UIImage(named: "mood\(i+1).png")!
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            imageView.image = image
            imageView.isUserInteractionEnabled = true
            imageView.translatesAutoresizingMaskIntoConstraints = false

            // 이미지뷰와 감정 레이블을 감싸는 moodContainerView 생성 및 추가 (image의 사이즈에 맞게 생성하기 위해 이미지뷰 먼저 생성)
            let moodContainerView = UIView(frame: CGRect(x: (CGFloat(i%2) * (view.frame.width/2) + ((view.frame.width/2) - image.size.width * 2.3)/2), y: (CGFloat(i/2) * (image.size.height * 2.7) + 15), width: image.size.width * 2.3, height: image.size.height * 2.3))
            moodContainerView.isUserInteractionEnabled = true
            moodContainerView.layer.cornerRadius = 30 // 모서리 둥글기 설정
            moodContainerView.backgroundColor = UIColor.white
            moodContainerView.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
            moodContainerView.layer.shadowOpacity = 0.3 // 그림자 투명도
            moodContainerView.layer.shadowOffset = CGSize(width: 5, height: 5) // 그림자 오프셋
            moodContainerView.layer.shadowRadius = 5 // 그림자 반경

            // 클릭했을 때 크키가 커지는 효과를 주도록 moodContainerView에 탭 제스처 등록
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moodTapped(_:)))
            moodContainerView.addGestureRecognizer(tapGesture)

            moodScrollView.addSubview(moodContainerView)

            // 이미지뷰 추가 (moodContainerView 먼저 생성 후 추가)
            moodContainerView.addSubview(imageView)

            // 감정레이블 생성 및 추가
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.text = moodArr[i]
            moodContainerView.addSubview(label)

            // 이미지뷰와 감정레이블의 제약 조건 설정
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
                label.leadingAnchor.constraint(equalTo: moodContainerView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: moodContainerView.trailingAnchor),
                imageView.centerXAnchor.constraint(equalTo: moodContainerView.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: moodContainerView.topAnchor, constant: 30)
            ])

            moodViews.append(moodContainerView) // 배열에 이미지뷰와 레이블을 감싼 moodContainerView 추가
            // scrollView의 크기를 생성된 moodContainerView의 수와 그 사이의 공간에 맞게 적절히 설정
            moodScrollView.contentSize = CGSize(width: view.frame.width, height: (image.size.height * 2.7 * CGFloat(12)) + 15)
        }

        // Continue 버튼 생성 및 뷰에 추가
        continueBtn = UIButton(type: .system)
        continueBtn.translatesAutoresizingMaskIntoConstraints = false
        continueBtn.setTitle("Continue", for: .normal)
        continueBtn.backgroundColor = UIColor.black
        continueBtn.layer.cornerRadius = 15
        continueBtn.setTitleColor(.black, for: .normal)
        continueBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        continueBtn.backgroundColor = orangeColor
        continueBtn.isUserInteractionEnabled = false
        continueBtn.isEnabled = false
        continueBtn.alpha = 0.3

        // Continue 버튼 클릭시 continueBtnClicked 함수 실행
        continueBtn.addTarget(self, action: #selector(continueBtnClicked), for: .touchUpInside)
        view.addSubview(continueBtn)

        // Continue 버튼의 제약 조건 설정
        NSLayoutConstraint.activate([
            continueBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            continueBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            continueBtn.topAnchor.constraint(equalTo: firstContainerView.bottomAnchor, constant: 15),
            continueBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // 두 번째 페이지
        secondContainerView = UIView()
        secondContainerView.translatesAutoresizingMaskIntoConstraints = false
        secondContainerView.backgroundColor = yellowColor
        secondContainerView.isHidden = true
        view.addSubview(secondContainerView)

        // secondContainerView의 제약 조건 설정
        NSLayoutConstraint.activate([
            secondContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            secondContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            secondContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            secondContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
        
        // 인사 레이블 생성 및 설정
        let weatherTodayLabel = UILabel()
        weatherTodayLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherTodayLabel.textAlignment = .left
        weatherTodayLabel.text = "오늘의 날씨는 어땠나요?"
        weatherTodayLabel.font = UIFont.boldSystemFont(ofSize: 25) // 폰트 크기 설정
        secondContainerView.addSubview(weatherTodayLabel)
        
        // 기온 레이블 생성 및 설정
        weatherLabel = UILabel()
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherLabel.textAlignment = .left
        secondContainerView.addSubview(weatherLabel)
        
        // 날씨 스크롤 뷰 생성 및 설정
        let weatherScrollView = UIScrollView()
        weatherScrollView.translatesAutoresizingMaskIntoConstraints = false
        secondContainerView.addSubview(weatherScrollView)

        // 이름 레이블, 인사 레이블, 스크롤 뷰의 제약 조건 설정
        NSLayoutConstraint.activate([
            weatherTodayLabel.leadingAnchor.constraint(equalTo: secondContainerView.leadingAnchor, constant: 30),
            weatherTodayLabel.topAnchor.constraint(equalTo: secondContainerView.topAnchor, constant: 40),
            weatherLabel.leadingAnchor.constraint(equalTo: secondContainerView.leadingAnchor, constant: 30),
            weatherLabel.topAnchor.constraint(equalTo: weatherTodayLabel.bottomAnchor, constant: 10),
            weatherScrollView.leadingAnchor.constraint(equalTo: secondContainerView.leadingAnchor),
            weatherScrollView.trailingAnchor.constraint(equalTo: secondContainerView.trailingAnchor),
            weatherScrollView.topAnchor.constraint(equalTo: secondContainerView.topAnchor, constant: 110),
            weatherScrollView.bottomAnchor.constraint(equalTo: secondContainerView.bottomAnchor)
        ])
        
        // 이미지뷰와 레이블이 가운데에 정렬된 뷰 생성 후 스크롤 뷰에 추가
        for i in 0..<8 {
            // 이미지뷰 생성
            let image = UIImage(named: "weather\(i+1).png")!
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            imageView.image = image
            imageView.isUserInteractionEnabled = true
            imageView.translatesAutoresizingMaskIntoConstraints = false

            // 이미지뷰와 날씨 레이블을 감싸는 weatherContainerView 생성 및 추가 (image의 사이즈에 맞게 생성하기 위해 이미지뷰 먼저 생성)
            let weatherContainerView = UIView(frame: CGRect(x: (CGFloat(i%2) * (view.frame.width/2) + ((view.frame.width/2) - image.size.width * 2.3)/2), y: (CGFloat(i/2) * (image.size.height * 2.7) + 15), width: image.size.width * 2.3, height: image.size.height * 2.3))
            weatherContainerView.isUserInteractionEnabled = true
            weatherContainerView.layer.cornerRadius = 30 // 모서리 둥글기 설정
            weatherContainerView.backgroundColor = UIColor.white
            weatherContainerView.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
            weatherContainerView.layer.shadowOpacity = 0.3 // 그림자 투명도
            weatherContainerView.layer.shadowOffset = CGSize(width: 5, height: 5) // 그림자 오프셋
            weatherContainerView.layer.shadowRadius = 5 // 그림자 반경

            // 클릭했을 때 크키가 커지는 효과를 주도록 weatherContainerView에 탭 제스처 등록
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(weatherTapped(_:)))
            weatherContainerView.addGestureRecognizer(tapGesture)

            weatherScrollView.addSubview(weatherContainerView)

            // 이미지뷰 추가 (moodContainerView 먼저 생성 후 추가)
            weatherContainerView.addSubview(imageView)

            // 날씨 레이블 생성 및 추가
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.text = weatherArr[i]
            weatherContainerView.addSubview(label)

            // 이미지뷰와 날씨 레이블의 제약 조건 설정
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
                label.leadingAnchor.constraint(equalTo: weatherContainerView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: weatherContainerView.trailingAnchor),
                imageView.centerXAnchor.constraint(equalTo: weatherContainerView.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: weatherContainerView.topAnchor, constant: 30)
            ])

            weatherViews.append(weatherContainerView) // 배열에 이미지뷰와 레이블을 감싼 moodContainerView 추가
            // scrollView의 크기를 생성된 weatherContainerView의 수와 그 사이의 공간에 맞게 적절히 설정
            weatherScrollView.contentSize = CGSize(width: view.frame.width, height: (image.size.height * 2.7 * CGFloat(4)) + 15)
        }
        
        
        // 세 번째 페이지
        thirdContainerView = UIView()
        thirdContainerView.translatesAutoresizingMaskIntoConstraints = false
        thirdContainerView.backgroundColor = yellowColor
        thirdContainerView.isHidden = true
        view.addSubview(thirdContainerView)

        // thirdContainerView의 제약 조건 설정
        NSLayoutConstraint.activate([
            thirdContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            thirdContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            thirdContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            thirdContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
        
        // 날짜 레이블 생성 및 설정
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .left
        dateLabel.font = UIFont.boldSystemFont(ofSize: 25) // 폰트 크기 설정
        thirdContainerView.addSubview(dateLabel)
        
        // mood, weather 이미지뷰
        moodImgView = UIImageView()
        moodImgView.translatesAutoresizingMaskIntoConstraints = false
        thirdContainerView.addSubview(moodImgView)

        weatherImgView = UIImageView()
        weatherImgView.translatesAutoresizingMaskIntoConstraints = false
        thirdContainerView.addSubview(weatherImgView)

        // 날짜 레이블과 이미지뷰들의 제약 조건 설정
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: thirdContainerView.leadingAnchor, constant: 40),
            dateLabel.topAnchor.constraint(equalTo: thirdContainerView.topAnchor, constant: 40),
            moodImgView.widthAnchor.constraint(equalToConstant: 30),
            moodImgView.heightAnchor.constraint(equalToConstant: 30),
            moodImgView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 20),
            moodImgView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            weatherImgView.widthAnchor.constraint(equalToConstant: 30),
            weatherImgView.heightAnchor.constraint(equalToConstant: 30),
            weatherImgView.leadingAnchor.constraint(equalTo: moodImgView.trailingAnchor, constant: 10),
            weatherImgView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor)
        ])
        
        let contentContainerView = UIView()
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.backgroundColor = .white
        contentContainerView.layer.cornerRadius = 15
        thirdContainerView.addSubview(contentContainerView)
        
        // contentContainerView의 제약 조건 설정
        NSLayoutConstraint.activate([
//            contentContainerView.heightAnchor.constraint(equalToConstant: view.frame.height/1.5),
            contentContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            contentContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            contentContainerView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            contentContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
        
        contentTextView = UITextView()
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.textContainer.lineBreakMode = .byWordWrapping
        contentTextView.backgroundColor = .clear
        contentTextView.contentMode = .topLeft
        contentTextView.font = UIFont.boldSystemFont(ofSize: 15) // 폰트 크기 설정
        contentContainerView.addSubview(contentTextView)

        // contentTextField의 제약 조건 설정
        NSLayoutConstraint.activate([
            contentTextView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 10),
            contentTextView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -10),
            contentTextView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 10),
            contentTextView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -10),
            contentTextView.widthAnchor.constraint(lessThanOrEqualTo: contentContainerView.widthAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(lessThanOrEqualTo: contentContainerView.heightAnchor, constant: -20)
        ])
        
        // 마지막 페이지
        completeContainerView = UIView()
        completeContainerView.translatesAutoresizingMaskIntoConstraints = false
        completeContainerView.backgroundColor = yellowColor
        completeContainerView.isHidden = true
        view.addSubview(completeContainerView)

        // secondContainerView의 제약 조건 설정
        NSLayoutConstraint.activate([
            completeContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            completeContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            completeContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            completeContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
                                  
                                  
        guard let jsonPath = Bundle.main.path(forResource: "dancingDiary", ofType: "json") else {
            print("JSON file not found")
            return
        }

        // JSON 파일을 로드하여 애니메이션 뷰에 설정
        let animation = LottieAnimation.filepath(jsonPath)

        let dancingDiaryAnimationView = LottieAnimationView()
        dancingDiaryAnimationView.animation = animation

        // 애니메이션 재생
        dancingDiaryAnimationView.loopMode = .loop
        dancingDiaryAnimationView.animationSpeed = 1
        dancingDiaryAnimationView.play()

        dancingDiaryAnimationView.translatesAutoresizingMaskIntoConstraints = false
        completeContainerView.addSubview(dancingDiaryAnimationView)

        NSLayoutConstraint.activate([
            dancingDiaryAnimationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            dancingDiaryAnimationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            dancingDiaryAnimationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dancingDiaryAnimationView.widthAnchor.constraint(equalToConstant: 250),
            dancingDiaryAnimationView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
    }
}

extension DiaryContentViewController {
    @objc func moodTapped(_ sender: UITapGestureRecognizer) {
        guard let moodContainerView = sender.view else { return }
        // 클릭한 라벨의 텍스트를 clickedMood에 담기
        if let label = moodContainerView.subviews[1] as? UILabel {
            clickedMood = label.text ?? ""
            print(clickedMood)
        }

        // moodContainerView 확대/축소 애니메이션 적용
        UIView.animate(withDuration: 0.3) {
            self.resetMoodViews()
            moodContainerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05) // 1.05배 커짐
            moodContainerView.layer.shadowOpacity = 0.6 // 그림자 투명도 증가

            self.continueBtn.alpha = 1 // 계속 버튼 색깔 진하게
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.isEnabled = true
        }
    }

    // 모든 moodContainerView들을 원래 크기로 리셋
    func resetMoodViews() {
        for moodContainerView in moodViews {
            moodContainerView.transform = .identity
            moodContainerView.layer.shadowOpacity = 0.3
        }
    }
}

extension DiaryContentViewController {
    @objc func weatherTapped(_ sender: UITapGestureRecognizer) {
        guard let weatherContainerView = sender.view else { return }
        // 클릭한 라벨의 텍스트를 clickedMood에 담기
        if let label = weatherContainerView.subviews[1] as? UILabel {
            clickedWeather = label.text ?? ""
            print(clickedWeather)
        }

        // moodContainerView 확대/축소 애니메이션 적용
        UIView.animate(withDuration: 0.3) {
            self.resetWeatherViews()
            weatherContainerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05) // 1.05배 커짐
            weatherContainerView.layer.shadowOpacity = 0.6 // 그림자 투명도 증가

            self.continueBtn.alpha = 1 // 계속 버튼 색깔 진하게
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.isEnabled = true
        }
    }

    // 모든 moodContainerView들을 원래 크기로 리셋
    func resetWeatherViews() {
        for weatherContainerView in weatherViews {
            weatherContainerView.transform = .identity
            weatherContainerView.layer.shadowOpacity = 0.3
        }
    }
}

extension DiaryContentViewController {
    @objc func continueBtnClicked() {
        if continueBtn.isEnabled && continueBtn.isUserInteractionEnabled && viewCount == 1 {
            print("continueBtnClicked1")

            // firstContainerView 이동 애니메이션 적용
            UIView.animate(withDuration: 0.6, animations: {
                self.firstContainerView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            }) { (_) in
                self.firstContainerView.isHidden = true
                self.secondContainerView.isHidden = false
                self.animateSecondContainerView()
                
                self.continueBtn.isEnabled = false
                self.continueBtn.isUserInteractionEnabled = false
                self.continueBtn.alpha = 0.3 // 계속 버튼 색깔 연하게
                self.viewCount += 1
            }
        }
        
        if continueBtn.isEnabled && continueBtn.isUserInteractionEnabled && viewCount == 2 {
            print("continueBtnClicked2")

            // secondContainerView 이동 애니메이션 적용
            UIView.animate(withDuration: 0.6, animations: {
                self.secondContainerView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            }) { (_) in
                self.secondContainerView.isHidden = true
                self.thirdContainerView.isHidden = false
                self.animateThirdContainerView()
                
                self.continueBtn.isEnabled = false
                self.continueBtn.isUserInteractionEnabled = false
                self.continueBtn.alpha = 0.3 // 계속 버튼 색깔 연하게
                self.viewCount += 1
                
                self.changeViews()
                
            }
        }
        
        if continueBtn.isEnabled && continueBtn.isUserInteractionEnabled && viewCount == 3 {
            print("continueBtnClicked3")

            // secondContainerView 이동 애니메이션 적용
            UIView.animate(withDuration: 0.6, animations: {
                self.thirdContainerView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            }) { (_) in
                self.thirdContainerView.isHidden = true
                self.completeContainerView.isHidden = false
                self.animateThirdContainerView()
                self.viewCount += 1
            }
        }
    }
    
    // secondContainerView 등장 애니메이션 적용
    func animateSecondContainerView() {
        secondContainerView.alpha = 0
        secondContainerView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)

        UIView.animate(withDuration: 0.6, animations: {
            self.secondContainerView.alpha = 1
            self.secondContainerView.transform = .identity
        })
    }

    // thirdContainerView 등장 애니메이션 적용
    func animateThirdContainerView() {
        thirdContainerView.alpha = 0
        thirdContainerView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)

        UIView.animate(withDuration: 0.6, animations: {
            self.thirdContainerView.alpha = 1
            self.thirdContainerView.transform = .identity
        })
    }
}

// HEX 색상 코드를 사용하여 색상을 커스텀하기 위해 UIColor 클래스를 확장하여 사용
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var formattedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if formattedHex.count == 6 {
            formattedHex = "FF" + formattedHex
        }

        var rgbValue: UInt64 = 0
        Scanner(string: formattedHex).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension DiaryContentViewController {
    func requestWeather(latitude: Double, longitude: Double) {
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        AF.request(url).responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let celsiusValue = json["main"]["temp"].doubleValue - 273
                self.temperature = String(Int(celsiusValue))
                print(self.temperature)
                self.weatherLabel.text = "현재 기온 : " + (self.temperature ?? "") + "℃"
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

extension DiaryContentViewController: CLLocationManagerDelegate {
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

extension DiaryContentViewController {
    func changeViews(){
        self.dateLabel.text = selectedDate
        
        // mood, weather 이미지
        self.moodImg = UIImage(named: "mood\(moodArr.firstIndex(of: clickedMood)! + 1).png")!
        self.moodImgView.image = moodImg

        self.weatherImg = UIImage(named: "weather\(weatherArr.firstIndex(of: clickedWeather)! + 1).png")!
        self.weatherImgView.image = weatherImg
    }
}