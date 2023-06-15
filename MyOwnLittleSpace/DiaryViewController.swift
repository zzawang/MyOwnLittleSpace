//
//  DiaryViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/05/28.
//

import UIKit
import FSCalendar
import Lottie
import Foundation
import Firebase

class DiaryViewController: UIViewController {
    
    // 감정 단어들을 담을 배열
    var moodArr: [String] = ["행복", "사랑을 느낌", "평범함", "슬픔", "화남", "감동 받음", "월급날", "기분 최고", "킹받음", "난처함", "너무 웃김", "속상함", "정신없음", "빡공중", "해탈", "축하", "주눅", "못마땅", "머리 아픔", "졸림", "부끄러움", "아픔", "소름", "없음"]
    // 날씨 단어들을 담을 배열
    var weatherArr: [String] = ["날씨 좋음", "눈", "비", "태풍", "천둥 번개", "흐림", "폭염", "강추위"]
   
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var diaryContentView: UIView!
    
    @IBOutlet weak var noDiaryContainerView: UIView!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var addDiaryBtn: UIButton!
    
    @IBOutlet weak var diaryContainerView: UIView!
    @IBOutlet weak var moodImgExplainView: UIView!
    @IBOutlet weak var moodImgView: UIImageView!
    @IBOutlet weak var moodImgExplainLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var weatherImgExplainView: UIView!
    @IBOutlet weak var weatherCLabel: UILabel!
    @IBOutlet weak var weatherExplainLabel: UILabel!
    @IBOutlet weak var weatherImgView: UIImageView!
    
    @IBOutlet weak var lockImgView: UIImageView!
    @IBOutlet weak var lockAnimationView: LottieAnimationView!
    
    var dateFormatter:DateFormatter!
    var selectedDate:String = "" // 현재 선택된 날짜
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 대한민국 시간대 (Asia/Seoul)

        let formattedDate = dateFormatter.string(from: Date())
        selectedDate = formattedDate
        
        fetchFirestoreData(for: selectedDate)
        print(selectedDate)
    
        let image = UIImage(named: "mood2.png")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        moodImgView.image = image
        
        // Object들의 모서리 둥글기 설정
        diaryContentView.layer.cornerRadius = 15
        addDiaryBtn.layer.cornerRadius = 15
        moodImgExplainView.layer.cornerRadius = 10
        weatherImgExplainView.layer.cornerRadius = 10
        
        guard let jsonPath = Bundle.main.path(forResource: "addDiary", ofType: "json") else {
            print("JSON file not found")
            return
        }

        // JSON 파일을 로드하여 애니메이션 뷰에 설정
        let animation = LottieAnimation.filepath(jsonPath)
        animationView.animation = animation

        // 애니메이션 재생
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.play()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.scope = .week   // 범위를 주간으로 설정
//        calendarView.scope = .month  // 범위를 월간으로 설정
        calendarView.locale = Locale(identifier: "ko_KR") // 언어를 한국어로 설정
        calendarView.firstWeekday = 2  // 첫 열을 월요일로 설정
        calendarView.scrollDirection = .horizontal  // 스크롤 방향을 가로로
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20) // 헤더 크기 설정
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 14) // Weekday 크기 설정
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 14) // 각각의 일(날짜) 크기 설정
        calendarView.appearance.headerDateFormat = "MM월"  // 헤더의 날짜 포맷 설정
        calendarView.appearance.headerTitleAlignment = .center // 헤더의 폰트 정렬 설정
        calendarView.headerHeight = 50 // 헤더 높이 설정
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0 // 헤더 양 옆(전달 & 다음 달) 글씨 안 보이도록
        
        // lock을 클릭했을 때 내용이 안보이도록 lockImgView에 탭 제스처 등록
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(lockImgViewTapped(_:)))
        lockImgView.isUserInteractionEnabled = true // 사용자 상호작용 가능하도록 설정
        lockImgView.addGestureRecognizer(tapGesture)
    }
}

extension DiaryViewController{
    @objc func lockImgViewTapped(_ sender: UITapGestureRecognizer) {
        guard let lockImgView: UIImageView = sender.view as? UIImageView else { return }
        // lockImgView 이미지 교체 & 내용 가리기 애니메이션 적용
        UIView.animate(withDuration: 0.3) {
            // 현재 잠금 상태라면 잠금해제 후 내용 보이게 하기
            if lockImgView.image == UIImage(systemName: "eye.slash.fill") {
                let image = UIImage(systemName: "eye.fill")
                lockImgView.image = image
                
                self.lockAnimationView.isHidden = true
                self.contentView.isHidden = false
                self.moodImgExplainView.isHidden = false
                self.moodImgView.isHidden = false
                self.moodImgExplainLabel.isHidden = false
                self.weatherImgExplainView.isHidden = false
                self.weatherImgView.isHidden = false
            }
            // 현재 잠금 해제 상태라면 잠금 후 내용 숨기게 하기
            else {
                let image = UIImage(systemName: "eye.slash.fill")
                lockImgView.image = image
                
                self.contentView.isHidden = true
                self.moodImgExplainView.isHidden = true
                self.moodImgView.isHidden = true
                self.moodImgExplainLabel.isHidden = true
                self.weatherImgExplainView.isHidden = true
                self.weatherImgView.isHidden = true
                
                guard let jsonPath = Bundle.main.path(forResource: "Lock", ofType: "json") else {
                    return
                }

                // JSON 파일을 로드하여 락 애니메이션 뷰에 설정
                let animation = LottieAnimation.filepath(jsonPath)
                self.lockAnimationView.animation = animation

                // 애니메이션 재생
                self.lockAnimationView.loopMode = .playOnce
                self.lockAnimationView.animationSpeed = 1
                self.lockAnimationView.isHidden = false
                self.lockAnimationView.play()
            }
        }
    }
}

extension DiaryViewController{
    // 기록 열매 심기 버튼 클릭시 performSegue 동작
    @IBAction func addDiary(_ sender: UIButton) {
        performSegue(withIdentifier: "addDiaryContent", sender: self)
    }
}

extension DiaryViewController{     // PlanGroupViewController.swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addDiaryContent"{
            let diaryContentViewController = segue.destination as! DiaryContentViewController
            diaryContentViewController.selectedDate = self.selectedDate
        }
    }
}

extension DiaryViewController: FSCalendarDelegate, FSCalendarDataSource{
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formattedDate = dateFormatter.string(from: date)
        selectedDate = formattedDate
        print(selectedDate)
        
        fetchFirestoreData(for: selectedDate)
    }
        
    // 스와이프로 월이 변경되면 호출된다
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
    }
        
    // 이함수를 fsCalendar.reloadData()에 의하여 모든 날짜에 대하여 호출된다.
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        
        return nil
    }
}

extension DiaryViewController {
    
    func fetchFirestoreData(for date: String) {
        let db = Firestore.firestore()
        let diaryCollection = db.collection("Diary")
        
        diaryCollection.document(date).getDocument { [self] document, error in
            if let document = document, document.exists {
                noDiaryContainerView.isHidden = true
                diaryContainerView.isHidden = false
                let data = document.data()
                
                if let content = data?["content"] as? String,
                   let mood = data?["mood"] as? String,
                   let weather = data?["weather"] as? String,
                   let temperature = data?["temperature"] as? String{
                    let content = content
                    let mood = mood
                    let weather = weather
                    let temperature = temperature
                    
                    let moodImg = UIImage(named: "mood\(self.moodArr.firstIndex(of: mood)! + 1).png")!
                    let weatherImg = UIImage(named: "weather\(self.weatherArr.firstIndex(of: weather)! + 1).png")!
                   
                    DispatchQueue.main.async {
                        self.moodImgExplainLabel.text = mood
                        self.weatherExplainLabel.text = weather
                        self.contentLabel.text = content
                        self.weatherCLabel.text = temperature
                        
                        self.moodImgView.image = moodImg
                        self.weatherImgView.image = weatherImg
                    }
                }
            } else {
                noDiaryContainerView.isHidden = false
                diaryContainerView.isHidden = true
            }
        }
    }
}
