//
//  BoundCarViewCell.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 2/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class BoundCarViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var bankTypelabel: UILabel!
    @IBOutlet weak var bankNumberLabel: UILabel!
    
//    var model:BankModel? = nil{
//        
//        willSet{
//            
//            bankNameLabel.text = model?.bankName
//            bankTypelabel.text = model?.bankType
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        backView.layoutIfNeeded()
        
        bankNumberLabel.adjustsFontSizeToFitWidth = true
        
        let maskPath = UIBezierPath(roundedRect: backView.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight] , cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = backView.bounds
        maskLayer.path = maskPath.cgPath
        backView.layer.mask = maskLayer
        
    }
    
    func configureForCell(_ model:BankModel) -> Void {
        
        bankNameLabel.text = model.bankName!
        bankTypelabel.text = model.bankBranch!
        
        guard let _ = model.cardId else{
            
            return
        }
        
        var cardNum: String = "**** **** **** "
        
        
        guard model.cardId!.characters.count >= 4 else{
            
            bankNumberLabel.text = cardNum + model.cardId!
            return
        }
        
        cardNum += (model.cardId! as NSString).substring(from: model.cardId!.characters.count - 4)
        
        bankNumberLabel.text = cardNum
        
    }
    
}



