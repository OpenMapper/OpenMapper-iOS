//
//  ViewController.swift
//  OpenMapper
//
//  Created by Nicolas Degen on 11.06.17.
//  Copyright © 2017 OpenMapper. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController{
  var previewView : UIView!
  
  //Camera Capture requiered properties
  var videoDataOutput: AVCaptureVideoDataOutput!
  var videoDataOutputQueue: DispatchQueue!
  var previewLayer:AVCaptureVideoPreviewLayer!
  var captureDevice : AVCaptureDevice!
  let session = AVCaptureSession()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    previewView = UIView(frame: CGRect(x: 0, y: 0,
                                       width: UIScreen.main.bounds.size.width,
                                       height: UIScreen.main.bounds.size.height))
    previewView.contentMode = UIViewContentMode.scaleAspectFit
    view.addSubview(previewView)
    
    self.setupAVCapture()
  }
  
  override var shouldAutorotate: Bool {
    if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
      UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
      UIDevice.current.orientation == UIDeviceOrientation.unknown) {
      return false
    } else {
      return true
    }
  }
}


// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
  func setupAVCapture(){
    session.sessionPreset = AVCaptureSessionPreset640x480
    guard let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                     mediaType: AVMediaTypeVideo,
                     position: .back) else{
                      return
    }
    captureDevice = device
    beginSession()
  }
  
  func beginSession(){
    var err : NSError? = nil
    var deviceInput:AVCaptureDeviceInput?
    do {
      deviceInput = try AVCaptureDeviceInput(device: captureDevice)
    } catch let error as NSError {
      err = error
      deviceInput = nil
    }
    if err != nil {
      print("error: \(String(describing: err?.localizedDescription))");
    }
    if self.session.canAddInput(deviceInput){
      self.session.addInput(deviceInput);
    }
    
    videoDataOutput = AVCaptureVideoDataOutput()
    videoDataOutput.alwaysDiscardsLateVideoFrames=true
    videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue)
    if session.canAddOutput(self.videoDataOutput){
      session.addOutput(self.videoDataOutput)
    }
    videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
    
    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
    
    let rootLayer :CALayer = self.previewView.layer
    rootLayer.masksToBounds = true
    self.previewLayer.frame = rootLayer.bounds
    rootLayer.addSublayer(self.previewLayer)
    session.startRunning()
  }
  
  func captureOutput(_ captureOutput: AVCaptureOutput!,
                     didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                     from connection: AVCaptureConnection!) {
    // use sampleBuffer, i.e. the camera image here to process frame
  }
  
  // clean up AVCapture
  func stopCamera(){
    session.stopRunning()
  }
}
