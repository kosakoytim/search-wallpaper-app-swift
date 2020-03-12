//
//  HomeViewController.swift
//  search-wallpaper-app-swift
//
//  Created by Macbook on 10/03/20.
//  Copyright © 2020 Hackington. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class HomeViewController : UIViewController {
    
    private var imagesDisplayLeftCol = [UnsplashImage]()
    private var imagesDisplayRightCol = [UnsplashImage]()
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var unsplashImageColViewLeft: UICollectionView!
    @IBOutlet weak var unsplashImageColViewRight: UICollectionView!
    @IBOutlet weak var homeScrollView: UIScrollView!
    private let homeViewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    @IBOutlet weak var imageFetchingActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unsplashImageColViewLeft.dataSource = self
        unsplashImageColViewLeft.delegate = self
        unsplashImageColViewRight.dataSource = self
        unsplashImageColViewRight.delegate = self
        searchTextField.delegate = self
        self.heightConstraint.constant = 100
        
        homeViewModel.fetchingImages.subscribe({ data in
            if (data.element! == true) {
                self.imageFetchingActivityIndicator.startAnimating()
            } else {
                self.imageFetchingActivityIndicator.stopAnimating()
            }
        }).disposed(by: disposeBag)
        
        homeViewModel.displayImageLeftColumn.subscribe({ data in
            self.imagesDisplayLeftCol.append(data.element!)
            self.unsplashImageColViewLeft.reloadData()
        }).disposed(by: disposeBag)
        
        homeViewModel.displayImageRightColumn.subscribe({ data in
            self.imagesDisplayRightCol.append(data.element!)
            self.unsplashImageColViewRight.reloadData()
        }).disposed(by: disposeBag)
        
        homeViewModel.resetData.subscribe({ data in
            if (data.element == true) {
                self.heightConstraint.constant = 100
                self.imagesDisplayLeftCol = [UnsplashImage]()
                self.imagesDisplayRightCol = [UnsplashImage]()
                self.unsplashImageColViewLeft.reloadData()
                self.unsplashImageColViewRight.reloadData()
            }
        }).disposed(by: disposeBag)
        
        handleTextField()
    }
    
    func handleTextField() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension HomeViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!imageFetchingActivityIndicator.isAnimating) {
            if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.bounds.size.height - 50)) {
                homeViewModel.fetchMore()
            }
        }
    }
}

extension HomeViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        homeViewModel.handleSearchField(text: textField.text ?? "")
        return true
    }
}

extension HomeViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var counter = 0
        if (collectionView == unsplashImageColViewLeft) {
            counter = imagesDisplayLeftCol.count
        } else {
            counter = imagesDisplayRightCol.count
        }
        return counter
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UnsplashImageCollectionViewCell()
        if (collectionView == unsplashImageColViewLeft) {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "unsplashImageCellLeft", for: indexPath as IndexPath) as! UnsplashImageCollectionViewCell
            cell.image.kf.setImage(with: URL(string: self.imagesDisplayLeftCol[indexPath.item].image_url))
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "unsplashImageCellRight", for: indexPath as IndexPath) as! UnsplashImageCollectionViewCell
            cell.image.kf.setImage(with: URL(string: self.imagesDisplayRightCol[indexPath.item].image_url))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width : CGFloat = 0
        var height : CGFloat = 0
        
        if (collectionView == unsplashImageColViewLeft) {
            print("set size on index path \(indexPath.item)")
            let collectionViewWidth = collectionView.bounds.width
            let collectionViewHorizontalSectionInset : CGFloat = 0
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellSpace = layout.minimumLineSpacing
            let adjustedWidth = collectionViewWidth - cellSpace - collectionViewHorizontalSectionInset
            width = adjustedWidth
            
//            print("collectionViewWidth \(collectionViewWidth)")
//            print("collectionViewHorizontalSectionInset \(collectionViewHorizontalSectionInset)")
//            print("cellSpace \(cellSpace)")
//            print("adjustedWidth \(adjustedWidth)")
            
            height = homeViewModel.getAspectRatioHeight(
                imgWidth: self.imagesDisplayLeftCol[indexPath.item].width,
                imgHeight: self.imagesDisplayLeftCol[indexPath.item].height,
                containerWidth: width
            )
            heightConstraint.constant = heightConstraint.constant + height
        } else {
            let collectionViewWidth = collectionView.bounds.width
            let collectionViewHorizontalSectionInset : CGFloat = 0
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellSpace = layout.minimumLineSpacing
            let adjustedWidth = collectionViewWidth - cellSpace - collectionViewHorizontalSectionInset
            width = adjustedWidth
            
            height = homeViewModel.getAspectRatioHeight(
                imgWidth: self.imagesDisplayRightCol[indexPath.item].width,
                imgHeight: self.imagesDisplayRightCol[indexPath.item].height,
                containerWidth: width
            )
        }
        
        return CGSize(width: width, height: height)
    }
}
