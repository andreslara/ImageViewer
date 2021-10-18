//
//  SearchResult.swift
//  ImageViewer
//
//  Created by Andres Lara on 2021-10-16.
//

import Foundation

struct ImageModel: Codable {
    let title: String
    let media: [String: String]
    let description: String
    let author: String

    var url: URL? {
        if let urlString = media["m"], let url = URL(string: urlString) {
            return url
        }
        return nil
    }

    var height: String {
        return extractValue(key: "height")
    }

    var width: String {
        return extractValue(key: "width")
    }

    func extractValue(key: String) -> String {
        //Format looks like this "something something key="value" something something"
        //We want to extract value by getting rid of everything before and after that substring
        //First we find the first ocurrence of the substring <key="> and get rid of anything before that.
        //Then we ocurrence of the closing <"> after the value and get rid of anything after that
        if let startRange = description.range(of: "\(key)=\"") {
            let temp =  description[startRange.upperBound...]
            if let endRange = temp.range(of: "\"") {
                let res = temp[..<endRange.lowerBound]
                return String(res)
            }
        }
        return ""
    }
}

struct Matches: Codable {

    let items: [ImageModel]

    private enum CodingKeys: String, CodingKey {
      case items
    }
}

