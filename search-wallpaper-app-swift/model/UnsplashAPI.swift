//
//  UnsplashAPI.swift
//  search-wallpaper-app-swift
//
//  Created by Macbook on 10/03/20.
//  Copyright © 2020 Hackington. All rights reserved.
//

import Foundation

struct PaginatorQuery {
    let page: Int
    let per_page: Int
}

struct APIError {
    let code: Int
    let message: String
}
