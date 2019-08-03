//
//  UserDataResponse.swift
//  On the Map
//
//  Created by milind shelat on 03/08/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import Foundation

struct UserDataResponse: Codable {
    let nickname: String
}


struct User: Codable {
    let lastname: String
    enum CodingKeys: String, CodingKey {
        case lastname = "last_name"
    }
}

