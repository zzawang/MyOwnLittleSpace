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
    @IBOutlet weak var todayIsLabel: UILabel!
    @IBOutlet weak var moodImgExplainLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var weatherImgExplainView: UIView!
    @IBOutlet weak var weatherCLabel: UILabel!
    @IBOutlet weak var weatherExplainLabel: UILabel!
    @IBOutlet weak var weatherImgView: UIImageView!
    
    @IBOutlet weak var lockImgView: UIImageView!
    @IBOutlet weak var lockAnimationView: LottieAnimationView!
    
    @IBOutlet weak var trashImgView: UIImageView!
    @IBOutlet weak var modifyImgView: UIImageView!
    
    var dateFormatter:DateFormatter!
    var selectedDate:String = "" // 현재 선택된 날짜
    
    let greenColor = UIColor(hex: "#008F00") // 커스텀한 색상 정의
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일" // 년, 월, 일로 포맷 지정
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 대한민국 시간대 (Asia/Seoul)

        // 현재 날짜를 selectedDate에 넣기
        selectedDate = dateFormatter.string(from: Date())
        
        // FireStore에서 데이터 가져오기
        fetchFirestoreData(for: selectedDate)
        
        // Object들의 모서리 둥글기 설정
        diaryContentView.layer.cornerRadius = 15
        addDiaryBtn.layer.cornerRadius = 15
        moodImgExplainView.layer.cornerRadius = 10
        weatherImgExplainView.layer.cornerRadius = 10
        
        let contentTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        contentTextView.addGestureRecognizer(contentTapGesture)
        
        // JSON 파일
        guard let jsonPath = Bundle.main.path(forResource: "addDiary", ofType: "json") else {
            print("JSON file not found")
            return
        }

        // JSON 파일을 로드하여 애니메이션 뷰에 설정
        animationView.animation = LottieAnimation.filepath(jsonPath)

        // 애니메이션 재생
        animationView.loopMode = .loop  // 애니메이션 반복 재생
        animationView.animationSpeed = 1
        animationView.play()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.scope = .week   // 범위를 주간으로 설정
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
        
        // lockImgView를 클릭했을 때 내용이 안보이도록 lockImgView에 탭 제스처 등록
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(lockImgViewTapped(_:)))
        lockImgView.isUserInteractionEnabled = true // 사용자 상호작용 가능하도록 설정
        lockImgView.addGestureRecognizer(tapGesture1)
        
        // modifyImgView를 클릭했을 때 내용이 수정되도록 lockImgView에 탭 제스처 등록
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(modifyImgViewTapped(_:)))
        modifyImgView.isUserInteractionEnabled = true // 사용자 상호작용 가능하도록 설정
        modifyImgView.addGestureRecognizer(tapGesture2)
        
        // trashImgView를 클릭했을 때 내용이 삭제되도록 lockImgView에 탭 제스처 등록
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(trashImgViewTapped(_:)))
        trashImgView.isUserInteractionEnabled = true // 사용자 상호작용 가능하도록 설정
        trashImgView.addGestureRecognizer(tapGesture3)
    }
}

extension DiaryViewController{
    @objc func lockImgViewTapped(_ sender: UITapGestureRecognizer) {
        guard let lockImgView: UIImageView = sender.view as? UIImageView else { return }
        // lockImgView 이미지 교체 & 내용 가리기 애니메이션 적용
        UIView.animate(withDuration: 0.3) { [self] in
            // 현재 잠금 상태라면 잠금해제 후 내용 보이게 하기
            if lockImgView.image == UIImage(systemName: "eye.slash.fill") {
                lockImgView.image = UIImage(systemName: "eye.fill")
                
                lockAnimationView.isHidden = true
                contentView.isHidden = false
                moodImgExplainView.isHidden = false
                moodImgView.isHidden = false
                moodImgExplainLabel.isHidden = false
                weatherImgExplainView.isHidden = false
                weatherImgView.isHidden = false
                trashImgView.isHidden = false
                modifyImgView.isHidden = false
            }
            else { // 현재 잠금 해제 상태라면 잠금 후 내용 숨기게 하기
                lockImgView.image = UIImage(systemName: "eye.slash.fill")
                
                contentView.isHidden = true
                moodImgExplainView.isHidden = true
                moodImgView.isHidden = true
                moodImgExplainLabel.isHidden = true
                weatherImgExplainView.isHidden = true
                weatherImgView.isHidden = true
                trashImgView.isHidden = true
                modifyImgView.isHidden = true
                
                // JSON 파일
                guard let jsonPath = Bundle.main.path(forResource: "Lock", ofType: "json") else {
                    return
                }

                // JSON 파일을 로드하여 lockAnimationView에 설정
                lockAnimationView.animation = LottieAnimation.filepath(jsonPath)
                
                lockAnimationView.isHidden = false

                // 애니메이션 재생
                lockAnimationView.loopMode = .playOnce  // 애니메이션 한 번만 재생
                lockAnimationView.animationSpeed = 1
                lockAnimationView.play()
            }
        }
    }
}

extension DiaryViewController {
    @objc func modifyImgViewTapped(_ sender: UITapGestureRecognizer) {
        // 애니메이션 적용
        UIView.animate(withDuration: 0.2, animations: { [self] in
            modifyImgView.alpha = 0.0
        }, completion: { [self] _ in
            if modifyImgView.image == UIImage(systemName: "pencil") {
                modifyImgView.tintColor = greenColor
                modifyImgView.image = UIImage(systemName: "checkmark")
                contentTextView.isSelectable = true
                contentTextView.isEditable = true
                contentTextView.tintColor = .black
                contentTextView.becomeFirstResponder()  // 커서 깜빡이도록
            }
            else{
                modifyImgView.tintColor = .darkGray
                modifyImgView.image = UIImage(systemName: "pencil")
                contentTextView.isSelectable = false
                contentTextView.isEditable = false
                
                // 새로 작성한 다이어리 내용을 Firestore에 업데이트
                let updateContent:String = contentTextView.text
                let documentRef = Firestore.firestore().collection("Diary").document(selectedDate)

                documentRef.updateData(["content": updateContent]) { error in
                    if error != nil {
                        print("다이어리 내용 업데이트 중 에러 발생")
                    } else {
                        print("다이어리 내용 업데이트 성공")
                    }
                }
            }
            UIView.animate(withDuration: 0.2) { [self] in
                modifyImgView.alpha = 1.0
            }
        })
    }
}

extension DiaryViewController {
    @objc func trashImgViewTapped(_ sender: UITapGestureRecognizer) {
        let documentRef = Firestore.firestore().collection("Diary").document(selectedDate)

        // Document 삭제
        documentRef.delete { error in
            if error != nil { // 실패
                print("다이어리 내용 삭제 중 에러 발생")
            } else { // 성공 & 애니메이션 적용
                UIView.animate(withDuration: 0.3, animations: { [self] in
                    diaryContainerView.alpha = 0.0
                }, completion: { [self] _ in
                    diaryContainerView.isHidden = true
                    noDiaryContainerView.alpha = 0.0
                    noDiaryContainerView.isHidden = false

                    UIView.animate(withDuration: 0.3) { [self] in
                        noDiaryContainerView.alpha = 1.0
                    }
                })
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

extension DiaryViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addDiaryContent"{
            let diaryContentViewController = segue.destination as! DiaryContentViewController
            // diaryContentViewController의 selectedDate로 지정
            diaryContentViewController.selectedDate = self.selectedDate
            // diaryContentViewController의 delegate를 self로 지정
            diaryContentViewController.delegate = self
        }
    }
}

extension DiaryViewController: FSCalendarDelegate, FSCalendarDataSource{
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = dateFormatter.string(from: date)
        fetchFirestoreData(for: selectedDate)  // 현재 선택된 날짜의 데이터를 Firestore에서 가져오기
    }
}

extension DiaryViewController {
    func fetchFirestoreData(for date: String) {
        let diaryCollection = Firestore.firestore().collection("Diary")
        
        diaryCollection.document(date).getDocument { [self] document, error in
            if let document = document, document.exists { // 데이터가 존재하면
                let data = document.data()
                
                if let content = data?["content"] as? String,
                   let mood = data?["mood"] as? String,
                   let weather = data?["weather"] as? String,
                   let temperature = data?["temperature"] as? String{
                    let content = content
                    let mood = mood
                    let weather = weather
                    let temperature = temperature
                    
                    didUpdateDiaryContent(content: content, mood: mood, weather: weather, temperature: temperature)
                }
            } else { // 데이터가 존재하지 않으면
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    diaryContainerView.alpha = 0.0
                }, completion: { [self] _ in
                    diaryContainerView.isHidden = true
                    noDiaryContainerView.alpha = 0.0
                    noDiaryContainerView.isHidden = false

                    UIView.animate(withDuration: 0.1) { [self] in
                        noDiaryContainerView.alpha = 1.0
                    }
                })
            }
        }
    }
}

protocol DiaryViewControllerDelegate: AnyObject {
    func didUpdateDiaryContent(content: String, mood: String, weather: String, temperature: String)
}

extension DiaryViewController: DiaryViewControllerDelegate {
    // Firestore에서 가져온 데이터를 화면에 보여준다.
    func didUpdateDiaryContent(content: String, mood: String, weather: String, temperature: String) {
        let moodImg = UIImage(named: "mood\(self.moodArr.firstIndex(of: mood)! + 1).png")!
        let weatherImg = UIImage(named: "weather\(self.weatherArr.firstIndex(of: weather)! + 1).png")!
       
        // 다이어리 내용이 보여질 때의 애니메이션
        DispatchQueue.main.async { [self] in
            UIView.animate(withDuration: 0.1, animations: { [self] in
                noDiaryContainerView.alpha = 0.0
            }, completion: { [self] _ in
                noDiaryContainerView.isHidden = true
                todayIsLabel.text = "오늘 하루는 "
                moodImgExplainLabel.text = mood
                weatherExplainLabel.text = weather
                contentTextView.text = content
                weatherCLabel.text = temperature + "도, "
                moodImgView.image = moodImg
                weatherImgView.image = weatherImg
                
                UIView.animate(withDuration: 0.1) { [self] in
                    diaryContainerView.alpha = 1.0
                    diaryContainerView.isHidden = false
                }
            })
        }
    }
}

// contentTextView를 터치할 때 키보드가 나타나거나 사라지도록 설정
extension DiaryViewController{
    @objc func dismissKeyboard(sender: UITapGestureRecognizer){
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        }
        else{
            contentTextView.becomeFirstResponder()
        }
    }
}
