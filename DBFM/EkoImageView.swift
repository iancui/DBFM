//
//  EkoImageView.swift
//  DBFM
//
//  Created by Ian on 15/11/8.
//  Copyright © 2015年 AppCode. All rights reserved.
//

import UIKit

class EkoImageView: UIImageView {
    required init(coder acoder:NSCoder){
        super.init(coder: acoder)!
        // 设置圆角
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.height/2
        // 边框
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).CGColor
        
    }
    
    func onRolation(){
        // 动画关键字
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.fromValue = 0.0

        animation.toValue = M_PI * 2.0
        
        animation.duration = 20
        
        animation.repeatCount = 10000
        
        self.layer.addAnimation(animation, forKey: nil)
        
        
    }
    
    
}
