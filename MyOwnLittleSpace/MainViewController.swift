//
//  MainViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/05/28.
//

import UIKit
import Lottie

class MainViewController: UIViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // JSON 파일 경로
        guard let jsonPath = Bundle.main.path(forResource: "plant5", ofType: "json") else {
            print("JSON file not found")
            return
        }

        // JSON 파일을 로드하여 애니메이션 뷰에 설정
        let animation = LottieAnimation.filepath(jsonPath)
        animationView.animation = animation

        // 애니메이션 재생
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.4
        animationView.play()
    }
}
