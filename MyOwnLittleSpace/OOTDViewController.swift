//
//  OOTDViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/06/18.
//

import UIKit
import FirebaseStorage
import Lottie

class OOTDViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var takeAgainBtn: UIButton!
    @IBOutlet weak var savePhotoBtn: UIButton!

    var image:UIImage!
    var temperature: String = ""  // 현재 기온을 담을 변수
    var nowDate:String = ""
    var dateFormatter:DateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss" // 이미지 파일 이름에 들어갈 날짜의 포맷
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 대한민국 시간대 (Asia/Seoul)

        // 현재 날짜 & 시간
        nowDate = dateFormatter.string(from: Date())
        
        imageView.image = image  // 이미지 뷰에 이미지 설정
        
        // Object들의 모서리 둥글기 설정
        takeAgainBtn.layer.cornerRadius = 15
        savePhotoBtn.layer.cornerRadius = 15
    }
}

extension OOTDViewController{
    @IBAction func takeAgain(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController() // 컨트롤러를 생성한다.
        imagePickerController.delegate = self // 이 딜리게이터를 설정하면 사진을 찍은후 호출된다
        imagePickerController.sourceType = .camera
        
        // UIImagePickerController가 활성화
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension OOTDViewController{
    @IBAction func savePhoto(_ sender: Any) {
        // 저장할 때 애니메이션이 실행되는 동안 다른 버튼이 눌려지지 않도록
        savePhotoBtn.isEnabled = false
        savePhotoBtn.isUserInteractionEnabled = false
        takeAgainBtn.isEnabled = false
        takeAgainBtn.isUserInteractionEnabled = false
        
        // Firebase Storage의 루트 레퍼런스 가져오기
        let storageRef = Storage.storage().reference()

        // 온도에 맞게 폴더 이름 생성
        let folderName: String = makeFoloderName(temp: temperature)
        
        // 최근 업로드 순서대로 가져올 수 있도록 업로드할 이미지의 파일명을 날짜 + UUID 로 설정
        let filename = nowDate + "\(UUID().uuidString).jpg"

        // 업로드할 이미지의 데이터 변환
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("이미지 데이터 변환 실패")
            return
        }

        // 업로드할 이미지 파일의 경로 설정
        let folderRef = storageRef.child(folderName)
        let imageRef = folderRef.child(filename)

        // 이미지 파일 업로드
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil {
                print("이미지 파일 업로드 실패")
                return
            }
        }
        
        // 이미지 업로드 하는 동안 보여줄 애니메이션 JSON 파일
        guard let jsonPath = Bundle.main.path(forResource: "savePhoto", ofType: "json") else {
            print("JSON file not found")
            return
        }

        // JSON 파일을 로드하여 애니메이션 뷰에 설정
        animationView.animation = LottieAnimation.filepath(jsonPath)

        // 애니메이션 재생
        animationView.loopMode = .playOnce  // 애니메이션 한 번만 재생
        animationView.animationSpeed = 1.3  // 애니메이션 속도 조절
        
        // 애니메이션이 끝난 후에 실행될 코드
        let animationCompletionBlock: LottieCompletionBlock = { [self] _ in
            // 버튼 다시 활성화
            savePhotoBtn.isEnabled = true
            savePhotoBtn.isUserInteractionEnabled = true
            takeAgainBtn.isEnabled = true
            takeAgainBtn.isUserInteractionEnabled = true
            self.dismiss(animated: true) // 애니메이션 종료 후 화면 닫기
        }

        // 애니메이션 재생 및 완료 콜백 설정
        animationView.play(completion: animationCompletionBlock)
    }
}

extension OOTDViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = img
            // 이미지 뷰에 이미지 설정
            imageView.image = image
        }
        // imagePickerController를 닫고, 이후에 OOTDViewController를 표시
        picker.dismiss(animated: true) {
        }
    }

    // 사진 캡쳐를 취소하는 경우 호출 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // imagePickerController을 죽인다
        picker.dismiss(animated: true, completion: nil)
    }
}

extension OOTDViewController {
    func makeFoloderName(temp: String) -> String {
        let temperature:Int = Int(temp)!
        var folderName:String = ""
        
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
        return folderName
    }
}
