//
//  CanvasViewController.swift
//  ProtoCanvas
//
//  Created by Jonathan Chen on 6/2/16.
//  Copyright © 2016 Chenlo Park. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        trayDownOffset = 150
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x, y: trayView.center.y + trayDownOffset)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didPanTray(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            trayOriginalCenter = trayView.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else if sender.state == UIGestureRecognizerState.Ended {
            // snap to top or bottom
            let velocity = sender.velocityInView(view)
            if velocity.y > 0 {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] , animations: { () -> Void in
                    self.trayView.center = self.trayDown
                    }, completion: { (Bool) -> Void in
                })
            } else {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] , animations: { () -> Void in
                    self.trayView.center = self.trayUp
                    }, completion: { (Bool) -> Void in
                })
            }
        }
    }
    
    
    @IBAction func didPanFace(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(view)

        
        if sender.state == UIGestureRecognizerState.Began {
            // do stuff
            let imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            UIView.animateWithDuration(0.4, delay: 0.0,
                                       options: [], animations: { () -> Void in
                                        self.newlyCreatedFace.transform = CGAffineTransformMakeScale(1.5, 1.5)
                }, completion: nil)
            
            // instantiate new pan gesture recognizer
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CanvasViewController.didPanNewFace(_:)))

            newlyCreatedFace.userInteractionEnabled = true
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            
            // instantiate new pinch recognizer
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(CanvasViewController.didPinchNewFace(_:)))
            pinchGestureRecognizer.delegate = self;
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            
            // instantiate new rotate recognizer
            let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(CanvasViewController.didRotateNewFace(_:)))
            newlyCreatedFace.addGestureRecognizer(rotateGestureRecognizer)
            
            // instantiate new double tap recognizer
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CanvasViewController.didDoubleTapNewFace(_:)))
            
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            
            newlyCreatedFace.addGestureRecognizer(doubleTapGestureRecognizer)
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            // do other stuff
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
            

        } else if sender.state == UIGestureRecognizerState.Ended {
            // do rest of stuff
            UIView.animateWithDuration(0.4, delay: 0.0,
                                       options: [], animations: { () -> Void in
                                        self.newlyCreatedFace.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        }
    }
    
    func didPanNewFace(sender: UIPanGestureRecognizer) {

        let translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            // if dropped on tray return to original position
            if newlyCreatedFaceOriginalCenter.y + translation.y > trayView.frame.origin.y - 10 {
                
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] , animations: { () -> Void in
                                    self.newlyCreatedFace.center = self.newlyCreatedFaceOriginalCenter
                    }, completion: { (Bool) -> Void in
                })
            } else {
                newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
            }

            
        } else if sender.state == UIGestureRecognizerState.Ended {
            // do nothing
        }
    }
    
    func didPinchNewFace(sender: UIPinchGestureRecognizer) {
        
        let scale = sender.scale
        
        newlyCreatedFace = sender.view as! UIImageView
        newlyCreatedFace.transform = CGAffineTransformScale(newlyCreatedFace.transform, scale, scale)
        
        sender.scale = 1
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didRotateNewFace(sender: UIRotationGestureRecognizer) {
        
        let rotation = sender.rotation
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
        } else if sender.state == UIGestureRecognizerState.Changed {
            newlyCreatedFace.transform = CGAffineTransformRotate(newlyCreatedFace.transform, rotation)
            sender.rotation = 0
        }
        
    }
    
    func didDoubleTapNewFace(sender: UITapGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
        } else if sender.state == UIGestureRecognizerState.Ended {
            newlyCreatedFace.removeFromSuperview()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
