//
//  RNScanResultTableViewCell03-02.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/21.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNScanResultTableViewCell03_02Delegate {
    
    func selectionFilterChangeRecode(_ tag: Int, index: IndexPath)
    
    func delectRowFilterChangeRecode(_ index: IndexPath) // 删除添加的记录
    
    func updateFilterChangeRecode(_ model: RNUserRecordModel) // 更新记录
}

class RNScanResultTableViewCell03_02: UITableViewCell {
    
    @IBOutlet weak var sortLabel: UILabel! // 序号
    @IBOutlet weak var dateTextField: UITextField! // 日期
    @IBOutlet weak var updateFilterTextField: UITextField! // 滤芯更换级数
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var filterYearView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var filterYearButton: UIButton!
    @IBOutlet weak var editImageView: UIImageView!
    
    var delegate: RNScanResultTableViewCell03_02Delegate?
    
    var indexPath:IndexPath?
    
    var myModel: RNUserRecordModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        editImageView.isHidden = true
        
        drawBorderForView(dateView)
        drawBorderForView(filterYearView)
        
        drawBorderForButton(dateButton)
        drawBorderForButton(filterYearButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteRecord))
        editImageView.isUserInteractionEnabled = true
        editImageView.addGestureRecognizer(tap)
        
        // 手势事件
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(selectData(_:)))
        dateView.isUserInteractionEnabled = true
        dateView.addGestureRecognizer(tap01)
        
        // 手势事件
        let tap02 = UITapGestureRecognizer(target: self, action: #selector(selectData(_:)))
        filterYearView.isUserInteractionEnabled = true
        filterYearView.addGestureRecognizer(tap02)
        
        dateTextField.isEnabled = false
        updateFilterTextField.isEnabled = false
        
        myModel?.index = 1
        myModel?.isRealData = false
        myModel?.name = "1"
        myModel?.year = ""
        myModel?.id = -1
        
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
    
    
    func configCell(_ index: IndexPath, model: RNUserRecordModel){
        
        self.indexPath = index
        self.myModel = model
        self.myModel?.index = index.row
        
        if !model.isRealData! {
            editImageView.isHidden = false
        }else{
            editImageView.isHidden = true
        }
        
        
        if  model.isRealData! {
            dateTextField.isEnabled = false
            updateFilterTextField.isEnabled = false
            
            dateButton.isEnabled = false
            filterYearButton.isEnabled = false
        }
        
        
        sortLabel.text = "\(indexPath!.row)."
        dateTextField.text = model.year
        updateFilterTextField.text = model.name
        
    }
    
    
    @IBAction func selectAction(_ sender: UIButton) {
        
        // 0 选择日期
        // 1 选择滤芯更换级数
        switch sender.tag {
        case 0:
            selectDate()
        case 1:
            selectChangeFilter()
        default:
            break
        }
        
        self.delegate?.selectionFilterChangeRecode(sender.tag, index: indexPath!)
    }
    
    func deleteRecord(){
        
        self.delegate?.delectRowFilterChangeRecode(indexPath!)
    }
    
    // 手势事件
    func selectData(_ tap: UITapGestureRecognizer){
        
        let view = tap.view
        // 300 选择日期
        // 301 选择更换级数
        
        switch view!.tag {
        case 300:
            
            if myModel!.isRealData! {
                //
            }else{
                selectDate()
            }
            
        case 301:
            
            
            if myModel!.isRealData! {
                //
            }else{
                selectChangeFilter()
            }
            
        default:
            break
        }
        
    }
    
    func selectDate(){
        
        DatePickerDialog().show("选择更换滤芯日期", doneButtonTitle: "确认", cancelButtonTitle: "取消", datePickerMode: .date,formate : "YYYY-MM-dd") {
            (date) -> Void in
            self.dateTextField.text="\(date)"
            
            self.myModel?.year = self.dateTextField.text
            self.delegate?.updateFilterChangeRecode(self.myModel!)
        }
        
    }
    
    func selectChangeFilter(){
      
        NotificationCenter.default.post(name: Notification.Name(rawValue: "CancelFirstResponse"), object: nil)// 发出取消键盘通知
        
        let brandArray = ["1级","2级","3级","4级","5级",]
        UsefulPickerView.showSingleColPicker("选择滤芯更换级数", data:  brandArray, defaultSelectedIndex: 0, doneAction: { (selectedIndex, selectedValue) in
            
            let index = selectedValue.characters.index(selectedValue.endIndex, offsetBy: -1)
            self.updateFilterTextField.text = selectedValue.substring(to: index)
            
            self.myModel?.name = self.updateFilterTextField.text
            self.delegate?.updateFilterChangeRecode(self.myModel!)
        })
        
    }
    
}
