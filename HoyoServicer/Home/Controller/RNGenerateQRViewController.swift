//
//  RNGenerateQRViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/12/22.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNGenerateQRViewController: UIViewController {
    
    var qrContent: String?
    
    // 一维码
    lazy var BRImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        return imageView
    }()
    
    // 二维码
    lazy var QRImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        return imageView
    }()
    
    var myImage: UIImage = UIImage() // 用于展示图片
    var myImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "我的二维码"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        view.backgroundColor = COLORRGBA(46, g: 49, b: 59, a: 1)
        
        
        self.setupUI()
        
        
        self.generateBR()
        
        self.generateQR()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - custom methods

extension RNGenerateQRViewController{
    
    func setupUI(){
        
//        let padding = 10
//        let margin = 15
        
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        backView.layer.cornerRadius = 3.0
        backView.frame = CGRect(x: 20, y: 80, width: WIDTH_SCREEN-40, height: HEIGHT_SCREEN-64-160)
        view.addSubview(backView)
//        backView.snp.makeConstraints { (make) in
//            make.top.equalTo(view.snp.top).offset(80)
//            make.leading.equalTo(view.snp.leading).offset(20)
//            make.bottom.equalTo(view.snp.bottom).offset(-80)
//            make.trailing.equalTo(view.snp.trailing).offset(-20)
//        }
        
        let brView = UIView()
        brView.backgroundColor = UIColor.clear
        brView.frame = CGRect(x: 0, y: 0, width: backView.bounds.size.width, height: backView.bounds.size.height*0.4)
        backView.addSubview(brView)
        brView.clipCornerRadiusForView(brView, RoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], Radii: CGSize(width: 3, height: 3))
//        brView.snp.makeConstraints { (make) in
//            make.top.equalTo(0)
//            make.leading.equalTo(0)
//            make.trailing.equalTo(0)
//            make.height.equalTo(backView.snp.height).multipliedBy(0.4)
//        }
        
        BRImageView.frame = CGRect(x: 20, y: 40, width: brView.bounds.size.width-40, height: brView.bounds.size.height-60)
        BRImageView.tag = 100
        BRImageView.isUserInteractionEnabled = true
        brView.addSubview(BRImageView)
//        BRImageView.snp.makeConstraints { (make) in
//            make.top.equalTo(padding)
//            make.leading.equalTo(margin)
//            make.bottom.equalTo(-padding)
//            make.trailing.equalTo(-margin)
//        }
        
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(showImage(tap:)))
        BRImageView.addGestureRecognizer(tap01)
        
        let qrView = UIView()
        qrView.backgroundColor = COLORRGBA(245, g: 245, b: 245, a: 1)
        qrView.frame = CGRect(x: 0, y: brView.bounds.size.height, width: backView.bounds.size.width, height: backView.bounds.size.height*0.6)
        backView.addSubview(qrView)
        qrView.clipCornerRadiusForView(qrView, RoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight], Radii: CGSize(width: 3, height: 3))
//        qrView.snp.makeConstraints { (make) in
//            make.top.equalTo(brView.snp.bottom).offset(0)
//            make.leading.equalTo(0)
//            make.trailing.equalTo(0)
//            make.bottom.equalTo(0)
//        }
        QRImageView.frame = CGRect(x:  (qrView.bounds.size.width - qrView.bounds.size.height+30)*0.5, y: 20, width: qrView.bounds.size.height-30, height: qrView.bounds.size.height-60)
        QRImageView.tag = 200
        QRImageView.isUserInteractionEnabled = true
        qrView.addSubview(QRImageView)
//        QRImageView.snp.makeConstraints { (make) in
//            make.top.equalTo(padding)
//            make.bottom.equalTo(-padding-10)
//            make.centerX.equalTo(qrView.snp.centerX)
//            make.width.equalTo(QRImageView.snp.height)
//        }
        
        let tap02 = UITapGestureRecognizer(target: self, action: #selector(showImage(tap:)))
        QRImageView.addGestureRecognizer(tap02)
        
    }
    
    func generateBR(){
        guard  let qrCon = qrContent, qrCon != "" else {
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {
                let _ = self.navigationController?.popViewController(animated: true)
            })
            alertView.showError("提示", subTitle: "没有数据用于生成条形码,返回")
            return
        }
        
//        let brImage = LBXScanWrapper.createCode128(codeString: qrCon, size: BRImageView.bounds.size, qrColor: UIColor.black, bkColor: UIColor.white)
//        BRImageView.image = brImage
        //        if let image =  generateBRCodeImage(qrCon, size: BRImageView.bounds.size.width){
        //            BRImageView.image = image
        //        }else{
        //
        //            let alertView=SCLAlertView()
        //            alertView.addButton("确定", action: {
        //            })
        //            alertView.showError("提示", subTitle: "生成条形码不成功")
        //            return
        //        }
        
        guard let imageWithColor = setCodeColor(generateBRCodeImage(qrCon, size:QRImageView.bounds.size.width), codeColor: UIColor.black, bgColor: UIColor.white) else{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {
            })
            alertView.showError("提示", subTitle: "生成二维码不成功")
            
            return
        }

        BRImageView.image = imageWithColor
    }
    
    
    func generateQR(){
        
        guard  let qrCon = qrContent, qrCon != "" else {
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {
                let _ = self.navigationController?.popViewController(animated: true)
            })
            alertView.showError("提示", subTitle: "没有数据用于生成二维码,返回")
            return
        }
//        
//        let qrImage = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: qrCon, size: QRImageView.bounds.size, qrColor: UIColor.black, bkColor: UIColor.white)
//        let logoImage = UIImage(named: "myLogo")
//        QRImageView.image = LBXScanWrapper.addImageLogo(srcImg: qrImage!, logoImg: logoImage!, logoSize: CGSize(width: 30, height: 30))
        
                // 清晰的二维码
//                guard let image =  generateQRCodeImage(qrCon, size:QRImageView.bounds.size.width) else{
//        
//                    let alertView=SCLAlertView()
//                    alertView.addButton("确定", action: {
//                    })
//                    alertView.showError("提示", subTitle: "生成二维码不成功")
//        
//                    return
//                }
        
                // 颜色
        guard let imageWithColor = setCodeColor(generateQRCodeImage(qrCon, size:QRImageView.bounds.size.width), codeColor: UIColor.black, bgColor: UIColor.white) else{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {
            })
            alertView.showError("提示", subTitle: "生成二维码不成功")
            
            return
        }
        
        // 二维码中间加 logo
        guard let imageWithLogo = createCustomImage(bigImage: imageWithColor, smallImage:  UIImage(named: "myLogo")!, smallImageWH: 30) else {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {
            })
            alertView.showError("提示", subTitle: "生成二维码不成功")
            
            return
        }
        
        QRImageView.image = imageWithLogo
        
    }
    
    func generateBRCodeImage(_ content: String, size: CGFloat) -> UIImage?{
        // 系统必须大于8.0
        guard let version = Float(UIDevice.current.systemVersion), version > 8.0 else {
            return nil
        }
        
        // 创建滤镜
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        
        // 还原滤镜的默认属性
        filter.setDefaults()
        // 设置需要生成的二维码数据
        let contentData = content.data(using: String.Encoding.ascii)
        filter.setValue(contentData, forKey: "inputMessage")
        filter.setValue(0, forKeyPath: "inputQuietSpace")
        
        // 从滤镜中取出生成的图片
        guard let ciImage = filter.outputImage else {
            return nil
        }
        
        return createClearImage(ciImage, size: size)
    }
    
    func generateQRCodeImage(_ content: String, size: CGFloat) -> UIImage?{
        
        // 创建滤镜
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        // 还原滤镜的默认属性
        filter.setDefaults()
        // 设置需要生成的二维码数据
        // 如果要设置二维码内容,必须以KVC的方式设置
        // 二维码的值必须是NSData
        let contentData = content.data(using:.utf8)
        filter.setValue(contentData, forKey: "inputMessage")
        // 4.设置二维码的级别(纠错率)
        //        key : inputCorrectionLevel
        //        value L: 7% M(默认  ): 15% Q: 25% H: 30%
        filter.setValue("H", forKeyPath: "inputCorrectionLevel")
        
        
        // 从滤镜中取出生成的图片
        //        guard let ciImage = filter.outputImage else {
        //            return nil
        //        }
        
        return createClearImage(filter.outputImage, size: size)
    }
    
    // 设置 清晰度
    /// - parameter image: 模糊的二维码图片
    /// - parameter size: 需要生成的二维码尺寸
    /// - returns: 清晰的二维码图片
    
    fileprivate func createClearImage(_ image : CIImage?, size : CGFloat ) -> UIImage? {
        
        
        guard let image = image else {
            return nil
        }
        // 1.调整小数像素到整数像素,将origin下调(12.*->12),size上调(11.*->12)
        let extent = image.extent.integral
        
        // 2.将指定的大小与宽度和高度进行对比,获取最小的比值
        let scale = min(size / extent.width, size/extent.height)
        
        // 3.将图片放大到指定比例
        let width = extent.width * scale
        let height = extent.height * scale
        // 3.1创建依赖于设备的灰度颜色通道
        let cs = CGColorSpaceCreateDeviceGray();
        // 3.2创建位图上下文
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        
        // 4.创建上下文
        let context = CIContext(options: nil)
        
        // 5.将CIImage转为CGImage
        let bitmapImage = context.createCGImage(image, from: extent)
        
        // 6.设置上下文渲染等级
        bitmapRef.interpolationQuality = .none
        
        // 7.改变上下文的缩放
        bitmapRef.scaleBy(x: scale, y: scale)
        
        // 8.绘制一张图片在位图上下文中
        bitmapRef.draw(bitmapImage!, in: extent)
        
        // 9.从位图上下文中取出图片(CGImage)
        guard let scaledImage = bitmapRef.makeImage() else {return nil}
        
        // 10.将CGImage转为UIImage并返回
        return UIImage(cgImage: scaledImage)
        //        let extent = image.extent.integral
        //        let scale = min(size / extent.width, size/extent.height)
        //        let cgImage = CIContext(options: nil).createCGImage(image, from: extent)
        //        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        //        let context = UIGraphicsGetCurrentContext()!
        //        context.interpolationQuality = .none
        //        context.scaleBy(x: scale, y: scale)
        //        context.draw(cgImage!, in: extent)
        //        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        //        UIGraphicsEndImageContext()
        //        guard let resultImage = codeImage else {
        //            return nil
        //        }
        //
        //        return resultImage
    }
    
    
    // 设置颜色 => 必须放在设置清晰度函数后面
    /// - parameter image: 模糊的二维码图片
    /// - parameter size: 需要生成的二维码尺寸
    /// - returns: 清晰的二维码图片
    func setCodeColor(_ image: UIImage?, codeColor: UIColor, bgColor: UIColor) -> UIImage?{
        
        guard let imageUI = image else {
            return nil
        }
        
        // 设置二维码颜色
        let imageCI = CIImage(image: imageUI)
        let colorFilter = CIFilter(name:"CIFalseColor")
        colorFilter?.setDefaults()
        
        // 设置图片
        colorFilter?.setValue(imageCI, forKeyPath: "inputImage")
        // 设置二维码颜色
        colorFilter?.setValue(CIColor.init(color: codeColor), forKeyPath: "inputColor0")
        
        // 设置背景颜色
        colorFilter?.setValue(CIColor.init(color: bgColor), forKeyPath: "inputColor1")
        guard let colorOutPutImage = colorFilter?.outputImage else {
            return nil
        }
        
        return UIImage(ciImage: colorOutPutImage)
    }
    
    
    // 在二维码中间插入图片
    // 注意点：二维码可以遮挡部分区域,但是要保证三个角不能被遮挡,三个角用于扫描定位(用户可能斜着拍\\\\\\\\倒着拍)
    fileprivate func createCustomImage(bigImage : UIImage, smallImage : UIImage, smallImageWH : CGFloat) -> UIImage? {
        
        // 0.获取大图片的尺寸
        let bigImageSize = bigImage.size
        
        // 1.创建图形上下文
        UIGraphicsBeginImageContext(bigImageSize)
        
        // 2.绘制大图片
        bigImage.draw(in: CGRect(x: 0, y: 0, width: bigImageSize.width, height: bigImageSize.height))
        
        // 3.绘制小图片
        smallImage.draw(in: CGRect(x: (bigImageSize.width - smallImageWH) * 0.5, y: (bigImageSize.height - smallImageWH) * 0.5, width: smallImageWH, height: smallImageWH))
        
        // 4.从上下文取出图片
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5.关闭上下文
        UIGraphicsEndImageContext()
        
        return outImage
    }
}

// MARK: - event response

extension RNGenerateQRViewController{
    
    func disMissBtn() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func showImage(tap: UITapGestureRecognizer){
        
       
        let imgView = tap.view as! UIImageView
        if let image = imgView.image {
            myImage = image
            myImageView = imgView
            XLPhotoBrowser.show(withCurrentImageIndex: imgView.tag, imageCount: 1, datasource: self)
            
        }else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "抱歉,未获取到图片")
        }
    }
}

extension RNGenerateQRViewController: XLPhotoBrowserDatasource{
    func photoBrowser(_ browser: XLPhotoBrowser!, placeholderImageFor index: Int) -> UIImage! {
        return myImage
    }
    
//    func photoBrowser(_ browser: XLPhotoBrowser!, sourceImageViewFor index: Int) -> UIImageView! {
//         return myImageView
//    }
    
}

