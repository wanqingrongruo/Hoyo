//
//  AchievementCell.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 8/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class AchievementCell: UITableViewCell {

    @IBOutlet weak var rankingLabel: UILabel! //排名
    @IBOutlet weak var headImageView: UIImageView! //头像
    @IBOutlet weak var nameLabel: UILabel! //名字
    @IBOutlet weak var star01: UIImageView! //等级
    @IBOutlet weak var star02: UIImageView!
    @IBOutlet weak var star03: UIImageView!
    @IBOutlet weak var star04: UIImageView!
    @IBOutlet weak var star05: UIImageView!
    @IBOutlet weak var scoresLabel: UILabel! //分数
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        headImageView.clipsToBounds = true
        headImageView.layer.cornerRadius = 30
       // headImageView.clipCornerRadiusForView(headImageView, RoundingCorners: [UIRectCorner.TopLeft,UIRectCorner.TopRight,UIRectCorner.BottomLeft,UIRectCorner.BottomRight], Radii: CGSizeMake(25, 25))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //显示cell
    func configCell(_ model: RankDetailModel) {
        
        if let _ = model.username {
            nameLabel.text = model.username!
        }
        if let _ = model.rank {
            if let rank = Int(model.rank!) {
                if rank > 3{
                    rankingLabel.textColor = UIColor.black
                }else{
                    rankingLabel.textColor = UIColor.red
                }
                
                rankingLabel.text = model.rank!
            }
           
        }
        if let _ = model.headImageUrl {
            
            if !model.headImageUrl!.hasPrefix("http") {
                model.headImageUrl = SERVICEADDRESS + model.headImageUrl!
            }
           
           // print(model.headImageUrl)
            let url = URL(string: model.headImageUrl!)
            headImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "manage_update"))
        }
        if let _ = model.score {
            scoresLabel.text = model.score!
        }
        if model.grade != nil && model.comments != nil {
            
            if Double(model.grade!) != nil && Double(model.comments!) != nil {
                let star = Double(model.grade!)! / Double(model.comments!)!
                
                //starsedOfHome-starsOfHome
                if star > 4.0 {
                    star01.image = UIImage(named: "starsedOfHome")
                    star02.image = UIImage(named: "starsedOfHome")
                    star03.image = UIImage(named: "starsedOfHome")
                    star04.image = UIImage(named: "starsedOfHome")
                    star05.image = UIImage(named: "starsedOfHome")
                }else if star > 3.0{
                    star01.image = UIImage(named: "starsedOfHome")
                    star02.image = UIImage(named: "starsedOfHome")
                    star03.image = UIImage(named: "starsedOfHome")
                    star04.image = UIImage(named: "starsedOfHome")
                }else if star > 2.0{
                    star01.image = UIImage(named: "starsedOfHome")
                    star02.image = UIImage(named: "starsedOfHome")
                    star03.image = UIImage(named: "starsedOfHome")
                }else if star > 1.0{
                    star01.image = UIImage(named: "starsedOfHome")
                    star02.image = UIImage(named: "starsedOfHome")
                    
                }else if star > 0.0{
                    star01.image = UIImage(named: "starsedOfHome")
                }
                
                
                
            }
            
            
        }
       
        
//        if model.rank > 2 {
//            rankingLabel.textColor = UIColor.blackColor()
//        }else{
//            rankingLabel.textColor = UIColor.redColor()
//        }
    }
    
}
