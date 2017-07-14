//
//  RNScanResultTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/19.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol RNScanResultTableViewCellDelegate {
    
    func selection(_ tag: Int)
}


class RNScanResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel! // 型号
    @IBOutlet weak var numberLabel: UILabel! // 编号
    
    @IBOutlet weak var linkerTextField: UITextField! // 联系人
    @IBOutlet weak var phoneTextField: UITextField! // 电话
    
    @IBOutlet weak var provinceTextField: UITextField! // 省
    @IBOutlet weak var cityTextField: UITextField! // 地区
    @IBOutlet weak var specificAddressTextView: UITextView! // 具体地址
    
    @IBOutlet weak var machineBrandTextField: UITextField! // 净水器品牌
    @IBOutlet weak var machineSizeTextField: UITextField! // 净水器型号
    @IBOutlet weak var machineTypeTextField: UITextField! // 净水器类型
    
    @IBOutlet weak var totalVolumeTextField: UITextField! // 总水量
    @IBOutlet weak var updateFilterTimeTextField: UITextField! // 上次更换滤芯时间
    
    // 加边框线
    @IBOutlet weak var provinceView: UIView!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var provinceButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var brandView: UIView!
    @IBOutlet weak var brandButton: UIButton!
    @IBOutlet weak var changeFilteeView: UIView!
    @IBOutlet weak var changeFilterButton: UIButton!
    @IBOutlet weak var specificAddressView: UITextView!
    
    // 加手势
    @IBOutlet weak var linkerImageView: UIImageView!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var machineSizeImageView: UIImageView!
    @IBOutlet weak var machineTypeImageView: UIImageView!
    @IBOutlet weak var totalVolumeImageView: UIImageView!
    
    
    var delegate: RNScanResultTableViewCellDelegate?
    
    var provinceAndCityJson: JSON?
    var provinceArray =  [String]()
    var cityArray =  [String]()
    var cityDic = [Int:[JSON]]() // 字典 -> 索引:数据
    
    var brandTap: UITapGestureRecognizer? // 加在品牌上的手势
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        drawBorderForView(provinceView)
        drawBorderForView(cityView)
        drawBorderForView(brandView)
        drawBorderForView(changeFilteeView)
        
        drawBorderForButton(provinceButton)
        drawBorderForButton(cityButton)
        drawBorderForButton(brandButton)
        drawBorderForButton(changeFilterButton)
        
        drawBorderForView(specificAddressView)
        //        specificAddressView.layer.masksToBounds = true
        //        specificAddressView.layer.cornerRadius = 5
        //        specificAddressView.layer.borderWidth = 1.0
        //        specificAddressView.layer.borderColor = UIColor.blackColor().CGColor
        
        specificAddressTextView.delegate = self
        specificAddressTextView.textColor = COLORRGBA(200, g: 200, b: 200, a: 1)
        
        // 选择器,不可编辑
        provinceTextField.isEnabled = false
        cityTextField.isEnabled = false
        machineBrandTextField.isEnabled = false
        updateFilterTimeTextField.isEnabled = false
        
        
        totalVolumeTextField.delegate = self
        machineBrandTextField.delegate = self
        
        // 手势事件
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(selectData(_:)))
        provinceView.isUserInteractionEnabled = true
        provinceView.addGestureRecognizer(tap01)
        
        let tap02 = UITapGestureRecognizer(target: self, action: #selector(selectData(_:)))
        cityView.addGestureRecognizer(tap02)
        
        let tap03 = UITapGestureRecognizer(target: self, action: #selector(selectData(_:)))
        brandView.addGestureRecognizer(tap03)
        
        brandTap = tap03
        
        let tap04 = UITapGestureRecognizer(target: self, action: #selector(selectData(_:)))
        changeFilteeView.addGestureRecognizer(tap04)
        
        // 给 imageView加手势
        let mTap01 = UITapGestureRecognizer(target: self, action: #selector(getResponser(_:)))
        linkerImageView.addGestureRecognizer(mTap01)
        let mTap02 = UITapGestureRecognizer(target: self, action: #selector(getResponser(_:)))
        phoneImageView.addGestureRecognizer(mTap02)
        let mTap03 = UITapGestureRecognizer(target: self, action: #selector(getResponser(_:)))
        addressImageView.addGestureRecognizer(mTap03)
        let mTap04 = UITapGestureRecognizer(target: self, action: #selector(getResponser(_:)))
        machineSizeImageView.addGestureRecognizer(mTap04)
        let mTap05 = UITapGestureRecognizer(target: self, action: #selector(getResponser(_:)))
        machineTypeImageView.addGestureRecognizer(mTap05)
        let mTap06 = UITapGestureRecognizer(target: self, action: #selector(getResponser(_:)))
        totalVolumeImageView.addGestureRecognizer(mTap06)
        
        // 省市数据
        let path =  Bundle.main.path(forResource: "china_citys", ofType: "json")
        let data =  try? Data(contentsOf: URL(fileURLWithPath: path!))
        provinceAndCityJson =  JSON(data: data!)
        for (index, value) in provinceAndCityJson!.array!.enumerated(){
            provinceArray.append(value["name"].stringValue)
            cityDic[index] = value["cities"].array
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancelKeyBoard), name: NSNotification.Name(rawValue: "CancelFirstResponse"), object: nil)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func drawBorderForView(_ showView: UIView){
        
        showView.layer.masksToBounds = true
        showView.layer.cornerRadius = 5
        showView.layer.borderWidth = 0.6
        showView.layer.borderColor = COLORRGBA(200, g: 200, b: 200, a: 1).cgColor
    }
    
    func drawBorderForButton(_ button: UIButton){
        
        // button.layer.masksToBounds = true
        // button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.6
        button.layer.borderColor = COLORRGBA(200, g: 200, b: 200, a: 1).cgColor
        button.imageView?.sizeToFit()
    }
    
    func cancelKeyBoard(){
        
        self.endEditing(true)
    }
    
}


extension RNScanResultTableViewCell{
    
    @IBAction func clickAction(_ sender: UIButton) {
        
        // 0 选择省市
        // 1 选择地区
        // 2 选择净水器品牌
        // 3 选择更新滤芯时间
        switch sender.tag {
        case 0:
            
            selectProvince()
        case 1:
            selectCity()
            
        case 2:
            
            machineBrandTextField.resignFirstResponder()
            selectOzner()
        case 3:
            
            selectUpdateTime()
        default:
            break
        }
        
        
        
        self.delegate?.selection(sender.tag)
        
    }
    
    // 手势事件
    func selectData(_ tap: UITapGestureRecognizer){
        
        let view = tap.view
        // 100 选择省市
        // 101 选择地区
        // 102 选择净水器品牌
        // 103 选择更新滤芯时间
        
        self.endEditing(true)
        
        switch view!.tag {
        case 200:
            selectProvince()
        case 201:
            selectCity()
        case 202:
            selectOzner()
        case 203:
            selectUpdateTime()
        default:
            break
        }
        
    }
    
    // imageView 上的手势
    func getResponser(_ gesture: UITapGestureRecognizer){
        
        let imageView = gesture.view as! UIImageView
        switch imageView.tag {
        case 800:
            linkerTextField.becomeFirstResponder()
        case 801:
            phoneTextField.becomeFirstResponder()
        case 802:
            specificAddressTextView.becomeFirstResponder()
        case 803:
            machineSizeTextField.becomeFirstResponder()
        case 804:
            machineTypeTextField.becomeFirstResponder()
        case 805:
            totalVolumeTextField.becomeFirstResponder()
        default:
            break
        }
        
    }
    
}


// MARK: - custom methods

extension RNScanResultTableViewCell{
    
    // 省市
    func selectProvince(){
        
        UsefulPickerView.showSingleColPicker("选择省市", data: provinceArray, defaultSelectedIndex: 0, doneAction: { (selectedIndex, selectedValue) in
            
            self.provinceTextField.text = selectedValue
            
            let tempArr = self.cityDic[selectedIndex]
            self.cityArray.removeAll()
            for item in tempArr!{
                
                self.cityArray.append(item.stringValue)
            }
            
            if self.cityArray.count > 0{
                
                self.cityTextField.text = self.cityArray[0] // 默认选择第一个
            }
            
        })
        
    }
    
    // 地区
    func selectCity(){
        
        if self.cityTextField.text == "" {
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "请先选择省市")
        }else{
            
            UsefulPickerView.showSingleColPicker("选择地区", data:  cityArray, defaultSelectedIndex: 0, doneAction: { (selectedIndex, selectedValue) in
                
                self.cityTextField.text = selectedValue
            })
        }
        
    }
    
    // 净水器品牌
    func selectOzner(){
        //浩泽，美的，安吉尔，沁园，海尔，飞利浦，霍尼韦尔，A.O史密斯，小米，3M，自定义
        let brandArray = ["浩泽","美的","安吉尔","沁园","海尔","飞利浦","霍尼韦尔","A.O史密斯","小米","3M","自定义"]
        UsefulPickerView.showSingleColPicker("选择品牌", data:  brandArray, defaultSelectedIndex: 0, doneAction: { (selectedIndex, selectedValue) in
            
            if selectedIndex == brandArray.count - 1 {
                
                self.brandView.removeGestureRecognizer(self.brandTap!)
                self.machineBrandTextField.isEnabled = true
                self.machineBrandTextField.becomeFirstResponder()
            }else{
                self.machineBrandTextField.text = selectedValue
            }
            
        })
    }
    
    // 滤芯更新时间
    func selectUpdateTime(){
        
        DatePickerDialog().show("上次更换滤芯日期", doneButtonTitle: "确认", cancelButtonTitle: "取消", datePickerMode: .date,formate : "yyyy-MM-dd HH:mm:ss") {
            (date) -> Void in
            self.updateFilterTimeTextField.text="\(date)"
        }

    }
}


extension RNScanResultTableViewCell: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "请填入完整的地址" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "请填入完整的地址"
            specificAddressTextView.textColor = COLORRGBA(200, g: 200, b: 200, a: 1)
        }
    }
}

extension RNScanResultTableViewCell: UITextFieldDelegate{
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == totalVolumeTextField{
           return textField.digitFormatCheck(textField.text!, range: range, replacementString: string)
            
        }else{
            return true
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == machineBrandTextField {
            
            self.machineBrandTextField.isEnabled = false
            self.brandView.addGestureRecognizer(self.brandTap!)
        }
    }
    
}


