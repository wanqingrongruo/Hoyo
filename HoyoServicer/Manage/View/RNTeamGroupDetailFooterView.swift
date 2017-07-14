//
//  RNTeamGroupDetailFooterView.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/24.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNTeamGroupDetailFooterViewDelegate {
    func showProtocolDetail()
    func joinUs()
}

class RNTeamGroupDetailFooterView: UIView {
    
    var delegate: RNTeamGroupDetailFooterViewDelegate?

    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var protocolButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBAction func clickAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            // 图标
            agreeButton.isSelected = !agreeButton.isSelected
            if agreeButton.isSelected {
                agreeButton.setImage(UIImage(named:"ageree_selected"), for: .normal)
            }else{
                agreeButton.setImage(UIImage(named:"agree_unselected"), for: .normal)
            }
            break
        case 200:
            // 协议详情
//            let tmpUrl = (NetworkManager.defaultManager?.URL.object(forKey: "Agreements"))! as! String
//            
//            let urlContrller = WeiXinURLViewController(Url: tmpUrl, Title: "浩优服务家协议")
//            self.present(urlContrller, animated: true, completion: nil)
            break
        case 300:
            // 申请加入
            if agreeButton.isSelected {
                delegate?.joinUs()
            }else{
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "请阅读并同意相关协议")
            }
            break
        default:
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        joinButton.layer.cornerRadius = 20
    }

}
