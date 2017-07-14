//
//  GeneralOfSelectIDCell.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/10.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class GeneralOfSelectIDCell: UITableViewCell {
    
    //21,22,23第一，二，三个按钮
    let normalColor=UIColor.white
    let selectColor=UIColor(red: 249/255.0, green: 113/255.0, blue: 52/255.0, alpha: 1)
    let normalFontColor=UIColor.black
    var delegate:SelectIDTableViewControllerDelegate?
    var selectIndex = 22{
        didSet{
            if selectIndex==oldValue {
                return
            }
            if selectIndex==21 {
                //callback
                delegate?.selectButtonChange(selectIndex)
            }else{
                normalButton.backgroundColor=selectIndex==22 ? selectColor:normalColor
                contactButton.backgroundColor=selectIndex==23 ? selectColor:normalColor
                normalButton.setTitleColor(selectIndex==22 ? normalColor:normalFontColor, for: UIControlState())
                contactButton.setTitleColor(selectIndex==23 ? normalColor:normalFontColor, for: UIControlState())
            }
        }
    }
    
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var inputNumberTextField: UITextField!
    
    @IBOutlet weak var regularView: UIView!
    
    
    @IBAction func selectWhitchButton(_ sender: UIButton) {
        selectIndex=sender.tag
    }
    @IBOutlet weak var commitbutton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
