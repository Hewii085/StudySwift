//
//  CameraViewController.swift
//  CamSessionTest
//
//  Created by 윤성빈 on 2020/10/16.
//

import UIKit
import SwiftUI
typealias strmCallback = ([UInt8], Bool) -> Void

final class CameraViewController: UIViewController
{
    
    let cameraController = CameraController()
    var previewView: UIView!
    
    override func viewDidLoad() {
                
        
        previewView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(previewView)
        
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.previewView)
        }
        
    }
    
  
    public func Record()
    {
        self.cameraController.StartRecord()
    }
}


extension CameraViewController : UIViewControllerRepresentable{
    public typealias UIViewControllerType = CameraViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewController>) -> CameraViewController {
        return CameraViewController()
    }
    
    public func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewController>) {
    }
}
