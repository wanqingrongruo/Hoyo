//
//  ZBMapViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/6/7.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MapKit
import JPSThumbnailAnnotation
import MBProgressHUD
class ZBMapViewController: UIViewController {
    
    var isgeocoder = "" // 鉴别经纬度是否是用地址编码得来
    
    @IBAction func BackClick(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var mkMapView: MKMapView!
    
    var myOverlays: [MKOverlay]? = nil // 路线上步数集合
    var isShowRoute = true
    
    
    fileprivate var cLLocation:CLLocationCoordinate2D?
    fileprivate var cLLocationStr:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title="位置详情"
        
//        if isgeocoder == "地址编码" {
//            
//            let alertView=SCLAlertView()
//            alertView.addButton("确定", action: {})
//            alertView.showWarning("提示", subTitle: "由于经纬度是由目的地址编码得来,但是,目的地址可能存在填写错误、不具体等问题，请谨慎导航。弄清地址，通过手机地图导航更佳")
//
//        }
        
        mkMapView.mapType=MKMapType.standard//标准模式
        mkMapView.showsUserLocation=true//显示自己
        mkMapView.delegate=self
        mkMapView.isZoomEnabled = true//支持缩放
        if cLLocation != nil {
            let pos = cLLocation//CLLocationCoordinate2D(latitude: 39.931203, longitude: 116.395573)
            let viewRegion = MKCoordinateRegionMakeWithDistance(pos!, 6000, 6000)//以pos为中心，显示6000米
            let adjustedRegion = mkMapView.regionThatFits(viewRegion)//适配map view的尺寸
            mkMapView.setRegion(adjustedRegion, animated: true)
            
            //            let thumbnail = JPSThumbnail()
            //            thumbnail.image = UIImage(named: "positionNewIcon")// ("position")
            //            thumbnail.title = cLLocationStr ?? ""
            //            thumbnail.subtitle = ""
            //            thumbnail.coordinate = cLLocation!
            //            thumbnail.disclosureBlock = { NSLog("selected Empire") }
            //            mkMapView.addAnnotation(JPSThumbnailAnnotation(thumbnail: thumbnail))
            //[mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = cLLocation!
            mkMapView.addAnnotation(pointAnnotation)
            
        }
        
        setupBottomView(cLLocationStr ?? "")
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    convenience  init(location:CLLocationCoordinate2D?,locationString:String) {
        
        var nibNameOrNil = String?("ZBMapViewController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        self.cLLocation=location
        self.cLLocationStr=locationString
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - custom methods

extension ZBMapViewController {
    
    func setupBottomView(_ title: String){
        
        let h: CGFloat = 80
        
        let bottomView = UIView(frame: CGRect(x: 0, y: MainScreenBounds.height-h, width: MainScreenBounds.width, height: h))
        bottomView.backgroundColor = UIColor.white
        view.addSubview(bottomView)
        
        let contentLabel = RNMultiFunctionLabel()
        contentLabel.text = title
        contentLabel.numberOfLines = 0
        bottomView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named:"goAddress"), for: .normal)
        btn.backgroundColor = UIColor.cyan
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = (h-30)/2.0
        btn.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        bottomView.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.leading.equalTo(contentLabel.snp.trailing).offset(20)
            make.trailing.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(h-30)
            make.height.equalTo(h-30)
        }
        
    }
    
    func makeRoute(_ origin: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D) {
        
        let originPlaceMark = MKPlacemark(coordinate: origin, addressDictionary: nil)
        let originMapItem = MKMapItem(placemark: originPlaceMark)
        
        let destinationPlaceMark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
        
        let request = MKDirectionsRequest()
        request.source = originMapItem
        request.destination = destinationMapItem
        
        // pull request to server of apple
        
        // 用于发送请求去服务器,获取规划好的路线
        let directs = MKDirections(request: request)
        directs.calculate { (response, error) in
            
            // 获取所有规划路径
            let routes = response?.routes
            let route = routes?.last
            
            // 保存路线中的每一步
            let steps = route?.steps
            
            guard let _ = steps else{
                return
            }
            for step in steps!{
                
                // 绘制遮盖打印到地图上
                self.mkMapView.add(step.polyline, level: .aboveRoads)
                
                // self.myOverlays?.append(step.polyline)
            }
        }
        
        
    }
    
    // 判断是否获取到当前位置
    func getCurrentLocation() -> (isUpdatedSuccess: Bool, origin: CLLocationCoordinate2D?) {
        
        let origin = self.mkMapView.userLocation.location?.coordinate
        
        guard let _ = origin else{
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showWait("提示", subTitle: "正在定位当前位置,请稍等...")
            
            return (false, nil)
        }
        
        return (true, origin)
        
    }
    
}

// MARK: - event response

extension ZBMapViewController {
    
    func showMap(){
        
        guard let _ = cLLocation else {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showWait("提示", subTitle: "未获取到目标坐标")
            
            return
        }
        
        // 检测手机上的地图
        let isBaiduMap = UIApplication.shared.canOpenURL(URL(string: "baidumap://")!)
        let isTencentMap = UIApplication.shared.canOpenURL(URL(string: "sosomap://")!)
        let isGaodeMap = UIApplication.shared.canOpenURL(URL(string: "iosamap://")!)
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let routeTitle = "显示路线"
        if !isShowRoute {
            
            // routeTitle = "隐藏路线"
        }
        
        let showRoute = UIAlertAction(title: routeTitle, style: .default) { (action) in
            
            
            if self.isShowRoute{
                
                guard let destination = self.cLLocation else{
                    
                    return
                }
                
                MBProgressHUD.showAdded(to: self.mkMapView, animated: true)
                
                guard self.getCurrentLocation().isUpdatedSuccess else{
                    
                    MBProgressHUD.hide(for: self.mkMapView, animated: true)
                    return
                }
                
                self.makeRoute(self.getCurrentLocation().origin!, destination)
            }else{
                
                //                if let overlays = self.myOverlays {
                //                   // 移除路线 -- 不成功舍弃
                //                    self.mkMapView.removeOverlays(overlays)
                //                    self.myOverlays = nil
                //                }
                
            }
            
            //  self.isShowRoute = !self.isShowRoute
            
        }
        
        alertViewController.addAction(showRoute)
        
        if isBaiduMap {
            
            let baiduAction = UIAlertAction(title: "百度地图", style: .default) { (action) in
                
                
                guard self.getCurrentLocation().isUpdatedSuccess else{
                    return
                }
                
                let ori = self.getCurrentLocation().origin!
                
                let str = "baidumap://map/direction?origin=\(ori.latitude),\(ori.longitude)&destination=\(self.cLLocation!.latitude),\(self.cLLocation!.longitude)&name=目的地&mode=driving&coord_type=gcj02&src=浩优服务家"
                // 对汉字进行转码 stringByAddingPercentEscapesUsingEncoding => iOS9.0 addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let urlStr = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                
                guard let us = urlStr, let u = URL(string: us) else{
                    return
                }
                UIApplication.shared.openURL(u)
            }
            alertViewController.addAction(baiduAction)
        }
        
        if isTencentMap {
            
            let tencentAction = UIAlertAction(title: "腾讯地图", style: .default) { (action) in
                
                guard self.getCurrentLocation().isUpdatedSuccess else{
                    return
                }
                
                let ori = self.getCurrentLocation().origin!
                
                let str = "qqmap://map/routeplan?type=drive&from=我的位置&fromcoord=\(ori.latitude),\(ori.longitude)&to=目的地&tocoord=\(self.cLLocation!.latitude),\(self.cLLocation!.longitude)&policy=0&referer=浩优服务家"
                // 对汉字进行转码 stringByAddingPercentEscapesUsingEncoding => iOS9.0 addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let urlStr = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                
                guard let us = urlStr, let u = URL(string: us) else{
                    return
                }
                UIApplication.shared.openURL(u)
            }
            alertViewController.addAction(tencentAction)
        }
        
        if isGaodeMap {
            
            let gaodeAction = UIAlertAction(title: "高德地图", style: .default) { (action) in
                
                //                guard self.getCurrentLocation().isUpdatedSuccess else{
                //                    return
                //                }
                //
                //                let ori = self.getCurrentLocation().origin!
                
                //&slat=\(ori.latitude)&slon=\(ori.longitude)&sname=我的位置&did=BGVIS2&d
                let str = "iosamap://navi?sourceApplication=浩优服务家&backScheme=hoyoServicer&lat=\(self.cLLocation!.latitude)&lon=\(self.cLLocation!.longitude)&name=目的地&dev=0&style=2"
                // 对汉字进行转码 stringByAddingPercentEscapesUsingEncoding => iOS9.0 addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let urlStr = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                
                guard let us = urlStr, let u = URL(string: us) else{
                    return
                }
                UIApplication.shared.openURL(u)
            }
            alertViewController.addAction(gaodeAction)
        }
        
        let appleAction = UIAlertAction(title: "苹果地图", style: .default) { (action) in
            
            //使用自带地图导航
            guard let des = self.cLLocation else{
                return
            }
            let destinationPlaceMark = MKPlacemark(coordinate: des, addressDictionary: nil)
            let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
            destinationMapItem.name = "目的地"
            
            let currentLocation = MKMapItem.forCurrentLocation()
            currentLocation.name = "我的位置"
            MKMapItem.openMaps(with: [currentLocation, destinationMapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: NSNumber.init(value: true)])
        }
        alertViewController.addAction(appleAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (cation) in}
        alertViewController.addAction(cancelAction)
        
        self.present(alertViewController, animated: true) {}
    }
}


// MARK: - MKMapViewDelegate

extension ZBMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.conforms(to: JPSThumbnailAnnotationViewProtocol.self) {
            (view as! JPSThumbnailAnnotationViewProtocol).didSelectAnnotationView(inMap: mapView)
        }
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.conforms(to: JPSThumbnailAnnotationViewProtocol.self) {
            (view as! JPSThumbnailAnnotationViewProtocol).didDeselectAnnotationView(inMap: mapView)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.conforms(to: JPSThumbnailAnnotationProtocol.self) {
            return (annotation as! JPSThumbnailAnnotationProtocol).annotationView(inMap: mapView)
        }
        return nil
        
    }
    
    // 返回指定的遮盖模型所对应的遮盖视图
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // 针对线段,系统有提供好的遮盖视图
        let render = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        
        // 配置遮盖的宽度-颜色
        render.lineWidth = 5.0
        render.strokeColor = UIColor.red
        
        MBProgressHUD.hide(for: self.mkMapView, animated: true)
        return render
    }
    
}
