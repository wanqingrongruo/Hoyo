//
//  RNSubmitCell01.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/8/3.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

// 充水-水质控制-送货


class RNSubmitCell01: SubmitCell{
    
    // MARK: - properties
    
    // headView
    @IBOutlet weak var headImageView: UIImageView! // 头像
    @IBOutlet weak var orderTypeLabel: UILabel! // 订单类型 - 主要有九种（分三种不同的界面显示）
    @IBOutlet weak var deviceNameLabel: UILabel! // 设备名称
    
    // midiumView
    @IBOutlet weak var midiumView: UIView! // midiumView
    @IBOutlet weak var selectDayButton: UIButton! // 选择日期 tag=0
    @IBOutlet weak var selectTimeButton: UIButton! // 选择具体时间 tag=1
    @IBOutlet weak var selectWorkTimeButton: UIButton! // 选择工作用时 tag=2
    @IBOutlet weak var ServiceFeeTextField: UITextField! // 服务费用 tag=100
    @IBOutlet weak var machineIdTextField: UITextField! // 机器 id tag=101
    @IBOutlet weak var scanMachineIdButton: UIButton! // 扫描机器 ID tag=3
    @IBOutlet weak var IMEITextField: UITextField! // IMEI tag=102
    @IBOutlet weak var IMEIButton: UIButton! // IMIE tag=4
    
    @IBOutlet weak var serviceFeeViewHeightConstraint: NSLayoutConstraint! // 服务费用view 的高度约束 -- 根据是否选择微信支付进行显示隐藏操作
    
    @IBOutlet weak var midWithBotSpaceConstraint: NSLayoutConstraint! // bottomView与 midiumView的间距
    // bottomView
    @IBOutlet weak var bottomView: UIView! // bottomView
    @IBOutlet weak var throughTrainTextField: UITextField! // 直通车 tag=103
    @IBOutlet weak var throughTrainButton: UIButton! // 直通车 tag=8
    @IBOutlet weak var machineVersionTextField: UITextField! // 机器版本 tag=104
   
    // scrollView
    @IBOutlet weak var constrainerView: UIView!
    @IBOutlet weak var img01: RNUploadImageView! //tag = 200
    @IBOutlet weak var img02: RNUploadImageView! //tag = 201
    @IBOutlet weak var img03: RNUploadImageView! //tag = 202
    @IBOutlet weak var img04: RNUploadImageView! //tag = 203
  
    
    
    // 配件清单
    @IBOutlet weak var selectAccButton: UIButton! // 选择配件 tag=116
    
   
    // 自定义属性
    var orderDetails: OrderDetail? // 订单详情
    
//    var delegate: SubmitCellDelegate? // 代理
    
    var faultReasons: [String]? = nil // 故障原因
    var dealMethods: [[String]]? = nil // 解决办法
    
  //  var selectedIndex = 5 //  现金已支付-微信支付-无需支付按钮 索引,默认选中现金已支付
    
    var myImage: UIImage = UIImage(named: "addmore")! // 用于展示图片
    // var myImageView = UIImageView()

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img01.addGestureRecognizer(tap01)
        let tap02 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img02.addGestureRecognizer(tap02)
        let tap03 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img03.addGestureRecognizer(tap03)
        let tap04 = UITapGestureRecognizer(target: self, action: #selector(addPicAction(press:)))
        img04.addGestureRecognizer(tap04)
        
        for i in 101...104 {
            let tf =  self.viewWithTag(i) as! UITextField
            tf.delegate = self
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // cell 显示
    func configCell(_ faultReasons: [String], dealMethods: [[String]], orderDetail: OrderDetail){
        
        self.faultReasons = faultReasons
        self.dealMethods = dealMethods
        
        self.orderDetails = orderDetail
        guard (self.orderDetails != nil) else{
            return
        }
        
        
        if orderDetails!.userImage != nil { // 头像
            self.headImageView.sd_setImage(with: URL(string: orderDetails!.userImage!), placeholderImage: UIImage(named: "order_repair.png"))
        }
        
        if orderDetails!.troubleHandleType != nil { // 订单类型
            self.orderTypeLabel.text = orderDetails!.troubleHandleType!
        }
        
        if orderDetails!.productName != nil {
           // self.deviceNameLabel.text = orderDetails!.productNameAndModel!
        }
       
    }
    
    
}

// MARK: - event response

extension RNSubmitCell01{
    
    // 选择日期
    @IBAction func selectDayAction(_ sender: UIButton) {
        
        DatePickerDialog().show("选择日期", doneButtonTitle: "确认",cancelButtonTitle: "取消",datePickerMode: .date,formate : "yyyy-MM-dd ") {
            (date) -> Void in
            self.selectDayButton.setTitle("\(date)", for: UIControlState())
        }
    }
    
    // 选择具体时间
    @IBAction func selectTimeAction(_ sender: UIButton) {
        
        DatePickerDialog().show("选择时间", doneButtonTitle: "确认", cancelButtonTitle: "取消", datePickerMode: .time,formate : "HH:mm:ss") {
            (date) -> Void in
            self.selectTimeButton.setTitle("\(date)", for: UIControlState())
        }

    }
    
    // 选择工作用时
    @IBAction func selectWorkTimeAction(_ sender: UIButton) {
        
        guard self.selectWorkTimeButton.currentTitle != nil else{
            return
        }
//        guard self.selectWorkTimeButton.titleLabel!.text != nil else{
//            return
//        }
    
        let title = self.selectWorkTimeButton.currentTitle!
        delegate?.poptoSuperCon(title) // 选择用时
    }
    
    // 调用相加扫描
    @IBAction func scanAction(_ sender: UIButton) {
        
        // 3-机器 id
        // 4-IMEI
        // 8-直通车编码
        switch sender.tag {
        case 3:
            delegate?.popAboutScanToSuperCon("3")
            break
        case 4:
            
            delegate?.popAboutScanToSuperCon("4")
            break
        case 8:
            
            delegate?.popAboutScanToSuperCon("8")
            break
        default:
            break
        }
    }
    
    
    // 添加正常运行照片
    func addPicAction(press: UITapGestureRecognizer) {
        
        let imgView = press.view as! RNUploadImageView
        
        if imgView.isUploaded {
            // [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:tap.view.tag imageCount:self.images.count datasource:self];
            
            if let image = imgView.image {
                myImage = image
                //  myImageView = imgView
                XLPhotoBrowser.show(withCurrentImageIndex: imgView.tag, imageCount: 1, datasource: self)
                
            }else{
                let alert = SCLAlertView()
                alert.addButton("确定", action: {})
                alert.showError("提示", subTitle: "抱歉,未获取到图片")
            }
            
        }else{
            delegate?.uploadPhoto(press)
        }
    }
    
    // 选择配件
    @IBAction func selectACCAction(_ sender: UIButton) {
        
        delegate?.popToSelectProductMaterial()
    }
    
}

extension RNSubmitCell01: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 102 || textField.tag == 104  {
            textField.resignFirstResponder()
            return true
        }else{
            let tf = self.viewWithTag(textField.tag+1) as! UITextField
            tf.becomeFirstResponder()
            return true
        }
    }
}

extension RNSubmitCell01: XLPhotoBrowserDatasource{
    func photoBrowser(_ browser: XLPhotoBrowser!, placeholderImageFor index: Int) -> UIImage! {
        return myImage
    }
    
    //func photoBrowser(_ browser: XLPhotoBrowser!, sourceImageViewFor index: Int) -> UIImageView! {
    //     return myImageView
    //  }
    
}
