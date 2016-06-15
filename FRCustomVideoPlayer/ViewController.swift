//
//  ViewController.swift
//  FRCustomVideoPlayer
//
//  Created by  on 6/2/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func chayVideo(sender: AnyObject) {
        // http://mos.scentvilla.vn:1935/kem_xoi-_tap_65_-_cau_hon_nguoi_dep_360p.mp4
        
        // http://clips.vorwaerts-gmbh.de/VfE_html5.mp4
        
        let videoController = YPlayerCustom.instanceFromNib("Demo video test", url: "http://mos.scentvilla.vn:1935/kem_xoi-_tap_65_-_cau_hon_nguoi_dep_360p.mp4")
        self.view.addSubview(videoController)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

