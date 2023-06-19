//
//  TabBarController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/05/28.
//

import UIKit
import Lottie

class TabBarController: UITabBarController {
    var animationView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Launch되는 동안 실행할 애니메이션 지정
        animationView = LottieAnimationView(name: "launchGIF")
        animationView.backgroundColor = .white
        animationView.frame = view.bounds
        animationView.center = view.center  // 애니메이션을 뷰의 정가운데로
        animationView.alpha = 1
        animationView.animationSpeed = 1
        view.addSubview(animationView)

        // 애니메이션의 구간과 시간을 지정
        animationView.play(fromProgress: 0.3, toProgress: 0.9) { _ in
            UIView.animate(withDuration: 0.3, animations: { [self] in
                animationView.alpha = 0
            }, completion: { [self] _ in
                // 애니메이션이 끝나면 사라지도록
                animationView.isHidden = true
                animationView.removeFromSuperview()
            })
        }
    }

}
