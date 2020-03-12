//
//  UnsplashImageCollectionViewCell.swift
//  search-wallpaper-app-swift
//
//  Created by Macbook on 11/03/20.
//  Copyright © 2020 Hackington. All rights reserved.
//

import UIKit

class UnsplashImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 15
    }
}
