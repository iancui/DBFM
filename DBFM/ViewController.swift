//
//  ViewController.swift
//  DBFM
//
//  Created by Ian on 15/11/8.
//  Copyright © 2015年 AppCode. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

import MediaPlayer



class ViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate, HttpProtocol ,ChannelProtocol {

    @IBOutlet weak var iv: EkoImageView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var detailTV: UITableView!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var progress: UIImageView!
    // 网络操作类的实例
    @IBOutlet weak var buttonPre: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonPlay: EkoButton!
    let ehttp:HttpController = HttpController()
    
    var songData:[JSON] = []
    
    var channelData:[JSON] = []
    
    var imageCache = Dictionary<String,UIImage>()
    
    var audioPlayer = MPMoviePlayerController()
    
    var timer:NSTimer?
    
    var currentIndex:Int = 0
    
    @IBOutlet weak var orderButton: OrderButton!
    // 定义一个变量
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "歌曲播放"
        iv.onRolation()
        
        // 设置背景模糊
        let blurEffect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        
        background.addSubview(blurView)
        detailTV.delegate = self
        detailTV.dataSource = self
        self.ehttp.delegate = self

        // 获取频道数据
        ehttp.onSearch("http://www.douban.com/j/app/radio/channels")
        
        onChangeChannel("33")
        
//        let parameters:[String: AnyObject] = ["type":"n","channel":"33","from":"mainsite"]
//
//        ehttp.onSearch("http://douban.fm/j/mine/playlist", parameters: parameters)
        
        //
        // Do any additional setup after loading the view, typically from a nib.
        
        detailTV.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.hidden = true
        
        // 监听按钮点击
        buttonPlay.addTarget(self, action: "onPlay:", forControlEvents: .TouchUpInside)
        buttonPre.addTarget(self, action: "onClick:", forControlEvents: .TouchUpInside)
        buttonNext.addTarget(self, action: "onClick:", forControlEvents: .TouchUpInside)
        orderButton.addTarget(self, action: "onOrder", forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playFinish", name: MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer)
        
        
        let adudiosession = AVAudioSession.sharedInstance()
        do {
        try adudiosession.setCategory(AVAudioSessionCategoryPlayback)
        
        } catch {
            
        }
//        self.setLockView(0)
        
        
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        
        if event!.type == UIEventType.RemoteControl {
            if event!.subtype == UIEventSubtype.RemoteControlPlay {
                print("received remote play")
                //                    RadioPlayer.sharedInstance.play()
            } else if event!.subtype == UIEventSubtype.RemoteControlPause {
                print("received remote pause")
                //                    RadioPlayer.sharedInstance.pause()
            } else if event!.subtype == UIEventSubtype.RemoteControlTogglePlayPause {
                print("received toggle")
                //                    RadioPlayer.sharedInstance.toggle()
            }
        }
        
        
        
    }
    
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }
    
    
    func setLockView(rowdata:JSON){
        
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle:rowdata["title"].string!,
            MPMediaItemPropertyArtist:rowdata["artist"].string!,
//            MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: self.getCacheImage(imageUrl: rowdata["picture"].string!)),
            MPMediaItemPropertyPlaybackDuration:audioPlayer.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime:audioPlayer.currentPlaybackTime,
            MPNowPlayingInfoPropertyPlaybackRate:1.0,
            
        ]
        
    }
    
    
    var isAutoFinish = true
    //
    func playFinish(){
        
        if isAutoFinish {
            switch(orderButton.order){
            case 1:
                currentIndex++
                if currentIndex > songData.count - 1 {
                    currentIndex = 0
                }
            case 2:
                currentIndex = random() % songData.count

            default :
                break
            }
            onSelectRow(currentIndex)
        }else {
            isAutoFinish = true
        }
        
    }
    
    
    
    func onOrder(){
        var message = ""
        switch(orderButton.order){
        case 1:
            message = "顺序播放"
        case 2:
            message = "随机播放"
        case 3:
            message = "单曲循环"
        default:
            message = "你逗我呢"
        }
        
        self.notice(message, type: NoticeType.info, autoClear: true, autoClearTime: 1)
        
    }
    
    func onClick(btn:UIButton){
        if btn == buttonNext {
            
            switch(orderButton.order){
            case 2:
                currentIndex = random() % songData.count
            default:
                currentIndex++
                if currentIndex > self.songData.count - 1 {
                    currentIndex = 0
                }
            }
        }else {
            switch(orderButton.order){
            case 2:
                currentIndex = random() % songData.count
            default:
                currentIndex--
                if currentIndex < 0 {
                    currentIndex = self.songData.count - 1
                }
            }
            
        }
        isAutoFinish = false
        onSelectRow(currentIndex)
        
    }
    
    
    
    func onPlay(btn:EkoButton){
        if btn.isPlay {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
    }
    
    
    
    func didRecieveResults(results: AnyObject) {
        let json = JSON(results)
        
        if let channels = json["channels"].array {
            self.channelData = channels
        }else if let song = json["song"].array {
            self.songData = song
            self.detailTV.reloadData()
            isAutoFinish = false
            onSelectRow(0)
        }
        
    }
    func onChangeChannel(channel_id: String) {
        
        let parameters:[String: AnyObject] = ["type":"n","channel":channel_id,"from":"mainsite"]
        
        ehttp.onSearch("http://douban.fm/j/mine/playlist", parameters: parameters)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let channelVC = segue.destinationViewController as! ChannelTableViewController
        
        channelVC.delegate = self
        channelVC.channelData = channelData

    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        iv.onRolation()
        self.navigationController?.navigationBar.hidden = true
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onSelectRow(index:Int){
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        detailTV.selectRowAtIndexPath(indexPath, animated: false, scrollPosition:.Top)
        
        let rowData = songData[index] as JSON
        
        let imgUrl = rowData["picture"].string
        
        onSetImage(imgUrl!)
        
        let songUrl = rowData["url"].string
        onSetAudio(songUrl!)
        
        
    }
    
    func onSetImage(imgUrl:String) {
        getCacheImage(imgUrl,imageView: self.iv)
        getCacheImage(imgUrl,imageView: self.background)
    }
    
    func getCacheImage(url:String,imageView:UIImageView){
        
        
        if let img = self.imageCache[url] as UIImage? {
            // 缓存中获取
             imageView.image = img
        }else {
            // 网络获取
            
            Alamofire.request(.GET, url).response(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), completionHandler: { (_, _, data, _) -> Void in
                let img = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    imageView.image =  img
                })
                self.imageCache[url] = img
            })
//                .responseData { (req) -> Void in
//                let img = UIImage(data: req.result.value!)
//                imgiv.image = img
//                self.imageCache[url] = img
//            }
//            
            
            
        }
        
    }
    // 播放音乐
    func onSetAudio(url:String){
        audioPlayer.stop()
        
        audioPlayer.contentURL = NSURL(string: url)
        
        audioPlayer.play()
        
        buttonPlay.onPlay()
        
        timer?.invalidate()
        playTime.text = "00:00"
        // 启动计时器
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        
        progress.frame.size.width = 0

    }
    
    
    
    func onUpdate(){
        // 获取播放的当前时间
        let c = audioPlayer.currentPlaybackTime
        if c > 0.0 {
            let all = Int(c)
            
            let t = audioPlayer.duration
            let pro:CGFloat = CGFloat(c/t)
            
            progress.frame.size.width = view.frame.size.width * pro
            
            let sec:Int = all % 60
            let min:Int = Int(all / 60)
            
            var time:String = ""
            
            if min < 10 {
                time.appendContentsOf("0\(min)")
            } else {
                time.appendContentsOf(String(min))
            }
            time.appendContentsOf(":")
            if sec < 10 {
                time.appendContentsOf("0\(sec)")
            }else {
                time.appendContentsOf(String(sec))
            }
            
            playTime.text = time
            
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.2) { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        isAutoFinish = false
        onSelectRow(indexPath.row)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = detailTV.dequeueReusableCellWithIdentifier("song")! as UITableViewCell
        
        let rowData:JSON = songData[indexPath.row]
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        let url = rowData["picture"].string


        self.getCacheImage(url!,imageView: cell.imageView!)
        
        self.setLockView(rowData)

        
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    

}

