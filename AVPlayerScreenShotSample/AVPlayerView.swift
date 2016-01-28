//
//  AVPlayerView.swift
//  AVPlayerScreenShotSample
//
//  Created by gawawa124 on 2016/01/28.
//  Copyright © 2016年 gawawa124. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerView: UIView {
    var player: AVPlayer {
        get {
            let layer = self.layer as! AVPlayerLayer
            return layer.player!
        }
        set {
            let layer = self.layer as! AVPlayerLayer
            layer.player = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    func setVideoFillMode(mode: NSString) {
        let layer = self.layer as! AVPlayerLayer
        layer.videoGravity = mode as String
    }
}
