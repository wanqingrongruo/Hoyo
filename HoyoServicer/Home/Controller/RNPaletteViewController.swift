//
//  RNPaletteViewController.swift
//  RNDrawBoardView
//
//  Created by 婉卿容若 on 2017/2/20.
//  Copyright © 2017年 婉卿容若. All rights reserved.
//

import UIKit

class RNPaletteViewController: UIViewController {
    
    // constant
    let myBounds = UIScreen.main.bounds
    let padding: CGFloat = 40.0
    let space: CGFloat = 20.0


    var paletteImage: UIImage? = nil // 签名
    
    var paletteInfo: (_ isPalette: Bool, _ paletteImage: UIImage?) -> Void // 回调
    
    var paletteImageView: UIImageView? = nil
    var paletteView: RNDrawimgView? = nil
    
    init(callBack: @escaping (Bool, UIImage?) -> Void){
       
        paletteInfo = callBack
       
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "添加电子签名"
        
        view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        addButton()
        
        if let image = paletteImage {
            addImageView(image: image)
            let alertView = SCLAlertView()
            alertView.showTitle("提示", subTitle: "点击修改按钮可对签名进行修改", duration: 1.5, completeText: "", style: .notice)
            
        }else{
            addView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isTranslucent = false
     
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    deinit{
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - private methods

extension RNPaletteViewController{
    
    func addImageView(image: UIImage?){
        
        if paletteImageView == nil {
            paletteImageView = UIImageView(frame: CGRect(x: 0, y: 64, width: myBounds.width, height: myBounds.height-64-90))
            paletteImageView?.image = image
            
            if let imageView = paletteImageView {
                view.addSubview(imageView)
            }
            
        }
    }
    
    func addView(){
        
        if paletteView == nil{
            paletteView = RNDrawimgView(frame: CGRect(x: 0, y: 64, width: myBounds.width, height: myBounds.height-64-90))
            paletteView?.backgroundColor = UIColor.white
            if let drawingView = paletteView {
                view.addSubview(drawingView)
            }
        }
       

    }
    
    func addButton(){
        
        let buttonWidth = (myBounds.width-padding*2-space)/2.0
        
        let bottomView = UIView(frame: CGRect(x: 0, y: myBounds.height-90, width: myBounds.width, height: 90))
        bottomView.backgroundColor =  UIColor(colorLiteralRed: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        view.addSubview(bottomView)
        
        
        let motifyButton = RNBaseUI.createButton("修改", titleColor: UIColor.black, font: 20, alignment: .center, target: self, sel: #selector(clcikAction(sender:)))
        motifyButton.backgroundColor = UIColor.white
        motifyButton.layer.cornerRadius = 5.0
        motifyButton.layer.borderWidth = 2.0
        motifyButton.layer.borderColor = UIColor(colorLiteralRed: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
        motifyButton.frame = CGRect(x: padding, y: 20, width: (myBounds.width-40*2-20)/2.0, height: 50)
        motifyButton.tag = 100
        bottomView.addSubview(motifyButton)
        
        let saveButton = RNBaseUI.createButton("保存", titleColor: UIColor.white, font: 20, alignment: .center, target: self, sel: #selector(clcikAction(sender:)))
        saveButton.backgroundColor = UIColor.orange
        saveButton.layer.cornerRadius = 5.0
       // saveButton.layer.borderWidth = 2.0
        //saveButton.layer.borderColor = UIColor(colorLiteralRed: 80.0/255.0, green: 80.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
        saveButton.frame = CGRect(x: myBounds.width - (buttonWidth+padding), y: 20, width: buttonWidth, height: 50)
        saveButton.tag = 200
        bottomView.addSubview(saveButton)
    }
    
    func clcikAction(sender: UIButton){
        
        switch sender.tag {
        case 100:
            
            paletteInfo(false, nil)
            paletteView?.isDrawed = false
            // 修改
            if let _ = paletteImage {
                guard let imageView = paletteImageView else {
                    return
                }
                paletteImageView = nil
                imageView.removeFromSuperview()
                addView()
            }else{
                paletteView = nil
                paletteView?.removeFromSuperview()
                addView()
            }
        case 200:
            // 保存
            // 弹出返回提示
            guard let paletteView = paletteView else {
                return
            }
            
            if paletteView.isDrawed{
                paletteInfo(true, capture(paletteView, size: paletteView.bounds.size.width))
                
                let alertView=SCLAlertView()
                alertView.addButton("取消", action: { })
                alertView.addButton("确定", action: { [weak self] in
                    
                    _ = self?.navigationController?.popViewController(animated: true)
                })
                alertView.showNotice("提示", subTitle: "签名已保存,是否返回?")

            }else{
                // 弹出未签名提示
                let alertView=SCLAlertView()
                alertView.addButton("取消", action: { })
                alertView.addButton("确定", action: { [weak self] in
                    
                    self?.paletteInfo(false, nil)
                    _ = self?.navigationController?.popViewController(animated: true)
                    
                })
                alertView.showNotice("提示", subTitle: "尚未签名,是否返回?")
            }
           
            
            break
        default:
             break
        }
    }
    
    func capture(_ theView: RNDrawimgView, size: CGFloat) -> UIImage?{
        
        // 已画
        if theView.isDrawed {
            let rect = theView.frame
           // UIGraphicsBeginImageContext(rect.size) // 模糊
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0) // 原图
            let context = UIGraphicsGetCurrentContext()
            
            guard let context02 = context else {
                return nil
            }
            
            theView.layer.render(in: context02)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image

        }else{
            // 弹出未签名提示
            let alertView=SCLAlertView()
            alertView.addButton("取消", action: { })
            alertView.addButton("确定", action: { [weak self] in
                
                _ = self?.navigationController?.popViewController(animated: true)
                
            })
            alertView.showNotice("提示", subTitle: "尚未签名,是否返回?")
            return nil
        }
    }
    
    // 返回
    func disMissBtn(){

//        // 弹出返回提示
//        guard let paletteView = paletteView else {
//            return
//        }
//        paletteInfo(true, capture(paletteView, size: paletteView.bounds.size.width))
        
//        let alertView=SCLAlertView()
//        alertView.addButton("确定", action: { [weak self] in
        
            _ = self.navigationController?.popViewController(animated: true)
//        })
//        alertView.showNotice("提示", subTitle: "签名已保存,是否返回?")

    }

}
