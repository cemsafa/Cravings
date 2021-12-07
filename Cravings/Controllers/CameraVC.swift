//
//  CameraVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import YPImagePicker
import JGProgressHUD

class CameraVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    var selectedMedia = [YPMediaItem]()
    
    var totalCount: Int {
        selectedMedia.count
    }
    
    var cellWidth: CGFloat {
        return totalCount > 2 ? view.frame.width / 3 : view.frame.width
    }
    
    var cellHeight: CGFloat {
        switch totalCount {
        case 1:
            return collectionView.frame.height
        case 2:
            return collectionView.frame.height / 2
        default:
            return view.frame.width / 3
        }
    }
    
    var cellSize: CGSize {
        print("\(cellWidth) \(cellHeight)")
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextField.delegate = self
        collectionView.register(UINib.init(nibName: "AddPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddPostCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func updateUI() {
        postButton.isHidden = selectedMedia.isEmpty
        closeButton.isHidden = selectedMedia.isEmpty
    }
    
    func restUI() {
        self.selectedMedia = [YPMediaItem]()
        updateUI()
        self.collectionView.reloadData()
    }
    
    func reloadUI() {
        updateUI()
        self.collectionView.reloadData()
    }
    
    func showImagePicker() {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 10
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            self.selectedMedia = items
            self.reloadUI()
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    func showVideoPicker() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .video]
        config.library.maxNumberOfItems = 5
        config.library.mediaType = .video
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            self.selectedMedia = items
            self.reloadUI()
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        showImagePicker()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        restUI()
    }
    
    @IBAction func videoButtonClicked(_ sender: Any) {
        showVideoPicker()
    }
   
    @IBAction func postButtonClicked(_ sender: Any) {
        addPost()
    }
    
    var postMedia: [PostMedia] {
        var media = [PostMedia]()
        for selectMedia in selectedMedia {
            switch selectMedia {
            case .photo(let p):
                if let data = p.image.jpegData(compressionQuality: 1.0) {
                    media.append(PostMedia(mediaType: .photo, data: data))
                }
            case .video(_):
                break
            }
        }
        return media
    }
    
    func addPost() {
        spinner.show(in: view)
        let post = Post(usersTagged: [String](), media: [String](), likedUsers: [String](), caption: captionTextField.text ?? "", time: timeStamp)
        StorageManager.shared.addPost(with: post, media: postMedia) { result in
            switch result {
                case .success(_):
                    self.spinner.dismiss()
                    self.reloadUI()
                    self.tabBarController?.selectedIndex = 0
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "",preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension CameraVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

extension CameraVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPostCollectionViewCell", for: indexPath) as! AddPostCollectionViewCell
        let mediaItem = selectedMedia[indexPath.row]
        switch mediaItem {
            case .photo(let photo):
                cell.image = photo.image
            case .video(let video):
                cell.videoURL = video.url
                print(video)
            }
        return cell
    }
    
}
