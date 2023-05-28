//
//  TabBarController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/05/28.
//

import UIKit
import Lottie

class TabBarController: UITabBarController {

    private let animationView: LottieAnimationView = {
        let lottieAnimationView = LottieAnimationView(name: "launchGIF")
        lottieAnimationView.backgroundColor = .white
        return lottieAnimationView
    }()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(animationView)

        animationView.frame = view.bounds
        animationView.center = view.center
        animationView.alpha = 1
        animationView.animationSpeed = 1

        animationView.play(fromProgress: 0.3, toProgress: 0.9) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.animationView.alpha = 0
            }, completion: { _ in
                self.animationView.isHidden = true
                self.animationView.removeFromSuperview()
            })
        }
    }

}
