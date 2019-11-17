//
//  ViewController.swift
//  Camera_Recognition
//
//  Created by Oleksii Kolakovskyi on 11/14/19.
//  Copyright © 2019 Aleksey. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let captureSession =  AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)

        // VNImageRequestHandler(cgImage: <#T##CGImage#>, options: <#T##[VNImageOption : Any]#>).perform(<#T##requests: [VNRequest]##[VNRequest]#>)

    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard  let pixerBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, err) in
            guard let results = finishedRequest.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else {return}
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                           self.textLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                       }
        }
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixerBuffer, options: [:]).perform([request])
        
        
    }
}

