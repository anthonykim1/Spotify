//
//  TitleHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by Anthony Kim on 5/29/21.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "TitleHeaderCollectionReusableView"
    
//    single subview which is a label
    private let label: UILabel = {
      let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: width-30, height: height)
    }
    
//    we are not going to create view model for this because all we are configuring with this is the title
//    so it will be simple
    
    func configure(with title: String) {
        label.text = title
    }
}
