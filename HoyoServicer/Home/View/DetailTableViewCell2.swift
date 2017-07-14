//
//  DetailTableViewCell2.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 11/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class DetailTableViewCell2: UITableViewCell {
    //到达时间
    @IBOutlet weak var arrivetime: UILabel!
    //用时
    @IBOutlet weak var usertime: UILabel!
    
    //服务费
    @IBOutlet weak var money: UILabel!
    
    //机器型号
    @IBOutlet weak var machineType: UILabel!
    
    //机器编号
    @IBOutlet weak var machineCode: UILabel!
    
    //支付方式
    @IBOutlet weak var payWay: UILabel!
    
    //故障
    @IBOutlet weak var troubleDetail: UILabel!
    
    //原因
    
    @IBOutlet weak var reason: UILabel!
    
    //评价
    @IBOutlet weak var remark: UILabel!
    
    //评论视图
    @IBOutlet weak var remarkView: UIView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var remarkBottomAndPhotoTop: NSLayoutConstraint!
   
    @IBOutlet weak var img01: UIImageView!
    @IBOutlet weak var img02: UIImageView!
    @IBOutlet weak var img03: UIImageView!
    @IBOutlet weak var img04: UIImageView!
    @IBOutlet weak var img05: UIImageView!
    
    var myFinishDetail: FinshDetail? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img01.addGestureRecognizer(tap01)
        let tap02 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img02.addGestureRecognizer(tap02)
        let tap03 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img03.addGestureRecognizer(tap03)
        let tap04 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img04.addGestureRecognizer(tap04)
        let tap05 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img05.addGestureRecognizer(tap05)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showDetail2Text(_ finishDetail : FinshDetail)
    {
        myFinishDetail = finishDetail
        
        // 无评价内容时移除remarkView
        if finishDetail.remark == "" {
            self.remarkView.removeFromSuperview()
        }
        
        let  timeStamp  =  DateTool.dateFromServiceTimeStamp(finishDetail.arrivetime! )!
        self.arrivetime.text =  DateTool.stringFromDate(timeStamp, dateFormat: "yyyy年MM月dd日")
        self.money.text = finishDetail.money
        

        if let pw = finishDetail.payWay {
            switch  pw {
            case "Money":
                self.payWay.text = "现金"
            case "124020040":
                self.payWay.text = "现金"
            case "124010020":
                self.payWay.text = "微信"
            case "124010001":
                self.payWay.text = "Pos机"
            case "N-Money":
                self.payWay.text = "无需支付"
            case "124010040":
                self.payWay.text = "无需支付"
            default:
                self.payWay.text = "其他"
                break
            }
        }else{
            self.payWay.text = "其他"
        }
      
//        if finishDetail.payWay == "Money" {
//           
//        }
//        else{
//            self.payWay.text = "其他"
//            
//        }
        
        let ss = finishDetail.remark
        self.machineType.text = finishDetail.machineType ?? "未知"
        self.machineCode.text = finishDetail.machineCode ?? "未知"
        self.troubleDetail.text = finishDetail.troubleDetail
        self.reason.text = finishDetail.reason ?? "未填写"
        self.remark.text = ss //finishDetail.remark ?? "未填写"
        self.usertime.text = finishDetail.usetime ?? "0" + "分钟"
        
        // 当没有图片时移除photoView
        if let photos = finishDetail.photos, photos.count > 0{
           
            for (index, value) in photos.enumerated() {
                
                switch index {
                case 0:
                    
                    let url = NSURL(string: value)
                    if let u = url {
                        img01.sd_setImage(with: u as URL, placeholderImage: UIImage(named: "myLogo"))
                        img01.isUserInteractionEnabled = true
                    }
                case 1:
                    let url = NSURL(string: value)
                    if let u = url {
                        img02.sd_setImage(with: u as URL, placeholderImage: UIImage(named: "myLogo"))
                        img02.isUserInteractionEnabled = true
                    }
                case 2:
                    let url = NSURL(string: value)
                    if let u = url {
                        img03.sd_setImage(with: u as URL, placeholderImage: UIImage(named: "myLogo"))
                        img03.isUserInteractionEnabled = true
                    }
                case 3:
                    let url = NSURL(string: value)
                    if let u = url {
                        img04.sd_setImage(with: u as URL, placeholderImage: UIImage(named: "myLogo"))
                        img04.isUserInteractionEnabled = true
                    }
                case 4:
                    let url = NSURL(string: value)
                    if let u = url {
                        img05.sd_setImage(with: u as URL, placeholderImage: UIImage(named: "myLogo"))
                        img05.isUserInteractionEnabled = true
                    }
                    
                default:
                    break
                }
            }
            
        }else{
            photoView.removeFromSuperview()
        }
                
    }
    
    func addPicAction(press: UITapGestureRecognizer) {
        
        let imgView = press.view as! UIImageView
        
                let photos = myFinishDetail?.photos
                
                if let p = photos{
                    XLPhotoBrowser.show(withCurrentImageIndex: imgView.tag-100, imageCount: UInt(p.count), datasource: self)
                   
                }else{
                let alert = SCLAlertView()
                alert.addButton("确定", action: {})
                alert.showError("提示", subTitle: "抱歉,未获取到图片")
            }
            
        
    }

}

extension DetailTableViewCell2: XLPhotoBrowserDatasource{
    
    
    func photoBrowser(_ browser: XLPhotoBrowser!, highQualityImageURLFor index: Int) -> URL! {
        let photos = myFinishDetail?.photos
        
        if let p = photos{
            
            let url = NSURL(string: p[index])
            
            if let u = url{
                return u as URL!
            }
        }
        return NSURL(string: "http://upload-images.jianshu.io/upload_images/565029-7d79967cc91e1936.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240") as URL!
    }
    
    //func photoBrowser(_ browser: XLPhotoBrowser!, sourceImageViewFor index: Int) -> UIImageView! {
    //     return myImageView
    //  }
    
}

