//
//  MovieViewController.swift
//  AVPlayerScreenShotSample
//
//  Created by gawawa124 on 2016/01/28.
//  Copyright © 2016年 gawawa124. All rights reserved.
//

import UIKit
import AVFoundation

class MovieViewController: UIViewController, AVPlayerItemOutputPullDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var playerItem: AVPlayerItem!
    var videoPlayer: AVPlayer!
    var videoPlayerView: AVPlayerView!
    
    var videoOutput: AVPlayerItemVideoOutput!
    var displayLink: CADisplayLink!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("freebies_032_mac", ofType: "mov")
        let fileURL = NSURL(fileURLWithPath: path!)
        let avAsset = AVURLAsset(URL: fileURL, options: nil)
        
        playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        videoPlayerView = AVPlayerView(frame: self.view.bounds)
        
        let layer = videoPlayerView.layer as! AVPlayerLayer
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.player = videoPlayer
        self.view.layer.addSublayer(layer)
        
        displayLink = CADisplayLink(target: self, selector: "displayLinkCallback:")
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink.paused = true
        
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)])
        videoOutput.setDelegate(self, queue: dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL))
        videoOutput.requestNotificationOfMediaDataChangeWithAdvanceInterval(0.03)
        
        playerItem.addOutput(videoOutput)
        videoPlayer.play()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        videoPlayer.seekToTime(kCMTimeZero)
        videoPlayer.play()
    }
    
    func outputMediaDataWillChange(sender: AVPlayerItemOutput) {
        displayLink.paused = false
    }
    
    func displayLinkCallback(sender: CADisplayLink) {
        var outputItemTime: CMTime = kCMTimeInvalid
        let nextVsync: CFTimeInterval = sender.timestamp + sender.duration
        outputItemTime = videoOutput.itemTimeForHostTime(nextVsync)
        
        if videoOutput.hasNewPixelBufferForItemTime(outputItemTime) {
            if let pixelBuffer = videoOutput.copyPixelBufferForItemTime(outputItemTime, itemTimeForDisplay: nil) {
                let ciImage = CIImage(CVPixelBuffer: pixelBuffer)
                //http://stackoverflow.com/questions/8072208/how-to-turn-a-cvpixelbuffer-into-a-uiimage
                let temporaryContext = CIContext(options: nil)
                let videoImage = temporaryContext.createCGImage(
                    ciImage,
                    fromRect: CGRectMake(
                        0,
                        0,
                        CGFloat(CVPixelBufferGetWidth(pixelBuffer)),
                        CGFloat(CVPixelBufferGetHeight(pixelBuffer))))
                backgroundImageView.image = UIImage(CGImage: videoImage)
            }
        }
    }
    
    @IBAction func failureButtonTapped(sender: AnyObject) {
        if let image = videoPlayerView.imageFromView() {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    @IBAction func successButtonTapped(sender: AnyObject) {
        if let image = backgroundImageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutablePointer<Void>) {
        if error == nil {
            let alert = UIAlertController(title: "", message: "Success", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            print(error)
        }
    }
}
