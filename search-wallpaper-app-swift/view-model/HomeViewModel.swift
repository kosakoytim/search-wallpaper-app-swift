//
//  HomeViewModel.swift
//  search-wallpaper-app-swift
//
//  Created by Macbook on 10/03/20.
//  Copyright © 2020 Hackington. All rights reserved.
//

import Foundation
import RxSwift

enum HomeImageDisplayCategory {
    case RANDOM
    case SEARCH
}

class HomeViewModel {

    private let dataManager: DataManager
    private var page : Int
    var displayImageLeftColumn : PublishSubject<UnsplashImage>
    private var leftColumnHeight : Int
    var displayImageRightColumn : PublishSubject<UnsplashImage>
    private var rightColumnHeight : Int
    var fetchingImages : PublishSubject<Bool>
    var resetData : PublishSubject<Bool>
    private var homeImageDisplayCategory : HomeImageDisplayCategory
    private var searchText : String
    
    init() {
        dataManager = DataManager()
        searchText = ""
        page = 1
        leftColumnHeight = 0
        rightColumnHeight = 0
        displayImageLeftColumn = PublishSubject<UnsplashImage>()
        displayImageRightColumn = PublishSubject<UnsplashImage>()
        fetchingImages = PublishSubject<Bool>()
        resetData = PublishSubject<Bool>()
        homeImageDisplayCategory = HomeImageDisplayCategory.RANDOM
        getRandomPhotos(
            paginator: PaginatorQuery(page: page, per_page: 20)
        )
    }
    
    private func getRandomPhotos(paginator: PaginatorQuery = PaginatorQuery(page: 1, per_page: 20)) {
        if (paginator.page == 1) {
            resetAllData()
        }
        homeImageDisplayCategory = HomeImageDisplayCategory.RANDOM
        fetchingImages.onNext(true)
        page = paginator.page
        dataManager.getRandomPhotos(
            count: paginator.per_page,
            onSuccess: { response in
                self.fetchingImages.onNext(false)
                self.distributeImageBetweenColumn(response: response)
        },
            onFailure: { error in
                self.fetchingImages.onNext(false)
                print("get error")
                print(error)
        })
    }
    
    private func getPhotosFromSeach(
        paginator: PaginatorQuery = PaginatorQuery(page: 1, per_page: 20),
        query: String
    ) {
        if (paginator.page == 1) {
            resetAllData()
        }
        homeImageDisplayCategory = HomeImageDisplayCategory.SEARCH
        fetchingImages.onNext(true)
        page = paginator.page
        dataManager.getPhotosFromSearch(
            paginator: paginator,
            query: query,
            onSuccess: { response in
                self.fetchingImages.onNext(false)
                self.distributeImageBetweenColumn(response: response)
        },
            onFailure: { error in
                self.fetchingImages.onNext(false)
                print("get error")
                print(error)
        })
    }
    
    private func distributeImageBetweenColumn(response : [UnsplashImage]) {
        for res in response {
//            print("--------")
            if (leftColumnHeight <= rightColumnHeight) {
                leftColumnHeight += res.height
                displayImageLeftColumn.onNext(res)
//                print("add to left")
            } else {
                rightColumnHeight += res.height
                displayImageRightColumn.onNext(res)
//                print("add to right")
            }
//            print("leftColumnHeight \(leftColumnHeight)")
//            print("rightColumnHeight \(rightColumnHeight)")
//            print("--------")
        }
    }
    
    private func resetAllData() {
        resetData.onNext(true)
        leftColumnHeight = 0
        rightColumnHeight = 0
    }
    
    public func handleSearchField(text: String) {
        if (text.count == 0) {
            getRandomPhotos()
        } else {
            searchText = text
            getPhotosFromSeach(query: text)
        }
    }
    
    public func fetchMore() {
        if (homeImageDisplayCategory == HomeImageDisplayCategory.RANDOM) {
            getRandomPhotos(paginator: PaginatorQuery(page: page + 1, per_page: 20))
        } else {
            getPhotosFromSeach(paginator: PaginatorQuery(page: page + 1, per_page: 20), query: searchText)
        }
    }
}
