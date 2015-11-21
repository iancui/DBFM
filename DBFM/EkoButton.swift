//
//  EkoButton.swift
//  DBFM
//
//  Created by Ian on 15/11/10.
//  Copyright © 2015年 AppCode. All rights reserved.
//

import UIKit

class EkoButton :UIButton {
    var isPlay:Bool = true
    let imgPlay:UIImage = UIImage(named: "play")!
    let imgPause:UIImage = UIImage(named: "pause")!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClick", forControlEvents: .TouchUpInside)
    }
    
    func onClick(){
        
        isPlay = !isPlay
        if isPlay {
            self.setImage(imgPause, forState: .Normal)
        } else {
            self.setImage(imgPlay, forState: .Normal)
        }
    }
    
    func onPlay() {
        isPlay = true
        self.setImage(imgPause, forState: .Normal)
    }
    
    
}
