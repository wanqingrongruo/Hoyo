//
//  DetailViewCell.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 30/3/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.


import UIKit
import MBProgressHUD
import SwiftyJSON

protocol DetailViewCellDelegate {
    func backToSuperCon()
    func showBrowPhtotoCon(_ cell :BrowseCollectionViewCell,browseItemArray:NSMutableArray)
    func pushToSubmitView()
    func pushToFinshView()
    
    func generateQR(text: String) // 生成二维码
}
class DetailViewCell: UITableViewCell,UICollectionViewDataSource,UIViewControllerTransitioningDelegate,UICollectionViewDelegate {
    
    var arr = [String]() //存放图片的数组
    
    //collectionView的背景View
    @IBOutlet weak var collectionViewBlackView: UIView!
    var orderDetail : OrderDetail?
    
    var imageDetailArr  :[String]?
    @IBOutlet weak var collectView: UICollectionView!
    //详情图片描述
    //   @IBOutlet weak var imageDetail: UIImageView!
    
    //头像
    @IBOutlet weak var headView: UIImageView!
    //背景
    @IBOutlet weak var topImage: UIImageView!
    //抢单
    @IBOutlet weak var robBtn: UIButton!
    //审核状态
    @IBOutlet weak var checkState: UILabel!
    @IBOutlet weak var expressCodeLabel: RNMultiFunctionLabel! // 快递单号
    @IBOutlet weak var orderCodeLabel: RNMultiFunctionLabel! // 订单编号
    @IBOutlet weak var CRMIDLabel: RNMultiFunctionLabel! // CRM 编号
    @IBOutlet weak var hoyoIDLabel: RNMultiFunctionLabel! // 浩泽编号
    
    
    //手机号
    @IBOutlet weak var mobileLabel: RNMultiFunctionLabel!
    // 联系人
    @IBOutlet weak var clientNameLabel: RNMultiFunctionLabel!
    //座机号--也可能是手机号码(厂商电话)
    @IBOutlet weak var phoneLabel: RNMultiFunctionLabel!
 
    
    //产品
    @IBOutlet weak var troubleHandleType: UILabel! // 问题类型
    @IBOutlet weak var productBrandLabel: UILabel! // 品牌
    @IBOutlet weak var productNameLabel: UILabel! // 机器名称
    @IBOutlet weak var productModelLabel: UILabel! // 机器型号
    @IBOutlet weak var areaCodeLabel: UILabel! // 区域代码
    
    
    // 新增 feeView : 根据字段决定是否显示
    @IBOutlet weak var fatherView: UIView! // 整个 view(加在 contentView)
    @IBOutlet weak var headerView: UIView! // 头 view
    @IBOutlet weak var feeView: UIView! // 费用 view
    @IBOutlet weak var codeView: UIView! // 编号 View
    
    @IBOutlet weak var payDetailView: UIView! // 支付信息展示界面
    
    @IBOutlet weak var headbottomWithFeetopConstraint: NSLayoutConstraint! // headView 底部与 feeView头部之间的约束
    @IBOutlet weak var feebottomWithCodetopConstraint: NSLayoutConstraint! // feeView 底部与 codeView头部之间的约束
    
    //上门时间
    @IBOutlet weak var visitTime: UILabel!
    //问题描述
    @IBOutlet weak var troubleDescripe: MLEmojiLabel!
    
    //地点
    @IBOutlet weak var address: RNMultiFunctionLabel!
    //距离
    @IBOutlet weak var distance: UILabel!
    
    //提交时间按钮
    @IBOutlet weak var submit: UIButton!
    
    //点击完成按钮
    @IBOutlet weak var finish: UIButton!
    
    //包含button的view
    @IBOutlet weak var YQView: UIView!
    @IBOutlet weak var detailUserName: UILabel!
    
    var delegate :DetailViewCellDelegate?
    //定位按钮
    @IBOutlet weak var toAddressMapButton: UIButton!
    //目的地址
    @IBOutlet weak var aimAdress: UILabel!
    //目的地址的View
    @IBOutlet weak var aimAdressView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.robBtn.isEnabled = true
        headView.layer.masksToBounds = true
        headView.layer.cornerRadius = 35
        headView.layer.borderWidth = 3.0
        headView.layer.borderColor = UIColor.white.cgColor
        
        robBtn.layer.masksToBounds = true
        robBtn.layer.cornerRadius = 6
        collectView.delegate = self
        collectView.dataSource = self
        let flowLayout  =  UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
        
        
        collectView.collectionViewLayout = flowLayout
        
        //        // 为orderCodeLabel订单编号Label 提供复制粘贴
        //        orderCodeLabel.userInteractionEnabled = true
        //        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        //        orderCodeLabel.addGestureRecognizer(longPress)
        
        // 给编号 Label 添加复制操作orderCodeLabel
//        let longPress01 = UILongPressGestureRecognizer.init(target: self, action: #selector(copyAction(press:)))
//        longPress01.minimumPressDuration = 1.0
//        orderCodeLabel.isUserInteractionEnabled = true
//        orderCodeLabel.addGestureRecognizer(longPress01)
//        
//        let longPress02 = UILongPressGestureRecognizer.init(target: self, action: #selector(copyAction(press:)))
//        longPress02.minimumPressDuration = 1.0
//        CRMIDLabel.isUserInteractionEnabled = true
//        CRMIDLabel.addGestureRecognizer(longPress02)
//        
//        let longPress03 = UILongPressGestureRecognizer.init(target: self, action: #selector(copyAction(press:)))
//        longPress03.minimumPressDuration = 1.0
//        hoyoIDLabel.isUserInteractionEnabled = true
//        hoyoIDLabel.addGestureRecognizer(longPress03)
        
        let qrpress01 = UITapGestureRecognizer(target: self, action: #selector(qrAction(tap:)))
        CRMIDLabel.addGestureRecognizer(qrpress01)
        
         let qrpress02 = UITapGestureRecognizer(target: self, action: #selector(qrAction(tap:)))
        hoyoIDLabel.addGestureRecognizer(qrpress02)
        
        troubleDescripe.emojiDelegate = self
        
        mobileLabel.isOpenTapGesture = true
        phoneLabel.isOpenTapGesture = true
        
        expressCodeLabel.isSkip = true
     
    }
    
  
    
    func copyAction(press: UILongPressGestureRecognizer){
        
        let lab = press.view as! UILabel
       
        if press.state == UIGestureRecognizerState.began {
            if let t = lab.text, t != ""{
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {
                    
                    
                    let pboard = UIPasteboard.general
                    pboard.string = t
                    
                })
                alertView.addButton("取消", action: {})
                alertView.showInfo("提示", subTitle: "是否复制编号?")
            }

        }
        
    }
    
    // 生成二维码
    func qrAction(tap: UITapGestureRecognizer){
        
//        let la = tap.view as! UILabel
//        
//        if let t = la.text, t != "" {
//            print("生成二维码")
//            
//            self.delegate?.generateQR(text: t)
//        }
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func dialAction(_ sender: UIButton) { // 拨打号码
        
        guard let title = sender.titleLabel?.text else{
            return
        }
        
        let telephoneNum = "telprompt://\(title)"
        guard let tel = URL(string: telephoneNum) else{
            return
        }
        UIApplication.shared.openURL(tel)
        
        
    }
    
    @IBAction func click(_ sender: AnyObject) {
        let  tag = (sender as! UIButton).tag
        switch tag {
        case 0:
            print("抢单")
            
            guard let detail = self.orderDetail, let myId = detail.id else{
                return
            }
            
            MBProgressHUD.showAdded(to: self, animated: true)
           
            User.RobOrderV2(myId, success: {
                
                MBProgressHUD.hide(for: self, animated: true)
                self.robBtn.isEnabled = false
                let alertView=SCLAlertView()
                //                alertView.showSuccess("", subTitle: "抢单", closeButtonTitle:"")
                alertView.showSuccess("抢单成功", subTitle: "抢单", closeButtonTitle: "", duration: 0.5)
                let  durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DetailViewCell.backToRobLists), userInfo: nil, repeats: false)
                RunLoop.main.add(durationTimer, forMode: RunLoopMode.commonModes)
                
                }, failure: { (error) in
                    
                    MBProgressHUD.hide(for: self, animated: true)
                    
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("错误提示", subTitle: error.localizedDescription)
                    
                    
            })
            
            break
        case 1:
            print("上门时间")
            
            delegate?.pushToSubmitView()
            break
        case 2:
            print("完成")
            
            delegate?.pushToFinshView()
            
            
            break
        default:
            break
        }
        
        
        
        
    }
    //返回到上个容器
    func backToRobLists()
    {
        delegate?.backToSuperCon()
        
        
    }
    func showCellText(_ orderDetail: OrderDetail, title :String, distance: String, payInfos: [RNPAYDetailModel], vc: ListsDetailViewController)
        
    {
        
        if payInfos.count == 0{
            feeView.removeFromSuperview()
            
            fatherView.removeConstraint(headbottomWithFeetopConstraint)
            fatherView.removeConstraint(feebottomWithCodetopConstraint)
            
            let newContraint = NSLayoutConstraint(item: codeView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 3)
            fatherView.addConstraint(newContraint)
        }else{
            
            var lastView: RNFeeTypeView02?
            for (index,value) in payInfos.enumerated() {
                
                let newView = Bundle.main.loadNibNamed("RNFeeTypeView02", owner: self, options: nil)?.last as! RNFeeTypeView02
                newView.typeLabel.text = value.PayTitle
                
                
                guard value.Money != nil else{
                    return
                }
                
                let price = String(format: "%.2f元", value.Money!/100.0)
                newView.priceLabel.text = price
                if value.PayState == "128000010" {
                    
                    newView.payStatusLabel.text = "未支付"
                }else if value.PayState == "128010020"{
                    newView.payStatusLabel.text = "已支付"
                }
                
                payDetailView.addSubview(newView)
                
                if lastView == nil {
                    newView.snp.makeConstraints({ (make) in
                        make.top.equalTo(5)
                        make.leading.equalTo(0)
                        make.trailing.equalTo(0)
                    })
                    
                    if index == payInfos.count - 1 {
                        newView.snp.makeConstraints({ (make) in
                            make.bottom.equalTo(payDetailView.snp.bottom).offset(-10)
                        })
                    }
                }else{
                    
                    newView.snp.makeConstraints({ (make) in
                        make.top.equalTo(lastView!.snp.bottom).offset(5)
                        make.leading.equalTo(0)
                        make.trailing.equalTo(0)
                    })
                    
                    if index == payInfos.count - 1 {
                        newView.snp.makeConstraints({ (make) in
                            make.bottom.equalTo(payDetailView.snp.bottom).offset(-10)
                        })
                    }
                }
                
                lastView = newView
                
            }
            
            
            // print("_________________________________")
        }
        
        self.orderDetail = orderDetail
        
        for item in (self.orderDetail?.imageDetail?.components(separatedBy: "|"))! as [String] {
            if (item as String).hasSuffix("|") {
                
                arr.append(item.components(separatedBy: "|").first!)
            }
            else if  item != ""{
                arr.append(item)
            }
            
        }
        
        if title == "抢单"
        {
            YQView.removeFromSuperview()
        }
            
        else if (title == "待处理") {
            robBtn.removeFromSuperview()
        }
        else
        {
            YQView.removeFromSuperview()
            robBtn.removeFromSuperview()
            
        }
        // self.headView.sd_setImageWithURL(NSURL(string: orderDetail.headImage! as String))//
        if(title == "抢单"){
            self.headView.sd_setImage(with: URL(string: orderDetail.userImage! as String), placeholderImage: UIImage(named: "defaultImage.png"))
        }else{
            self.headView.sd_setImage(with: URL(string: orderDetail.enginerImage! as String), placeholderImage: UIImage(named: "defaultImage.png"))
        }
        //        self.topImage.sd_setImageWithURL(NSURL(string: orderDetail.topImage! as String))
//        self.orderCodeLabel.text = orderDetail.orderId ?? ""
//        self.CRMIDLabel.text = orderDetail.crmID ?? ""
//        self.hoyoIDLabel.text = orderDetail.hoyoID ?? ""
        
        self.orderCodeLabel.attributedText = addUnderLineForlabel(text: orderDetail.orderId != "" ? orderDetail.orderId! : "无", color: COLORRGBA(0, g: 122, b: 255, a: 1))
        self.CRMIDLabel.attributedText = addUnderLineForlabel(text: orderDetail.crmID != "" ? orderDetail.crmID! : "无", color: COLORRGBA(0, g: 122, b: 255, a: 1))
        self.hoyoIDLabel.attributedText = addUnderLineForlabel(text: orderDetail.hoyoID != "" ? orderDetail.hoyoID! : "无", color: COLORRGBA(0, g: 122, b: 255, a: 1))
        
        self.checkState.text  =  NetworkManager.defaultManager?.getTroubleHandle(orderDetail.checkState! as String!).firstObject as? String
        //        if (orderDetail.aimAdress==""){
        //        self.aimAdressView.removeFromSuperview()
        //        }else
        //        { self.aimAdress.text=orderDetail.aimAdress}
        if (orderDetail.aimAdress == "")
        {
            self.aimAdress.text = "无"
        }
        else
        {
            self.aimAdress.text=orderDetail.aimAdress
        }
//        self.mobileButton.setTitle(orderDetail.mobile, for: UIControlState())
//        
//        
//        self.phoneButton.setTitle(orderDetail.telephoneNumber, for: UIControlState())
        
        self.expressCodeLabel.text = orderDetail.expressCode != "" ? orderDetail.expressCode : "无"
        
//        self.mobileLabel.text = orderDetail.mobile != "" ? orderDetail.mobile! : "无"
//        self.phoneLabel.text = orderDetail.telephoneNumber != "" ? orderDetail.telephoneNumber! : "无"
        
        self.mobileLabel.attributedText = addUnderLineForlabel(text: orderDetail.mobile != "" ? orderDetail.mobile! : "无", color: COLORRGBA(0, g: 122, b: 255, a: 1))
        self.phoneLabel.attributedText = addUnderLineForlabel(text:orderDetail.telephoneNumber != "" ? orderDetail.telephoneNumber! : "无", color: COLORRGBA(0, g: 122, b: 255, a: 1))
//        self.mobileButton.setAttributedTitle(addUnderLineForlabel(text: orderDetail.mobile != "" ? orderDetail.mobile! : "无", color: COLORRGBA(0, g: 122, b: 255, a: 1)), for: UIControlState.normal)
//        self.phoneButton.setAttributedTitle(addUnderLineForlabel(text: orderDetail.telephoneNumber != "" ? orderDetail.telephoneNumber! : "无", color: COLORRGBA(0, g: 122, b: 255, a: 1)), for: UIControlState.normal)
        
        self.clientNameLabel.text = orderDetail.clientName != "" ? orderDetail.clientName : "无"
        
        self.troubleHandleType.text = orderDetail.troubleHandleType ?? "无"
        self.productBrandLabel.text = orderDetail.productBrand ?? "无"
        self.productNameLabel.text = orderDetail.productName ?? "无"
        self.productModelLabel.text = orderDetail.productModel ?? "无"
        self.areaCodeLabel.text = orderDetail.areaCode != "" ? orderDetail.areaCode : "无"
        
        if orderDetail.troubleDescripe == "" || orderDetail.troubleDescripe == nil{
            self.troubleDescripe.text = "无"
        }else{
            self.troubleDescripe.emojiText = orderDetail.troubleDescripe
            // 识别电话号码
          //  self.troubleDescripe.addLink(toPhoneNumber: orderDetail.troubleDescripe, with: NSMakeRange(0, (orderDetail.troubleDescripe?.characters.count)!))
        }
        
        guard let _ = orderDetail.province, let _ = orderDetail.city, let _ = orderDetail.country, let _ = orderDetail.address else {
            return
        }
        
        self.address.text = "\(orderDetail.province!)\(orderDetail.city!)\(orderDetail.country!)\(orderDetail.address!)"
      //  self.address.text = orderDetail.province! + orderDetail.city! + orderDetail.country! + orderDetail.address!
        if (((orderDetail.visitTime?.hasPrefix("\\Date(")) != nil) || ((orderDetail.visitTime?.hasPrefix("/Date(")) != nil)) && (orderDetail.visitTime! as NSString).length >= 9 {
            
            let  timeStamp  =  DateTool.dateFromServiceTimeStamp(orderDetail.visitTime! )!
            
            //cell.remark.text   =  DateTool.stringFromDate(timeStamp, dateFormat: "yyyy-MM-dd")+" "+self.scorelists[indexPath.row-1].remark!
            self.visitTime.text =  DateTool.stringFromDate(timeStamp, dateFormat: "yyyy年MM月dd日 HH:mm")
            
        } else {
            
            self.visitTime.text = orderDetail.visitTime
        }
        //  let tmp = (orderDetail.distance! as NSString).doubleValue
        self.distance.text =  "距离" + String(format: "%.2lf",Double(distance)!) + "" + "km"
        self.detailUserName.text = orderDetail.nickname
        
        
        // 废弃不用,但是不想改 xib, 代码先放着
        self.collectView!.register(UINib(nibName:"BrowseCollectionViewCell", bundle:nil), forCellWithReuseIdentifier:"BrowseCollectionViewCell")
        
     //   if arr.count == 0{
            
            self.collectionViewBlackView.removeFromSuperview()
            
      //  }
        
      //  self.collectView.reloadData()
        
        
        if let expressCode = expressCodeLabel.text, expressCode != "无"{
            expressCodeLabel.skipEvent = { [weak vc] in
                
                let tmpUrl = "https://m.kuaidi100.com/result.jsp?nu=" + expressCode
                
                let urlContrller = RNExpressShowViewController(nibName: "RNExpressShowViewController", bundle: nil)
                urlContrller.tmpTitle = "物流详情"
                urlContrller.URLString = tmpUrl
                
                
              //  let urlContrller = WeiXinURLViewController(Url: tmpUrl, Title: "物流详情")
                vc?.navigationController?.pushViewController(urlContrller, animated:  true)
            }
        }
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell =   collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseCollectionViewCell", for: indexPath) as! BrowseCollectionViewCell
        cell.imageView.sd_setImage(with: URL(string: arr[indexPath.row] as String))
        cell.imageView.tag = indexPath.row + 100
        cell.imageView.clipsToBounds = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let browseItemArray = NSMutableArray()
        //var  i = 0
        for i in 0..<arr.count{
            
            let imageView = UIApplication.shared.keyWindow?.viewWithTag(i+100)
            let    browseItem = MSSBrowseModel()
            browseItem.bigImageUrl = arr[i]
            browseItem.smallImageView = imageView as! UIImageView
            browseItemArray.add(browseItem)
            
        }
        let cell = collectionView.cellForItem(at: indexPath) as! BrowseCollectionViewCell
        delegate?.showBrowPhtotoCon(cell ,browseItemArray: browseItemArray)
    }
    
    
    //MARK: - 为orderCodeLabel订单编号Label 提供复制粘贴
    
    
}

extension DetailViewCell{
    
    // 为Label 加下划线
    func addUnderLineForlabel(text: String, color: UIColor) -> NSMutableAttributedString{
       // let range = text.range(of: text)
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(value: 1), range: NSMakeRange(0, text.characters.count))
        attributeString.addAttribute(NSUnderlineColorAttributeName, value: color, range: NSMakeRange(0, text.characters.count))
        return attributeString
    }
}

extension DetailViewCell: MLEmojiLabelDelegate {
    
    func mlEmojiLabel(_ emojiLabel: MLEmojiLabel!, didSelectLink link: String!, with type: MLEmojiLabelLinkType) {
        
        switch type {
        case MLEmojiLabelLinkType():
            print(link)
            
            if link.contains("http://") || link.contains("https://") {
                UIApplication.shared.openURL(URL(string: link)!)
            } else {
                let strUrl =  "http://" + link
                UIApplication.shared.openURL(URL(string: strUrl)!)
                
            }
            
        case MLEmojiLabelLinkType.phoneNumber:
            UIApplication.shared.openURL(URL(string: "tel://" + link)!)
        case MLEmojiLabelLinkType.email:
            UIApplication.shared.openURL(URL(string: "mailto://" + link)!)
            
        default:
            break
        }
        
    }
}

