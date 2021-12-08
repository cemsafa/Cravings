//
//  AddPostCollectionViewCell.swift
//  Cravings
//
//  Created by Janakiram Gupta on 29/11/21.
//

import UIKit
import AVKit
import SDWebImage

class PlayerView: UIView {
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
}

class AddPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var playerView: PlayerView!
    
    var image: UIImage? {
        didSet {
            postImageView.isHidden = false
            playerView.isHidden = true
            postImageView.image = image
        }
    }
    
    var imageURL: String? {
        didSet {
            postImageView.isHidden = false
            playerView.isHidden = true
            self.postImageView.sd_setImage(with: URL(string: imageURL ?? ""), completed: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var videoURL: URL? {
        didSet {
            postImageView.isHidden = true
            playerView.isHidden = false
            playVideo()
        }
    }
    
    var videoPlayer: AVPlayer? = nil
    
    func playVideo() {
        guard let url = videoURL else {
            return
        }
        videoPlayer = AVPlayer(url: url)
        videoPlayer?.playImmediately(atRate: 1)
        playerView.player = videoPlayer
    }
    
    func stopVideo() {
        playerView.player?.pause()
    }
    
}
