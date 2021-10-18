//
//  ImagesPresenter.swift
//  ImageViewer
//
//  Created by Andres Lara on 2021-10-16.
//

import UIKit

public enum SearchError: Error {
    case invalidUrl
    case parser
    case networkFailure(Error)
    case invalidServerResponse
    case httpError(Int)
    case parameterError
}

protocol ImageSearching {
    func search(searchTerm: String)
}

protocol SearchResultsDelegate: AnyObject {
    func receivedResults(results: Result<[ImageModel], SearchError>)
}

class ImageSearchPresenter: NSObject, ImageSearching {
    // Make sure reference to delegate is weak
    weak var delegate: SearchResultsDelegate?
    var task: URLSessionDataTask?
    private let baseUrl = "https://www.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags="

    func search(searchTerm: String) {
        //If there is no delegate bail early
        guard let delegate = delegate else {
            return
        }

        //If search term is empty then return empty arrays
        if searchTerm.count == 0 {
            delegate.receivedResults(results: .success([]))
            return
        }

        let url = searchUrl(searchTerm: searchTerm)
        guard let url = url else {
            print("Cannot create url for search")
            return
        }
        //If there is an existing task, cancel it since we are about to start a new search
        if let task = task {
            task.cancel()
        }
        task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                DispatchQueue.main.async { delegate.receivedResults(results: .failure(.networkFailure(error))) }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                //We are expecting an HTTP response but we got something else
                DispatchQueue.main.async { delegate.receivedResults(results: .failure(.invalidServerResponse)) }
                return
            }
            if response.statusCode != 200 {
                //Status code is not 200, something went wrong
                DispatchQueue.main.async { delegate.receivedResults(results: .failure(.httpError(response.statusCode))) }
                return
            }
            guard let data = data else {
                //Data should not be nil
                DispatchQueue.main.async { delegate.receivedResults(results: .failure(.parser)) }
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(Matches.self, from: data)
                DispatchQueue.main.async { delegate.receivedResults(results: .success(decodedData.items)) }
            } catch let error as NSError {
                print("Error while decoding \(error.description)")
                DispatchQueue.main.async { delegate.receivedResults(results: .failure(.parser)) }
                return
            }
        })
        if let task = task {
            task.resume()
        }

    }

    func searchUrl(searchTerm: String) -> URL? {
        return URL(string: baseUrl + searchTerm)
    }
}
