//
//  ViewController.swift
//  WSDCircleGestureRecognizer
//
//  Created by vulgur on 16/3/7.
//  Copyright © 2016年 MAD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var outerCircleView: UIView!
    @IBOutlet var innerCircleView: UIView!
    
    let OuterRadius: CGFloat = 150
    let InnerRadius: CGFloat = 80
    
    var feedbackLabel = UILabel(frame: CGRectZero)
    var centerPoint: CGPoint = CGPointZero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        outerCircleView.layer.cornerRadius = OuterRadius
        innerCircleView.layer.cornerRadius = InnerRadius
        
        //add feedbackLabel
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(feedbackLabel)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[view]-|", options: [], metrics: nil, views: ["view":feedbackLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[view]", options: [], metrics: nil, views: ["view":feedbackLabel]))
        
        feedbackLabel.textAlignment = .Center
        feedbackLabel.numberOfLines = 0;
        feedbackLabel.font = UIFont(name: "", size: 20)
        feedbackLabel.text = ""
        feedbackLabel.textColor = UIColor.blackColor()
        
        centerPoint = CGPoint(x: CGRectGetWidth(outerCircleView.frame)/2, y: CGRectGetHeight(outerCircleView.frame)/2)
        let circleGestureRecognizer = CircleGestureRecognizer(center: centerPoint, innerRadius: InnerRadius, outerRadius: OuterRadius, target: self, action: "handleCircleGesture:")
        outerCircleView.addGestureRecognizer(circleGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Action
    
    func handleCircleGesture(recognizer: CircleGestureRecognizer){

        feedbackLabel.text = ""
        
        if let angle = recognizer.angle {
            feedbackLabel.text = feedbackLabel.text! + "\n" + String(format:"Angle: %.2f%", angle.deg)
        }
        if let total = recognizer.totalAngle {
            feedbackLabel.text = feedbackLabel.text! + "\n" + String(format:"Total: %.2f%", total)
        }
        if let velocity = recognizer.velocity {
            feedbackLabel.text = feedbackLabel.text! + "\n" + String(format:"Velocity: %.2f%", velocity)
        }
    }
}

