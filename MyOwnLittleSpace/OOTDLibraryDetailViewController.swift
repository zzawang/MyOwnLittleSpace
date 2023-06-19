//
//  OOTDLibraryDetailViewController.swift
//  MyOwnLittleSpace
//
//  Created by 최호빈 on 2023/06/18.
//

import UIKit
import FirebaseStorage

class OOTDLibraryDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var folderName: String = ""
    var activityIndicator: UIActivityIndicatorView!  // 로딩 화면으로 사용할 인디케이터
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이미지뷰 사이의 간격
        let imageViewSpacing: CGFloat = 10.0
        // 이미지뷰의 크기 (한 줄에 3개의 이미지뷰 + 4개의 이미지뷰 사이의 간격이 포함되므로 view의 크기에 맞게 imageSize를 설정해준다)
        let imageSize = (view.frame.width - imageViewSpacing * 4)/3
        
        // 로딩 화면에 사용할 인디케이터 초기화
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        // 인디케이터 시작
        activityIndicator.startAnimating()
        
        let storageRef = Storage.storage().reference()
        let folderRef = storageRef.child(folderName)
        
        folderRef.listAll { (result, error) in
            if error != nil {
                print("이미지를 가져오던 중 에러 발생")
                return
            }
            
            if result!.items.isEmpty {
                // 이미지가 없는 경우 로딩 화면을 숨기고 이미지 없음을 알림
                self.activityIndicator.stopAnimating()
                return
            }
            
            // 가져온 이미지 파일 목록을 최근 업로드한 순서대로 정렬
            let sortedItems = result!.items.sorted { $0.name > $1.name }
            
            // 스크롤 뷰 안에 이미지뷰가 한 줄에 3개씩 생성되고 나열되도록 설정
            DispatchQueue.main.async { [self] in
                var row: Int = 0
                var column: Int = 0
                
                for (index, imageRef) in sortedItems.enumerated() {
                    // 이미지뷰 생성
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    scrollView.addSubview(imageView)
                    
                    // 각 이미지뷰의 위치를 설정
                    let x = CGFloat(column) * (imageSize + imageViewSpacing)
                    let y = CGFloat(row) * (imageSize + imageViewSpacing)
    
                    // 이미지뷰의 제약 조건 설정
                    NSLayoutConstraint.activate([
                        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: x),
                        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: y),
                        imageView.widthAnchor.constraint(equalToConstant: imageSize),
                        imageView.heightAnchor.constraint(equalToConstant: imageSize)
                    ])
                    
                    column += 1 // 이미지뷰를 scrollView에 삽입할 때마다 증가
                    
                    // 한 줄에 이미지뷰가 3개 들어왔으면 다음 줄에 들어가도록 row 증가시킴
                    if column >= 3 {
                        row += 1
                        column = 0
                    }
                    
                    imageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("이미지 다운로드 중 에러 발생")
                            return
                        }
                        
                        if let imageData = data, let image = UIImage(data: imageData) {
                            DispatchQueue.main.async { [self] in
                                imageView.image = image  // 이미지 뷰에 이미지 설정
                                
                                // 이미지를 탭했을 때 이미지 확대 보기 설정
                                imageView.isUserInteractionEnabled = true
                                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImage(_:)))
                                imageView.addGestureRecognizer(tapGesture)
                                
                                // 모든 이미지 로딩이 완료되었을 때 인디케이터 숨김
                                if index == sortedItems.count - 1 {
                                    activityIndicator.stopAnimating()
                                    
                                    // scrollView 사이즈를 이미지뷰의 개수에 맞게 설정
                                    let contentHeight = CGFloat(row + 1) * (imageSize + imageViewSpacing)
                                    scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension OOTDLibraryDetailViewController {
    @objc func showImage(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            let image = imageView.image
            
            // 이미지 확대 보기를 위한 이미지 뷰 생성
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.backgroundColor = UIColor(white: 0, alpha: 0.7) // 반투명한 배경 설정
            
            // 이미지 뷰를 전체 화면에 표시
            imageView.frame = UIScreen.main.bounds
            imageView.isUserInteractionEnabled = true
            imageView.layer.opacity = 0.0  // 서서히 나타나는 애니메이션 효과를 주도록 처음엔 투명도를 0으로 설정
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideImage(_:)))
            imageView.addGestureRecognizer(tapGesture)
            
            // 이미지 뷰를 현재의 뷰 컨트롤러에 추가
            self.view.addSubview(imageView)
            
            UIView.animate(withDuration: 0.3, animations: {
                imageView.layer.opacity = 1.0 // 이미지뷰가 서서히 나타남
            })
        }
    }
        
    @objc func hideImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
}
