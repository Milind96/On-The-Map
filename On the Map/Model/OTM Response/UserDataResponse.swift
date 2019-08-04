//
//  UserDataResponse.swift
//  On the Map
//
//  Created by milind shelat on 03/08/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import Foundation

struct UserDataResponse: Codable {
    let firstName: String
    let lastName: String
    let nickName: String
    
    enum CodingKeys : String,CodingKey{
        case firstName = "first_name"
        case lastName = "last_name"
        case nickName = "nickname"
    }
}

