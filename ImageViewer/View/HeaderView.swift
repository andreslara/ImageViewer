//
//  HeaderView.swift
//  ImageViewer
//
//  Created by Andres Lara Aguirre on 2021-10-18.
//

import UIKit

// Used to display a message in a collection view header
class HeaderView: UICollectionReusableView {
    static let headerViewId = "HeaderView"
    @IBOutlet var messageLabel: UILabel!
}
