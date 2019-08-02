//
//  PostLocationResponse.swift
//  On the Map
//
//  Created by milind shelat on 30/07/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import Foundation

struct PostLocationResponse: Codable {
    let createdAt: String
    let objectId: String
}

struct NewLocation: Codable {
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
}
