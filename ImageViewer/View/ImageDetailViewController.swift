//
//  ImageDetailViewController.swift
//  ImageViewer
//
//  Created by Andres Lara Aguirre on 2021-10-18.
//

import UIKit

// Displays the details of an image
class ImageDetailViewController: UIViewController {

    var imageModel: ImageModel?
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dimensionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let imageModel = imageModel else {
            return
        }
        if let urlString = imageModel.media["m"], let url = URL(string: urlString) {
            imageView.sd_setImage(with: url )
        }
        titleLabel.text = imageModel.title
        authorLabel.text = "By \(imageModel.author)"
        dimensionLabel.text = "Dimensions: \(imageModel.width) x\(imageModel.height)"

    }

}
