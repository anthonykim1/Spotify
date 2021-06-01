//
//  NewReleaseCollectionViewCell.swift
//  Spotify
//
//  Created by Anthony Kim on 3/26/21.
//

import UIKit
import SDWebImage // to download image for the album with url thats in our viewmodel

class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let albumNameLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0 // lets the line text for the label wrap if it needs to
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let numberOfTracksLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 0 //lets the line for the text wrap if it needs to
        return label
    }()
    
    private let artistNameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true // so that anything that overflows clips to bounds
        contentView.addSubview(numberOfTracksLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-10
        let albumLabelSize = albumNameLabel.sizeThatFits(
            CGSize(
            width: contentView.width-imageSize-10,
            height: contentView.height-10 //subtractions omitting the space that is available for the label to be used and sized
            )
        )
        
        artistNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
        
        //Image
        albumCoverImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        // Album name label
        let albumLabelHeight = min(60, albumLabelSize.height)
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                           y: 5,
                                           width: albumLabelSize.width,
                                           height: albumLabelHeight
        )
        
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                       y: albumNameLabel.bottom+5,
                                       width: contentView.width - albumCoverImageView.right-10,
                                           height: 30
        )
        
        numberOfTracksLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                           y: contentView.bottom-44,
                                           width: numberOfTracksLabel.width,
                                           height: 44)
    }
    
    // this gets called whenever we want to reuse our cell
    override func prepareForReuse() {
        super.prepareForReuse()
        // ensure that when we reuse cell we are leaking stage from the prior cell
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    // take in view model type
    // configuration business.
    // configure our content
    func configure(with viewModel: NewReleasesCellViewModel) {
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
