//
//  RNScanResultTableViewCell04-02.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/21.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNScanResultTableViewCell04_02Delegate {
    
    func selectionServiceRecord(_ index: IndexPath)
    
    func delectRowServiceRecord(_ index: IndexPath) // 删除添加的记录
    
    func updateServiceRecord(_ model: RNUserRecordModel) // 更新记录
}

class RNScanResultTableViewCell04_02: UITableViewCell {

    @IBOutlet weak var sortLabel: UILabel! // 序号
    @IBOutlet weak var dataTextField: UITextField! // 日期
    @IBOutlet weak var fixContentTextField: UITextField! // 服务维修内容
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var editImageView: UIImageView!
    
    var delegate: RNScanResultTableViewCell04_02Delegate?
    
     var indexPath:IndexPath?
    
     var myModel: RNUserRecordModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
         editImageView.isHidden = true
        
        drawBorderForView(dateView)
        
        drawBorderForButton(dateButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteRecord))
        editImageView.isUserInteractionEnabled = true
        editImageView.addGestureRecognizer(tap)
        
        // 手势事件
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(selectData(_:)))
        dateView.isUserInteractionEnabled = true
        dateView.addGestureRecognizer(tap01)
        
        dataTextField.isEnabled = false
        fixContentTextField.delegate = self
        
        myModel?.index = 1
        myModel?.isRealData = false
        myModel?.name = ""
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
        
        if !model.isRealData! {
            editImageView.isHidden = false
        }else{
             editImageView.isHidden = true
        }
        
        if  model.isRealData! {
            fixContentTextField.isEnabled = false
            dataTextField.isEnabled = false
            
            dateButton.isEnabled = false
        }
        
        sortLabel.text = "\(indexPath!.row)."
        dataTextField.text = model.year
        fixContentTextField.text = model.name
        
    }

    
    // 选择日期
    @IBAction func selectDate(_ sender: UIButton) {
        
        if myModel!.isRealData! {
            //
        }else{
            selectDate()
        }
        
       // self.delegate?.selectionServiceRecord(indexPath!)
    }
    
    func deleteRecord(){
        
        self.delegate?.delectRowServiceRecord(indexPath!)
    }
    
    func selectData(_ tap: UITapGestureRecognizer){
        if myModel!.isRealData! {
            //
        }else{
            selectDate()
        }
    }
    
    func selectDate(){
        DatePickerDialog().show("选择维修日期", doneButtonTitle: "确认", cancelButtonTitle: "取消", datePickerMode: .date,formate : "YYYY-MM-dd") {
            (date) -> Void in
            self.dataTextField.text="\(date)"
            
            self.myModel?.year = self.dataTextField.text
            self.delegate?.updateServiceRecord(self.myModel!)
        }
    }
    
   

}

extension RNScanResultTableViewCell04_02: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        myModel?.name = textField.text
        
        self.delegate?.updateServiceRecord(myModel!)
    }

}
