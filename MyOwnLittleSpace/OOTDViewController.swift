//
//  OOTDViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/06/18.
//

import UIKit
import FirebaseStorage

class OOTDViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takeAgainBtn: UIButton!
    @IBOutlet weak var savePhotoBtn: UIButton!

    var image:UIImage!
    var selectedDate: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image  // 이미지 뷰에 이미지 설정
        
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
        // Firebase Storage의 레퍼런스 생성
        let storageRef = Storage.storage().reference()
            
        // 업로드할 이미지의 파일명 설정
        let filename = "\(selectedDate + UUID().uuidString).jpg"
        
        // 업로드할 이미지의 데이터 변환
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            // 이미지 데이터 변환 실패 시 에러 처리
            print("Failed to convert image to data")
            return
        }
            
        // 업로드할 이미지 파일의 경로 설정
        let imageRef = storageRef.child(filename)
            
        // 이미지 파일 업로드
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                // 업로드 실패 시 에러 처리
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }
                
            // 업로드 성공 시 처리할 로직 추가
            print("Image uploaded successfully!")
            self.dismiss(animated: true)
            
            // 애니메이션 추가하기
                
            // 업로드된 이미지의 다운로드 URL 가져오기
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    // 다운로드 URL 가져오기 실패 시 에러 처리
                    print("Failed to get download URL: \(error.localizedDescription)")
                    return
                }
                
                // 다운로드 URL 성공 시 처리할 로직 추가
                if let downloadURL = url {
                    print("Download URL: \(downloadURL.absoluteString)")
                }
            }
        }
    }
}

extension OOTDViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = img
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
