//
//  RNGuideViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/10.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

typealias GuideClosure = () -> Void

class RNGuideViewController: UIViewController {
    
    var collectionView: UICollectionView?
    fileprivate var imageNames = ["guide_00","guide_01","guide_02"]
    fileprivate let cellIdentifier = "collectionCell"
    fileprivate var isHiddenNextButton = true
    fileprivate var pageControl = UIPageControl(frame: CGRect(x: 0,y: HEIGHT_SCREEN-40,width: WIDTH_SCREEN,height: 20))
    
    internal var skipClosure: GuideClosure?
    
    func initWithSkipClosure(_ closure: @escaping GuideClosure) -> Void{
        skipClosure = closure
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        
      //  UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
     //   self.prefersStatusBarHidden

        setupCollectionView()
        setupPageControl()
        //你在台上唱着我的创作我在台下已经开始感动
        
    }
    
    // MARK: About UI
    
    fileprivate func setupCollectionView() -> Void{
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = MainScreenBounds.size
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView = UICollectionView(frame: MainScreenBounds, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.register(GuideCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        view.addSubview(collectionView!)
        
    }
    
    fileprivate func setupPageControl() -> Void{
        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = 0
        view.addSubview(pageControl)
    }

   
}


// MARK: - UICollectionViewDelegate && UICollectionViewDataSource

extension RNGuideViewController: UICollectionViewDelegate,UICollectionViewDataSource{
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GuideCell
        cell.newImage = UIImage(named: imageNames[indexPath.row])
        if indexPath.row != imageNames.count - 1 {
            cell.setNextButtonHidden(true)
        }
        
        weak var weakSelf = self
        cell.cellClosure = {
            
            if weakSelf?.skipClosure != nil {
                weakSelf?.skipClosure!()
            }
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == WIDTH_SCREEN * CGFloat(imageNames.count - 1) {
            let cell = collectionView!.cellForItem(at: IndexPath(row: imageNames.count - 1, section: 0)) as! GuideCell
            cell.setNextButtonHidden(false)
            isHiddenNextButton = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != WIDTH_SCREEN * CGFloat(imageNames.count - 1) && !isHiddenNextButton && scrollView.contentOffset.x > WIDTH_SCREEN * CGFloat(imageNames.count - 2) {
            let cell = collectionView!.cellForItem(at: IndexPath(row: imageNames.count - 1, section: 0)) as! GuideCell
            cell.setNextButtonHidden(true)
            isHiddenNextButton = true
        }
        
        pageControl.currentPage = Int(scrollView.contentOffset.x / WIDTH_SCREEN + 0.5)
    }

}
