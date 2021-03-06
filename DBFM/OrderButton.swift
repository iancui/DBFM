//
//  OrderButton.swift
//  DBFM
//
//  Created by Ian on 15/11/11.
//  Copyright © 2015年 AppCode. All rights reserved.
//

import UIKit

class OrderButton: UIButton {
    var order:Int = 1
    
    let order1:UIImage = UIImage(named: "order1")!
    let order2:UIImage = UIImage(named: "order2")!
    let order3:UIImage = UIImage(named: "order3")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: "onClick:", forControlEvents: .TouchUpInside)
    }
    
    func onClick(btn:UIButton){
        order++
        if order == 1{
            self.setImage(order1, forState: .Normal)
        }else if order == 2{
            self.setImage(order2, forState: .Normal)
        }else if order == 3{
            self.setImage(order3, forState: .Normal)
        }else if order > 3 {
            self.setImage(order1, forState: .Normal)
            order = 1
        }
        
    }
    
}
