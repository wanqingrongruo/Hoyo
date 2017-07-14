//
//  HomeTableViewCell.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
@objc protocol CirCleViewDelegate {
    /**
     *  点击banner图片的代理方法
     *  @para  currentIndxe 当前点击图片的下标
     */
    @objc optional func clickCurrentImage(_ currentIndxe: Int)
}

protocol HomeTableViewCellDelegate {
    
    func scanQR() // 扫描二维码
}
class HomeTableViewCell: UITableViewCell,UIScrollViewDelegate {

    var buttonClickCallBack:((_ whichButton:Int)->Void)?
    @IBOutlet weak var starImg1: UIImageView!
    @IBOutlet weak var starImg2: UIImageView!
    @IBOutlet weak var starImg3: UIImageView!
    @IBOutlet weak var starImg4: UIImageView!
    @IBOutlet weak var starImg5: UIImageView!
    @IBAction func buttonClick(_ sender: UIButton) {
        if buttonClickCallBack==nil{
            return
        }
        buttonClickCallBack!(sender.tag)
    }
    @IBOutlet weak var personImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var QRButton: UIButton! // 二维码按钮
    
    @IBOutlet weak var unDealLabel: UILabel! // 待处理上的未处理的订单数
    @IBOutlet weak var DealLabelWidthLayout: NSLayoutConstraint! // label的宽度约束
    
    var scoreOfStar = 0{
        didSet{
            if scoreOfStar==oldValue {
                return
            }
            starImg1.image=UIImage(named: scoreOfStar>0 ? "starsedOfHome":"starsOfHome")
            starImg2.image=UIImage(named: scoreOfStar>1 ? "starsedOfHome":"starsOfHome")
            starImg3.image=UIImage(named: scoreOfStar>2 ? "starsedOfHome":"starsOfHome")
            starImg4.image=UIImage(named: scoreOfStar>3 ? "starsedOfHome":"starsOfHome")
            starImg5.image=UIImage(named: scoreOfStar>4 ? "starsedOfHome":"starsOfHome")
            
        }
    }
    
    //banner
    @IBOutlet weak var footerScrollView: XRCarouselView!

    @IBOutlet weak var orderAboutLabel: UILabel!
    
    
    var delegate: HomeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
       // personImg.layer.cornerRadius = personImg.frame.width/2.0
        personImg.layer.masksToBounds = true
        personImg.layer.cornerRadius =  personImg.frame.size.width / 2.0
        
        self.unDealLabel.isHidden = true
        
        
       // QRButton.hidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    //footer banner视图
    func footerScrollViewSetup(_ imageArray: [String]){
        
        footerScrollView.imageArray = imageArray
        footerScrollView.placeholderImage = UIImage(named: "banner2")
        
        footerScrollView.setPageColor(UIColor.white, andCurrentPageColor: UIColor.blue)// 分页控制器颜色
        footerScrollView.changeMode = ChangeModeFade // 图片切换方式
//        footerScrollView.imageClickBlock = { (index) in
//            
//            print("点击了第\(index)张图片")
//            
//        }
        footerScrollView.delegate = self // 代理 -- 也可用上面的 block
        footerScrollView.time = 2.0 // 时间间隔
        
    }

    // 扫描二维码
    @IBAction func scanAction(_ sender: UIButton) {
        
        self.delegate?.scanQR()
    }
}

extension HomeTableViewCell: XRCarouselViewDelegate{
    
    func carouselView(_ carouselView: XRCarouselView!, clickImageAt index: Int) {
         print("点击了第\(index)张图片")
    }
}
