//
//  SelectProductViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 19/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager

import MBProgressHUD
import MJRefresh
protocol SelectProductViewControllerDelegate {
    func selectedInfos(_ productInfo:[Int:ProductInfo],isSign:[Bool])
}
class SelectProductViewController: UIViewController ,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    var isSignArr = [Bool]()
    var productInfos = [ProductInfo]()
    
    var productInfo2 = [Int:ProductInfo]()
    
    var delegate:SelectProductViewControllerDelegate?
    var selectPageIndex=1
    
    
    let header = MJRefreshNormalHeader() // 下拉刷新
    let footer = MJRefreshAutoNormalFooter() //上拉刷新
    
   // var searchController: UISearchController! // 搜索vc
   // var searchBar: UISearchBar!
    var searchSting: String? = nil // 搜索字段
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationItem("back.png", selector: #selector(SelectProductViewController.doBack), isRight: false)
        self.setNavigationItem("确认", selector: #selector(SelectProductViewController.sure), isRight: true)
        self.title = "选择材料"
        
        
        self.collectionView!.register(UINib(nibName:"SelectProductCollectionCellCollectionViewCell", bundle:nil), forCellWithReuseIdentifier:"SelectProductCollectionCellCollectionViewCell")
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
//        collectionView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
//        collectionView.contentOffset = CGPoint(x: 0, y: 44)

        
        setupSearch()
        
      //  layout.headerReferenceSize = CGSize(width: WIDTH_SCREEN, height: 30)
        
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.isStatusBarHidden = false
        
        
        self.loadData(search: searchSting)

        setUpRefresh()

    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(isSignArr:[Bool],productinfos:[Int:ProductInfo]) {
        
        var nibNameOrNil = String?("SelectProductViewController.swift")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
        self.isSignArr=isSignArr
        
        self.productInfo2=productinfos
        
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    override func doBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        UIApplication.shared.isStatusBarHidden = false
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
    }

    //确认并且返回
    func sure(){
        
        delegate?.selectedInfos(self.productInfo2,isSign: self.isSignArr )
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (productInfos.count != 0){
            if (self.isSignArr.count==0){
                for _ in 0...productInfos.count
                {
                    self.isSignArr.append(false)
                    
                }
            }
                
            else{
                
                if self.isSignArr.count<productInfos.count {
                    if(self.isSignArr.count==productInfos.count-1)
                    {
                        self.isSignArr.append(false)
                        
                    }
                    else{
                        for _ in self.isSignArr.count...productInfos.count{
                            self.isSignArr.append(false)
                            
                        }
                    }
                }
            }
            
        }
        
        tableViewDisplayWithMsg("没有配件数据", ifNecessagryForRowCount: productInfos.count)
        return productInfos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell =   collectionView.dequeueReusableCell(withReuseIdentifier: "SelectProductCollectionCellCollectionViewCell", for: indexPath) as! SelectProductCollectionCellCollectionViewCell
        if productInfos.count>indexPath.row{
            cell.showCellText(productInfos[indexPath.row])
            
        }
        if isSignArr[indexPath.row]==false{
            cell.selectImage.image = UIImage(named: "")
        }
        else{
            cell.selectImage.image = UIImage(named: "selected")
        }
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (WIDTH_SCREEN-43)/3
        let height = width
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SelectProductCollectionCellCollectionViewCell
        //
        ////        if !cell.isSign {
        //               cell.selectImage.image = UIImage(named: "selected")
        //            cell.isSign = true
        ////            productInfo.append(productInfos[indexPath.row])
        //            productInfo2[indexPath.row] = productInfos[indexPath.row]
        //
        //                //["\(productInfos[indexPath.row].name!)","\(productInfos[indexPath.row].price!)","\(productInfos[indexPath.row].id)","\(productInfos[indexPath.row].productCode)","\(productInfos[indexPath.row].productType)","\(productInfos[indexPath.row].company)"]
        //        }else{
        //               cell.selectImage.image = UIImage(named: "")
        //            cell.isSign = false
        ////              productInfo.removeAtIndex(indexPath.row)
        //            productInfo2.removeValueForKey(indexPath.row)
        //        }
        
        if !isSignArr[indexPath.row]{
            cell.selectImage.image=UIImage(named: "selected")
            self.isSignArr[indexPath.row] = true
            
            
            productInfo2[indexPath.row] = productInfos[indexPath.row]
            
            
            
        }
        else
        {
            cell.selectImage.image=UIImage(named: "")
            isSignArr[indexPath.row]=false
            productInfo2.removeValue(forKey: indexPath.row)
        }
        
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
//        
//       // searchController = UISearchController(searchResultsController: nil)
//       // searchController.searchResultsUpdater = self
//        searchBar = UISearchBar()
//        searchBar.sizeToFit()
//        searchBar.delegate = self
//        searchBar.barTintColor = COLORRGBA(239, g: 239, b: 239, a: 1)//COLORRGBA(0, g: 184, b: 252, a: 1)
//        searchBar.showsCancelButton = true
//        if let views = searchBar.subviews.first?.subviews{
//            for view in views {
//                if view.isKind(of: NSClassFromString("UINavigationButton")!) {
//                    let cancelButton = view as! UIButton
//                    cancelButton.setTitleColor(COLORRGBA(0, g: 184, b: 252, a: 1), for: .normal)
//                }
//            }
//        }
//       
////        if #available(iOS 9.1, *) {
////            searchController.obscuresBackgroundDuringPresentation = true
////        } else {
////            // Fallback on earlier versions
////        }
//        // collectionView.
//        let imageView = searchBar.subviews.first?.subviews.first
//        imageView?.layer.borderColor = COLORRGBA(255, g: 255, b: 255, a: 1).cgColor
//        imageView?.layer.borderWidth = 1.0
//        definesPresentationContext = true // 保证在UISearchController在激活状态下用户push到下一个view controller之后search bar不会仍留在界面上
//
//        headerView.addSubview(searchBar)
//        return headerView
//    }
//    
//  
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: WIDTH_SCREEN, height: 44)
//    }
//    
    
    // 添加上拉下拉刷新控件
    func setUpRefresh() {
        
        //下拉刷新
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headRefresh))
        collectionView.mj_header = header
        
        //上拉刷新
        
        footer.setRefreshingTarget(self, refreshingAction:  #selector(footerRefresh))
        collectionView.mj_footer = footer
        
    }
    
    
    
    
    
    // 下拉刷新事件
    
    func headRefresh() {
        
        //        if !productInfos.isEmpty {
        //            productInfos.removeAll() // 移除所有数据
        //        }
        
        selectPageIndex = 1 //返回第一页
        footer.resetNoMoreData() // 重启
        loadDataByPull(search: searchSting)
    }
    
    
    // 上拉刷新事件
    
    func footerRefresh() {
        
        selectPageIndex += 1 //页码增加
        loadDataByUp(search: searchSting)
        
    }
    
    
    func loadData(search: String?){
        //MBProgressHUD.showAdded(to: self.collectionView, animated: true)
        User.GetPriceTable(1, pagesize: 18, searchString: search, success: { [weak self]productinfos in
            
            self?.header.endRefreshing()
            self?.footer.endRefreshing()
            if productinfos.count < 18 {
                self?.footer.endRefreshingWithNoMoreData()
            }
            
            if let strongSelf = self{
               // print(productinfos)
                
                
              //  MBProgressHUD.hide(for: strongSelf.collectionView, animated: true)
                strongSelf.collectionView.isUserInteractionEnabled = true
                //                strongSelf.orders = orders
                strongSelf.productInfos = productinfos
                print("成功.....-------")
                
                strongSelf.collectionView.reloadData()
            }}) { [weak self] (error) in
                if let strongSelf = self{
                    //                    strongSelf.orders = [Order]()
                    
                    //strongSelf.tableView.pullToRefreshView.stopAnimating()
                    self?.collectionView.isUserInteractionEnabled = true
                  //  MBProgressHUD.hide(for: strongSelf.collectionView, animated: true)
                    strongSelf.collectionView.reloadData()
                    print(error.localizedDescription)
                }
        }
        
        
    }
    
    //下拉刷新
    func loadDataByPull(search: String?){
        
        User.GetPriceTable(1, pagesize: 18, searchString: search, success: { [weak self]productinfos in
            
            self?.header.endRefreshing()
            // self?.footer.endRefreshing()
            if productinfos.count < 18 {
                self?.footer.endRefreshingWithNoMoreData()
            }
            
            if let strongSelf = self{
                
                //  strongSelf.header.endRefreshing()
                strongSelf.collectionView.isUserInteractionEnabled = true
              //  print("成功.....-------")
                strongSelf.productInfos = productinfos
               // print(productinfos)
                self?.collectionView.reloadData()
            }}) { [weak self] (error) in
                
                if let strongSelf = self{
                    
                    self!.header.endRefreshing()
                    strongSelf.collectionView.isUserInteractionEnabled = true
                    strongSelf.collectionView.reloadData()
                    print(error.localizedDescription)
                }
        }
        
        
    }
    
    
    
    //上拉刷新
    func loadDataByUp(search: String?){
        
        //        print(self.selectPageIndex)
        //        if (self.isLoadEnd==false){
        // selectPageIndex += 1 //页码增加
        //            print(self.selectPageIndex)
        //        }

        User.GetPriceTable(selectPageIndex, pagesize: 18,searchString: search, success: { [weak self]tmproductinfos in
            
            // self?.header.endRefreshing()
            self?.footer.endRefreshing()
            if tmproductinfos.count < 18 {
                self?.footer.endRefreshingWithNoMoreData()
            }
            
            if let strongSelf = self{
                strongSelf.collectionView.isUserInteractionEnabled = true
                
                
                //  strongSelf.orders = orders
                if (tmproductinfos.count==0)
                {
                    
                    strongSelf.selectPageIndex -= 1 //恢复增加
                    // strongSelf.footer.endRefreshingWithNoMoreData()
                }
                    
                else{
                    
                    
                    for index in 0...tmproductinfos.count-1{
                        if (tmproductinfos[index].id != nil){
                            
                            strongSelf.productInfos.append(tmproductinfos[index])
                            print(strongSelf.productInfos.count)
                            
                        }
                        
                    }
                    
                    
                    
                    
                    strongSelf.collectionView.reloadData()
                    
                    
                    //  print("成功.....-------")
                    
                    
                    //   strongSelf.footer.endRefreshing()
                    
                }
                
                strongSelf.collectionView.isUserInteractionEnabled = true
            }
            
        }) { [weak self] (error) in
            
            if let strongSelf = self{
                
                self!.footer.endRefreshing()
                strongSelf.collectionView.isUserInteractionEnabled = true
                
                strongSelf.collectionView.reloadData()
                print(error.localizedDescription)
            }
        }
        
    }
    
    func tableViewDisplayWithMsg(_ message: String, ifNecessagryForRowCount: Int ) -> Void {
        if  ifNecessagryForRowCount == 0{
            //没有数据时显示
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 15)
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.sizeToFit()
            
            collectionView.backgroundView = messageLabel
            
            footer.isHidden = true //没有数据是隐藏footer
            
        }else{
            collectionView.backgroundView = nil
            
            footer.isHidden = false
          
        }
    }

    
}

// MARK: -  搜索

extension SelectProductViewController{
    
    func setupSearch(){
        
//        searchController = UISearchController(searchResultsController: nil)
//        // searchController.searchResultsUpdater = self
//        searchController.searchBar.sizeToFit()
//        searchController.searchBar.delegate = self
//        searchController.searchBar.barTintColor = COLORRGBA(239, g: 239, b: 239, a: 1)//COLORRGBA(0, g: 184, b: 252, a: 1)
//        //        if #available(iOS 9.1, *) {
//        //            searchController.obscuresBackgroundDuringPresentation = true
//        //        } else {
//        //            // Fallback on earlier versions
//        //        }
//        // collectionView.
//        let imageView = searchController.searchBar.subviews.first?.subviews.first
//        imageView?.layer.borderColor = COLORRGBA(239, g: 239, b: 239, a: 1).cgColor
//        imageView?.layer.borderWidth = 1.0
//        definesPresentationContext = true // 保证在UISearchController在激活状态下用户push到下一个view controller之后search bar不会仍留在界面上

        
      //  collectionView.addSubview(searchController.searchBar)
        
        searchBar.delegate = self
        searchBar.barTintColor = COLORRGBA(239, g: 239, b: 239, a: 1)//COLORRGBA(0, g: 184, b: 252, a: 1)
        searchBar.showsCancelButton = true
        if let views = searchBar.subviews.first?.subviews{
            for view in views {
                if view.isKind(of: NSClassFromString("UINavigationButton")!) {
                    let cancelButton = view as! UIButton
                    cancelButton.setTitleColor(COLORRGBA(0, g: 184, b: 252, a: 1), for: .normal)
                }
            }
        }
        
        //        if #available(iOS 9.1, *) {
        //            searchController.obscuresBackgroundDuringPresentation = true
        //        } else {
        //            // Fallback on earlier versions
        //        }
        // collectionView.
        let imageView = searchBar.subviews.first?.subviews.first
        imageView?.layer.borderColor = COLORRGBA(255, g: 255, b: 255, a: 1).cgColor
        imageView?.layer.borderWidth = 1.0
        definesPresentationContext = true // 保证在UISearchController在激活状态下用户push到下一个view controller之后search bar不会仍留在界面上
        
    }
    
    // 搜索数据
    func filterResultsWithSearchString(searchStr: String?){
        
        self.searchSting = searchStr
        
        self.loadData(search: searchSting)
        
        selectPageIndex = 1 //返回第一页
        footer.resetNoMoreData() // 重启
    }

}

// UISearchResultsUpdating

//extension SelectProductViewController: UISearchResultsUpdating{
//    
//    
////    func updateSearchResults(for searchController: UISearchController) {
////        let searchBar = searchController.searchBar
////        filterResultsWithSearchString(searchStr: searchBar.text)
////    }
//    
//}

//  UISearchBarDelegate

extension SelectProductViewController:  UISearchBarDelegate{
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         filterResultsWithSearchString(searchStr: searchText)
    }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) -> Bool {
//        filterResultsWithSearchString(searchStr: searchBar.text)
//        return true
//    }
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = true
//        
//        guard let views = searchBar.subviews.first?.subviews else {
//            return
//        }
//        for view in views {
//            if view.isKind(of: NSClassFromString("UINavigationButton")!) {
//                let cancelButton = view as! UIButton
//                cancelButton.setTitleColor(COLORRGBA(0, g: 184, b: 252, a: 1), for: .normal)
//            }
//        }
//    }
//    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        /// filterResultsWithSearchString(searchStr: searchBar.text)
        
          searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterResultsWithSearchString(searchStr: nil)
        searchBar.text = nil
        searchBar.resignFirstResponder()
      
    }
}

