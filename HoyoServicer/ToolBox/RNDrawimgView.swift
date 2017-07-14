//
//  RNDrawimgView.swift
//  RNDrawBoardView
//
//  Created by 婉卿容若 on 2017/2/20.
//  Copyright © 2017年 婉卿容若. All rights reserved.
//

import UIKit

class RNDrawimgView: UIView {

    var path: UIBezierPath
    var isDrawed: Bool = false
    
    // 重写layerClass属性
    override class var layerClass: AnyClass{
        return CAShapeLayer.self
    }
    
    // init
    
    override init(frame: CGRect) {
        
        
        self.path = UIBezierPath()
        
        super.init(frame: frame)

        let shapLayer = self.layer as? CAShapeLayer
        shapLayer?.strokeColor = UIColor.black.cgColor
        shapLayer?.fillColor = UIColor.clear.cgColor
        shapLayer?.lineJoin = kCALineJoinRound
        shapLayer?.lineCap = kCALineCapRound
        shapLayer?.lineWidth = 3
       
    }
    
    override func awakeFromNib() {
        
        self.path = UIBezierPath()
        
        super.awakeFromNib()
        
        let shapLayer = self.layer as? CAShapeLayer
        shapLayer?.strokeColor = UIColor.black.cgColor
        shapLayer?.fillColor = UIColor.clear.cgColor
        shapLayer?.lineJoin = kCALineJoinRound
        shapLayer?.lineCap = kCALineCapRound
        shapLayer?.lineWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let point = ((touches as NSSet).anyObject() as AnyObject).location(in: self)
        self.path.move(to: point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let point = ((touches as NSSet).anyObject() as AnyObject).location(in: self)
        
        
        if self.point(inside: point, with: nil) {
            self.path.addLine(to: point)
            (self.layer as? CAShapeLayer)?.path = self.path.cgPath
            
            isDrawed = true // 标记
        }
        
       
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let point = ((touches as NSSet).anyObject() as AnyObject).location(in: self)
//        self.
//    }
    
//    override func draw(_ rect: CGRect) {
//        
//        //
//    }
    

}
