//
//  CameraVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import YPImagePicker

class CameraVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
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
    }
    
    func updateUI() {
        postButton.isHidden = selectedMedia.isEmpty
        closeButton.isHidden = selectedMedia.isEmpty
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
        selectedMedia = [YPMediaItem]()
        self.reloadUI()
    }
    
    @IBAction func videoButtonClicked(_ sender: Any) {
        showVideoPicker()
    }
   
    @IBAction func postButtonClicked(_ sender: Any) {
        // upload with caption
        self.tabBarController?.selectedIndex = 0
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
