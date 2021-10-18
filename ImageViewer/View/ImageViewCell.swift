//
//  ImageViewCell.swift
//  ImageViewer
//
//  Created by Andres Lara Aguirre on 2021-10-18.
//

import UIKit

// Used to display images in a collection view
class ImageViewCell: UICollectionViewCell {
    static let imageCellId = "ImageViewCell"
    @IBOutlet var imageView: UIImageView!
    var imageModel: ImageModel?
}
