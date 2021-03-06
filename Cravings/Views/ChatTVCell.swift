//
//  ChatTVCell.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-25.
//

import UIKit
import SDWebImage

class ChatTVCell: UITableViewCell {

    static let identifier = "ChatTVCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLbl)
        contentView.addSubview(userMessageLbl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLbl.frame = CGRect(x: userImageView.right + 10, y: 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height)/2)
        userMessageLbl.frame = CGRect(x: userImageView.right + 10, y: userNameLbl.bottom + 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height)/2)
    }
    
    public func configure(with model: Conversation) {
        self.userMessageLbl.text = model.latestMessage.text
        self.userNameLbl.text = model.name
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
