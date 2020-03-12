//
//  DataManager.swift
//  search-wallpaper-app-swift
//
//  Created by Macbook on 10/03/20.
//  Copyright © 2020 Hackington. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

final class DataManager {
    private let c = Constants()
    init(){}
    
    func getRandomPhotos(
        count: Int,
        onSuccess: @escaping ([UnsplashImage]) -> Void,
        onFailure: @escaping (APIError) -> Void
    ) {
        var endpoint = c.API_URL + "/photos/random?client_id=" + c.API_KEY
        endpoint += "&count=\(count)"
        print(endpoint)
        AF.request(endpoint).responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.data {
                    do{
                        let data = try JSON(data: json)
                        let results = data
                        var images_to_display = [UnsplashImage]()
                        for (index, _) in results.enumerated() {
                            images_to_display.append(
                                UnsplashImage(
                                    id: results[index]["id"].stringValue,
                                    width: results[index]["width"].intValue,
                                    height: results[index]["height"].intValue,
                                    image_url: results[index]["urls"]["small"].stringValue
                                )
                            )
                        }
                        onSuccess(images_to_display)
                    }
                    catch{
                        onFailure(APIError(code: 301, message: "Fail while fetching data"))
                    }
                }
            case .failure(let error):
                print("error getRandomPhotos")
                print(error)
            }
        }
    }
    
    func getPhotosFromSearch(
        paginator: PaginatorQuery,
        query: String,
        onSuccess: @escaping ([UnsplashImage]) -> Void,
        onFailure: @escaping (APIError) -> Void
    ) {
        var endpoint = c.API_URL + "/search/photos?client_id=" + c.API_KEY
        endpoint += "&page=\(paginator.page)"
        endpoint += "&per_page=\(paginator.per_page)"
        endpoint += "&query=\(query)"
        AF.request(endpoint).responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.data {
                    do{
                        let data = try JSON(data: json)
                        let results = data["results"]
                        var images_to_display = [UnsplashImage]()
                        for (index, _) in results.enumerated() {
                            images_to_display.append(
                                UnsplashImage(
                                    id: results[index]["id"].stringValue,
                                    width: results[index]["width"].intValue,
                                    height: results[index]["height"].intValue,
                                    image_url: results[index]["urls"]["small"].stringValue
                                )
                            )
                        }
                        onSuccess(images_to_display)
                    }
                    catch{
                        onFailure(APIError(code: 301, message: "Fail while fetching data"))
                    }
                }
            case .failure(let error):
                print("error getPhotosFromSearch")
                print(error)
            }
        }
    }
}
