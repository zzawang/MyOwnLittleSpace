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
    
    var folderName:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // stackView안에 있는 버튼들의 둥글기 설정
        for subview in stackView.subviews {
            if let button = subview as? UIButton {
                button.layer.cornerRadius = 15
                button.layer.masksToBounds = true
            }
        }
        // 돌아가기 버튼의 둥글기 설정
        backBtn.layer.cornerRadius = 15
    }
}

// 각 버튼에 맞게 폴더명 생성 후 ootdLibraryDetailViewController로 폴더명 전달 & 이동
extension OOTDLibraryViewController{
    @IBAction func btn1Clicked(_ sender: UIButton) {
        makeFoloderName(temperature: 24)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
    }
    
    @IBAction func btn2Clicked(_ sender: UIButton) {
        makeFoloderName(temperature: 23)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
    }
    
    @IBAction func btn3Clicked(_ sender: UIButton) {
        makeFoloderName(temperature: 19)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
    }
    
    @IBAction func btn4Clicked(_ sender: UIButton) {
        makeFoloderName(temperature: 16)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
    }
    
    @IBAction func btn5Clicked(_ sender: UIButton) {
        makeFoloderName(temperature: 9)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
    }
    
    @IBAction func btn6Clicked(_ sender: UIButton) {
        makeFoloderName(temperature: 5)
        performSegue(withIdentifier: "showLibraryDetail", sender: self)
    }
}

extension OOTDLibraryViewController{
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension OOTDLibraryViewController {
    func makeFoloderName(temperature: Int) -> Void {
        if temperature >= 24 {
            folderName = "24over"
        }
        else if temperature >= 20 && temperature <= 23 {
            folderName = "20and23"
        }
        else if temperature >= 17 && temperature <= 19 {
            folderName = "17and19"
        }
        else if temperature >= 10 && temperature <= 16 {
            folderName = "10and16"
        }
        else if temperature >= 6 && temperature <= 9 {
            folderName = "6and9"
        }
        else {
            folderName = "5under"
        }
    }
}

extension OOTDLibraryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLibraryDetail" {
            guard let ootdLibraryDetailViewController = segue.destination as? OOTDLibraryDetailViewController else {
                return
            }
            ootdLibraryDetailViewController.folderName = folderName
        }
    }
}
