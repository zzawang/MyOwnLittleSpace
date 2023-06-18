//
//  OOTDLibraryViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/06/18.
//

import UIKit

class OOTDLibraryViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set corner radius for subviews in stack view
        for subview in stackView.subviews {
            if let button = subview as? UIButton {
                button.layer.cornerRadius = 15
                button.layer.masksToBounds = true
            }
        }
        backBtn.layer.cornerRadius = 15
    }
}

extension OOTDLibraryViewController{
    @IBAction func btn1Clicked(_ sender: UIButton) {
        
    }
    
    @IBAction func btn2Clicked(_ sender: UIButton) {
        
    }
    
    @IBAction func btn3Clicked(_ sender: UIButton) {
        
    }
    
    @IBAction func btn4Clicked(_ sender: UIButton) {
        
    }
    
    @IBAction func btn5Clicked(_ sender: UIButton) {
        
    }
    
    @IBAction func btn6Clicked(_ sender: UIButton) {
        
    }
}

extension OOTDLibraryViewController{
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
