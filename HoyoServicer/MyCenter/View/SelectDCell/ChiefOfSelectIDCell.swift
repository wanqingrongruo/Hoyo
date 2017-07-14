//
//  ChiefOfSelectIDCell.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/10.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class ChiefOfSelectIDCell: UITableViewCell {

    var delegate:SelectIDTableViewControllerDelegate?
    
    @IBOutlet weak var webSiteNameTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var detailAdressTextField: UITextField!
    @IBOutlet weak var commitbutton: UIButton!
    @IBOutlet weak var regularView: UIView!
    
    @IBAction func selectWhitchButton(_ sender: UIButton) {
        delegate?.selectButtonChange(sender.tag)
    }
    @IBAction func selectAdress(_ sender: AnyObject) {
        
        delegate?.ToSelectAdressController()
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         
        // Configure the view for the selected state
    }
    
}
