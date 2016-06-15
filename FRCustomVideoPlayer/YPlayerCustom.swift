//
//  YPlayerCustom.swift
//  FRCustomVideoPlayer
//
//  Created by  on 6/6/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

import UIKit
import AVFoundation
let yPlayerStatus = "status"
let yControllerNibName = "YPlayerCustom"

class YPlayerCustom: UIView {
    
    // define constant
    let yWidthScreen: CGFloat = UIScreen.mainScreen().bounds.size.width
    let HeightScreen: CGFloat = UIScreen.mainScreen().bounds.size.height
    let yHeightScreen: CGFloat = 2/3 * UIScreen.mainScreen().bounds.size.height

    
    // player
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerSeeking: Bool = false
    private var currentEndTime: CMTime?
    
    // for control
    private var isPlaying: Bool = false
    private var timeObserver:AnyObject?
    private var navigationFlag: Bool!
    
    // outlet
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    class func instanceFromNib(title: String, url: String) -> UIView {
        let weakSelf: YPlayerCustom = UINib(nibName: yControllerNibName, bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! YPlayerCustom
        weakSelf.frame = CGRectMake(0, 0, weakSelf.yWidthScreen, 320)
        
        //TODO: Call func init here
        let playerViewtapGesture = UITapGestureRecognizer(target: weakSelf, action: #selector(playerViewTapEvent))
        let controlViewtapGesture = UITapGestureRecognizer(target: weakSelf, action: #selector(controlViewTapEvent))
        
        weakSelf.playerView.addGestureRecognizer(playerViewtapGesture)
        weakSelf.controlView.addGestureRecognizer(controlViewtapGesture)
        
        weakSelf.initVideoPlayer(title, url: url)
        return weakSelf
    }
    
    deinit {
        print("YPlayerCustom -> deinit")
        if self.player != nil {
            self.player = nil
        }
        if self.playerLayer != nil {
            self.playerLayer = nil
        }
    }
    
    func initVideoPlayer(title: String, url: String) {
        if self.player == nil {
            self.titleLabel.text = title
            self.seekSlider.value = 0
            self.loadingIndicator.hidden = false
            self.loadingIndicator.startAnimating()
            
            let currentPlayerItem = AVPlayerItem(URL: NSURL(string: url)!)
            self.player = AVPlayer(playerItem: currentPlayerItem)
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect // AVLayerVideoGravityResizeAspectFill
            self.playerView.layer.addSublayer(self.playerLayer!)
            self.playerLayer!.frame = self.frame
            
            self.startObservers()
            self.controlViewAnimation(true)
        }
    }
    
    func startObservers() {
        if (timeObserver == nil) {
            weak var wSelf = self
            timeObserver = player?.addPeriodicTimeObserverForInterval(CMTimeMake(1, 100), queue: dispatch_get_main_queue(),
                                                                      usingBlock: { (time: CMTime) -> Void in
                                                                        let currentItem = wSelf!.player?.currentItem!
                                                                        let endTime = CMTimeConvertScale(currentItem!.asset.duration, time.timescale, CMTimeRoundingMethod.RoundHalfAwayFromZero)
                                                                        let currentTimeF: Float = (Float)(CMTimeGetSeconds(time))
                                                                        let endTimeF: Float = (Float)(CMTimeGetSeconds(endTime))
                                                                        if (!isnan(currentTimeF) && !isinf(currentTimeF) && !isnan(endTimeF) && !isinf(endTimeF)) {
                                                                            wSelf?.currentEndTime = endTime
                                                                            wSelf!.updateTime(currentTimeF, endTime: endTimeF)
                                                                        }
            })
        }
        player?.currentItem!.addObserver(self, forKeyPath: yPlayerStatus, options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    func stopObservers() {
        if (timeObserver != nil) {
            player?.currentItem!.removeObserver(self, forKeyPath: yPlayerStatus)
            player?.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    func updateTime(durationTime: Float, endTime: Float) {
        self.seekSlider.value = (Float)(durationTime/endTime)
        self.durationTimeLabel.text = self.convertTime(durationTime)
        self.endTimeLabel.text = self.convertTime(endTime)
    }
    
    func convertTime(time: Float) -> String {
        var timeStr = "00:00"
        var minute: Int = 0
        var second: Int = (Int)(floorf(time))
        if time > 60 {
            minute = (Int)(floorf(time/60))
            second = second - minute * 60
        }
        
        timeStr = minute < 10 ? "0\(minute)" : "\(minute)"
        timeStr = timeStr + ":" + (second < 10 ? "0\(second)" : "\(second)")
        return timeStr
    }
    
    func playVideo() -> Void {
        self.player?.play()
    }
    
    func pauseVideo() -> Void {
        self.player?.pause()
    }
    
    func playerViewTapEvent(sender: UITapGestureRecognizer) -> Void {
        print("Tap here: ", self.controlView.hidden)
        if self.controlView.hidden {
            self.controlViewAnimation(false)
        } else {
            self.controlViewAnimation(true)
        }
    }
    
    func controlViewTapEvent(sender: UITapGestureRecognizer) -> Void {
        print("Control here: ", self.controlView.hidden)
        if self.controlView.hidden {
            self.controlViewAnimation(false)
        } else {
            self.controlViewAnimation(true)
        }
    }
    
    func controlViewAnimation(show: Bool) -> Void {
        if show {
            YPlayerCustom.animateWithDuration(1, delay: 0.5, options: UIViewAnimationOptions.TransitionCurlDown, animations: {
                self.controlView.alpha = 0
                }, completion: { finished in
                    print("Hidden control view")
                    self.controlView.hidden = show
            })
        } else {
            YPlayerCustom.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
                self.controlView.hidden = show
                self.controlView.alpha = 1.0
                }, completion: { finished in
                    print("Show control view")
            })
        }
    }
    
    func degreesToRadians(x: Float) -> CGFloat {
        return CGFloat(x * Float(M_PI) / 180.0)
    }

    // func action
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>){
        if keyPath! == yPlayerStatus {
            let status: AVPlayerStatus = self.player!.status
            switch (status) {
            case AVPlayerStatus.ReadyToPlay:
                self.loadingIndicator.hidden = true
                self.loadingIndicator.stopAnimating()
                self.playVideo()
                break
            case AVPlayerStatus.Unknown, AVPlayerStatus.Failed:
                break
            }
        }
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        print("Done Action")
    }
    
    @IBAction func pauseButton(sender: AnyObject) {
        if self.player?.rate == 1.0 {
            self.pauseButton.setImage(UIImage(named: "VKVideoPlayer_play"), forState: UIControlState.Normal)
            self.pauseVideo()
        } else {
            self.pauseButton.setImage(UIImage(named: "VKVideoPlayer_pause"), forState: UIControlState.Normal)
            self.playVideo()
        }
        
    }
    
    @IBAction func zoomAction(sender: AnyObject) {
        print("Zoom Action")
        
        UIView.beginAnimations("rotate", context: nil)
        UIView.setAnimationDuration(0.5)
        
        print("yWidthScreen rotate: ", self.yWidthScreen)
        print("yHeightScreen rotate: ", self.yHeightScreen)
        
        self.transform = CGAffineTransformMakeRotation(self.degreesToRadians(90.0))
        self.frame = CGRectMake(-self.yWidthScreen, 0, self.HeightScreen, self.yWidthScreen)
        self.playerLayer!.frame = self.frame
        self.updateConstraints()
        self.layoutIfNeeded()
        
        UIView.commitAnimations()
    }
    
    @IBAction func seekAction(sender: UISlider) {
        if(playerSeeking || self.player == nil || currentEndTime == nil) {
            return
        }
        self.player?.pause()
        let currentValue = Double(sender.value)
        let time = CMTimeMultiplyByFloat64(currentEndTime!, currentValue)
        playerSeeking = true
        sender.userInteractionEnabled = false
        weak var wSelf = self
        player?.seekToTime(time, completionHandler: { (finished) -> Void in
            if finished {
                if wSelf != nil {
                    let currentTimeF: Float = (Float)(CMTimeGetSeconds(time))
                    let endTimeF: Float = (Float)(CMTimeGetSeconds(wSelf!.currentEndTime!))
                    if (!isnan(currentTimeF) && !isinf(currentTimeF) && !isnan(endTimeF) && !isinf(endTimeF)) {
                        wSelf!.updateTime(currentTimeF, endTime: endTimeF)
                    }
                }
                wSelf?.playerSeeking = false
                sender.userInteractionEnabled = true
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    wSelf?.playVideo()
                }
            }
        })
    }
    
}
