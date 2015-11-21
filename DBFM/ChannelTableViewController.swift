//
//  ChannelTableViewController.swift
//  DBFM
//
//  Created by Ian on 15/11/8.
//  Copyright © 2015年 AppCode. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ChannelProtocol {
    // 回掉方法，讲频道id传回代理中
    func onChangeChannel(channel_id:String)
}



class ChannelTableViewController: UITableViewController {
    
    var delegate:ChannelProtocol?
    
    
    var channelData:[JSON] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.title = "频道列表"
        
        let rightbuttonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editChannel:")
        
        self.navigationItem.rightBarButtonItem = rightbuttonItem
        
        self.view.alpha = 0.8

        self.navigationController?.navigationBar.hidden = false
        

    }
    
    
    
    func editChannel(sender: UIBarButtonItem){
        self.editing = !self.editing
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let itemToMove = channelData[sourceIndexPath.row]
        channelData.removeAtIndex(sourceIndexPath.row)
        channelData.insert(itemToMove, atIndex: destinationIndexPath.row)
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("channel")! as UITableViewCell
        let rowData:JSON = channelData[indexPath.row] as JSON
        

        cell.textLabel?.text = rowData["name"].string
        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 获取行数据
        let rowData = channelData[indexPath.row] as JSON
        
        let channel_id = rowData["channel_id"].stringValue
        
        delegate?.onChangeChannel(channel_id)
        

        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
}
