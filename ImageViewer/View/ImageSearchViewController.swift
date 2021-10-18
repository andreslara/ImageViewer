//
//  ImageSearchViewController.swift
//  ImageViewer
//
//  Created by Andres Lara on 2021-10-16.
//

import UIKit
import SDWebImage

//This class allows the user to enter a search term and displays any images that match
class ImageSearchViewController: UICollectionViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    var datasource: ImageCollectionViewDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        datasource = ImageCollectionViewDataSource(collectionView: collectionView)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageDetailViewController, let cell = sender as? ImageViewCell {
            vc.imageModel = cell.imageModel
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //Invalidate layout when rotating so cell sizes get recalculated
        coordinator.animate(
                alongsideTransition: { _ in },
                completion: { _ in self.collectionView.reloadData()}
            )
    }

// MARK: UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let datasource = datasource else {
            return
        }
        //Let the data source load the items for the search text
        datasource.loadItems(searchTerm: searchText)
    }

}

/// Takes care of interacting with the model to fetch the list of images that match the search term
/// and populates the collection view
class ImageCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SearchResultsDelegate {

    var collectionView: UICollectionView
    var items = [ImageModel]()
    var imagesPresenter = ImageSearchPresenter()
    var searchError: SearchError?
    private let collectionInsets =  UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)
    private let cellsPerRow: CGFloat = 3

    init(collectionView: UICollectionView) {
        //Setup everything related to the collection view
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self

        //Set self as the delegate to receive search results
        imagesPresenter.delegate = self
    }

    // MARK: SearchResultsDelegate
        func receivedResults(results: Result<[ImageModel], SearchError>) {
            switch results {
            case .success(let results):
                self.items = results
                searchError = nil
            case .failure(let error):
                self.items = []
                print("Error = \(error.localizedDescription)")
                searchError = error
            }
            self.collectionView.reloadData()
        }

    // Loads the list of items for the given search term
    func loadItems(searchTerm: String) {
        imagesPresenter.search(searchTerm: searchTerm)
    }

    func configureCell(_ cell: ImageViewCell, imageModel: ImageModel) {
        cell.imageModel = imageModel
        //Load image from url
        if let url = imageModel.url {
            cell.imageView.sd_setImage(with: url )
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.imageCellId, for: indexPath)
        if let cell = cell as? ImageViewCell {
            let imageModel = items[indexPath.row]
            configureCell(cell, imageModel: imageModel)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        //We show the number of matches in the header of an error message if there is one
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.headerViewId, for: indexPath)

            if let headerView = headerView as? HeaderView {
                if searchError != nil {
                    headerView.messageLabel.text = "There was an error, please try again later."
                } else {
                    headerView.messageLabel.text = "Found \(items.count) images"
                }

            }
            return headerView
        default:
            assert(false, "Unknown kind of supplementary element")
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Calulcate row size based on number of desired items, collection view width and empty space
        let emptySpace = (cellsPerRow + 1) * collectionInsets.left
        let cellSpace = collectionView.frame.width - emptySpace
        let itemWidth = cellSpace / cellsPerRow

        return CGSize(width: itemWidth, height: itemWidth)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionInsets.left
    }

}
