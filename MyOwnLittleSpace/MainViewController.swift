//
//  MainViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/05/28.
//

import UIKit
import Lottie
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet weak var animationContainerView: UIView!
    @IBOutlet weak var animationView: LottieAnimationView!
    
    @IBOutlet weak var diaryCount: UILabel!
    @IBOutlet weak var diaryLevel: UILabel!
    
    let jsonPath1 = Bundle.main.path(forResource: "plant1", ofType: "json")
    let jsonPath2 = Bundle.main.path(forResource: "plant2", ofType: "json")
    let jsonPath3 = Bundle.main.path(forResource: "plant3", ofType: "json")
    let jsonPath4 = Bundle.main.path(forResource: "plant4", ofType: "json")
    let jsonPath5 = Bundle.main.path(forResource: "plant5", ofType: "json")
    
    var docCount:Int = 0 // Document 개수
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationContainerView.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDocCount() // Document 개수 가져오기
    }
}

extension MainViewController{
    func updateAnimation() {
        diaryCount.text = String(docCount)
        
        // 다이어리 개수에 따라 식물 애니메이션 변경 (시연 영상을 위해 개수의 기준을 줄임)
        if docCount >= 0 && docCount < 2 {  // 다이어리가 0개 or 1개 일때
            // diaryLevel 설정
            diaryLevel.text = "Lv.1"
            
            // JSON 파일을 로드하여 애니메이션 뷰에 설정
            animationView.animation = LottieAnimation.filepath(jsonPath1!)

            // 애니메이션 재생
            animationView.loopMode = .playOnce
            animationView.animationSpeed = 0.3
            animationView.play()
        }
        else if docCount >= 2 && docCount < 3 {  // 다이어리가 2개 일때
            // diaryLevel 설정
            diaryLevel.text = "Lv.2"
            
            // JSON 파일을 로드하여 애니메이션 뷰에 설정
            animationView.animation = LottieAnimation.filepath(jsonPath2!)

            // 애니메이션 재생
            animationView.loopMode = .playOnce
            animationView.animationSpeed = 0.6
            animationView.play()
        }
        else if docCount >= 3 && docCount < 4 {  // 다이어리가 3개 일때
            // diaryLevel 설정
            diaryLevel.text = "Lv.3"
            
            // JSON 파일을 로드하여 애니메이션 뷰에 설정
            animationView.animation = LottieAnimation.filepath(jsonPath3!)

            // 애니메이션 재생
            animationView.loopMode = .playOnce
            animationView.animationSpeed = 0.7
            animationView.play()
        }
        else if docCount >= 4 && docCount < 5 {  // 다이어리가 4개 일때
            // diaryLevel 설정
            diaryLevel.text = "Lv.4"
            
            // JSON 파일을 로드하여 애니메이션 뷰에 설정
            animationView.animation = LottieAnimation.filepath(jsonPath4!)

            // 애니메이션 재생
            animationView.loopMode = .playOnce
            animationView.animationSpeed = 0.8
            animationView.play()
        }
        else if docCount >= 5 && docCount < 6 {  // 다이어리가 5개 일때
            // diaryLevel 설정
            diaryLevel.text = "Lv.5"
            
            // JSON 파일을 로드하여 애니메이션 뷰에 설정
            animationView.animation = LottieAnimation.filepath(jsonPath5!)

            // 애니메이션 재생
            animationView.loopMode = .playOnce
            animationView.animationSpeed = 1
            animationView.play()
        }
    }
}


extension MainViewController {
    func getDocCount(){
        let collectionRef = Firestore.firestore().collection("Diary")

        collectionRef.getDocuments { [self] (snapshot, error) in
            if error != nil {
                print("Document를 가져오는 중 에러 발생")
            } else {
                if let snapshot = snapshot {
                    docCount = snapshot.documents.count
                    updateAnimation() // 애니메이션 업데이트
                }
            }
        }
    }
}
