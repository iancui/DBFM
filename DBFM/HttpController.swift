//
//  HttpController.swift
//  DBFM
//
//  Created by Ian on 15/11/9.
//  Copyright © 2015年 AppCode. All rights reserved.
//

import UIKit
import Alamofire

protocol HttpProtocol {
    func didRecieveResults(results:AnyObject)
    
}

class HttpController:NSObject {
    var delegate:HttpProtocol?
    func onSearch(url:String){
//        Alamofire.request(.GET, url).responseJSON { (req) -> Void in
//            code
//        }
        Alamofire.request(.GET, url).responseJSON(options: .MutableContainers) { (request) -> Void in
            if request.result.error == nil {
                self.delegate?.didRecieveResults(request.result.value!)
            }
        }
    }
    func onSearch(url:String,parameters:[String: AnyObject]){
        Alamofire.request(.GET, url,parameters: parameters).responseJSON(options: .MutableContainers) { (request) -> Void in
            if request.result.error == nil {
                self.delegate?.didRecieveResults(request.result.value!)
            }
        }
    }
    
    
}
