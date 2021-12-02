//
//  PhotoViewerVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-30.
//

import UIKit
import SDWebImage

class PhotoViewerVC: UIViewController {

    private let url: URL
    
    private let imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(imageView)
        imageView.sd_setImage(with: url, completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
}
