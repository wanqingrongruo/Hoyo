//
//  RNScanResultTableViewCell02-02.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/21.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNScanResultTableViewCell02_02Delegate {
    
    func selectionFilterSetting(_ index: IndexPath) //  选择时间
    
    func delectRow(_ index: IndexPath) // 删除添加的记录
    
    func updateFilterSettingModel(_ model: filterModel) // 更新滤芯设定的 model 数组
}

class RNScanResultTableViewCell02_02: UITableViewCell{

    @IBOutlet weak var titleLabel: UILabel! // 第 x 级
    @IBOutlet weak var filterNameTextField: UITextField! // 滤芯名称
    @IBOutlet weak var filterYearTextField: UITextField! // 滤芯寿命
    @IBOutlet weak var filterYearView: UIView!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var editImageView: UIImageView!
    
    var delegate: RNScanResultTableViewCell02_02Delegate?
    
    var indexPath:IndexPath?
    
    var model = filterModel()

    var filterYearTap: UITapGestureRecognizer? // 滤芯寿命手势
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editImageView.isHidden = false
        
        drawBorderForView(filterYearView)
        drawBorderForButton(yearButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteRecord))
        editImageView.isUserInteractionEnabled = true
        editImageView.addGestureRecognizer(tap)
        
        filterYearTextField.isEnabled = false
        filterYearTextField.delegate = self
        filterNameTextField.delegate = self
        
        // 手势事件
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(selectData(_:)))
        filterYearView.isUserInteractionEnabled = true
        filterYearView.addGestureRecognizer(tap01)
        
         filterYearTap = tap01
        
        model.index = 1
        model.filterName = ""
        model.filterYear = "0"
        
        filterNameTextField.text = ""
        filterYearTextField.text = ""
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


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configCell(_ index: IndexPath, myModel: filterModel){
        
        self.indexPath = index
        
        self.model = myModel
        
        self.model.index = index.row 
//        if !model.isRealData! {
//            editImageView.hidden = false
//        }else{
//            editImageView.hidden = true
//        }
//
//        
//        if  model.isRealData! {
//            filterYearTextField.enabled = false
//            filterNameTextField.enabled = false
//            
//            yearButton.enabled = false
//        }
//        
        var sort: String = ""
        switch self.indexPath!.row {
        case 1:
            sort =   "一"
        case 2:
            sort =  "二"
        case 3:
            sort =  "三"
        case 4:
            sort =  "四"
        case 5:
            sort =  "五"
            
        default:
            break
        }

        
        titleLabel.text = "第\(sort)级"
        filterNameTextField.text = model.filterName
        filterYearTextField.text = model.filterYear == "0" ? "" : model.filterYear
        
    }
    
    // 选择滤芯寿命
    @IBAction func selectFilterYear(_ sender: UIButton) {
        
        self.filterNameTextField.resignFirstResponder()
        self.filterYearTextField.resignFirstResponder()
        
        selectFilterYear()
        //self.delegate?.selectionFilterSetting(indexPath!)
    }
    
    
    func deleteRecord(){
        
        self.delegate?.delectRow(indexPath!)
    }
    
    func selectData(_ tap: UITapGestureRecognizer){
        
        selectFilterYear()
    }
    
    // 选择滤芯寿命
    func selectFilterYear(){
        
        filterNameTextField.resignFirstResponder()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "CancelFirstResponse"), object: nil)// 发出取消键盘通知
       // self.endEditing(true)
        
        let yearArray = ["1个月","2个月","3个月","4个月","5个月","6个月","7个月","8个月","9个月","10个月","11个月","12个月","自定义"]
        UsefulPickerView.showSingleColPicker("选择滤芯寿命", data:  yearArray, defaultSelectedIndex: 0, doneAction: { (selectedIndex, selectedValue) in
            
            if selectedIndex == yearArray.count - 1 {
                
                self.filterYearTextField.isEnabled = true
                self.filterYearTextField.becomeFirstResponder()
                
                self.filterYearView.removeGestureRecognizer(self.filterYearTap!)

            }else{

                let index = selectedValue.characters.index(selectedValue.endIndex, offsetBy: -2)
                self.filterYearTextField.text = selectedValue.substring(to: index)
            }
            
            self.model.filterYear = self.filterYearTextField.text
            
            self.delegate?.updateFilterSettingModel(self.model)
        })

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.endEditing(true)
    }
    
    
    
}

extension RNScanResultTableViewCell02_02: UITextFieldDelegate{
    
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
//        if textField == filterNameTextField {
//            model.filterName = textField.text
//            
//            self.delegate?.updateFilterSettingModel(model)
//        }else{
//            model.filterYear = textField.text
//            
//            self.filterYearTextField.isEnabled = false
//            self.filterYearView.addGestureRecognizer(self.filterYearTap!)
//            
//            self.delegate?.updateFilterSettingModel(model)
//        }
//
//        return true
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if textField == filterNameTextField {
            model.filterName = filterNameTextField.text
            
            self.delegate?.updateFilterSettingModel(model)
        }else{
            model.filterYear = filterYearTextField.text
            
            self.filterYearTextField.isEnabled = false
            self.filterYearView.addGestureRecognizer(self.filterYearTap!)
            
            self.delegate?.updateFilterSettingModel(model)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == filterYearTextField{
            return textField.digitFormatCheck(textField.text!, range: range, replacementString: string)
            
        }else{
            return true
        }
        
    }

}
