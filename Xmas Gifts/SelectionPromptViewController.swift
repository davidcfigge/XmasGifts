//
//  SelectionPromptViewController.swift
//  Xmas List
//
//  Created by David Figge on 1/17/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  Supports selection of 2-3 options (or simple messaging).
//  Access via the utility class SelectionPrompt

import UIKit

class SelectionPromptViewController: UIViewController, DismissSubviewDelegate {
    @IBOutlet weak var buttonBaseView : UIView!
    @IBOutlet weak var userPrompt : UILabel!
    @IBOutlet weak var button1 : UIButton!
    @IBOutlet weak var button2 : UIButton!
    @IBOutlet weak var button3 : UIButton!
    
    
    public static let BUTTON_1 = 0
    public static let BUTTON_2 = 1
    public static let BUTTON_3 = 2
    private var button1Text = "OK"
    private var button2Text : String! = nil
    private var button3Text : String! = nil
    private var prompt : String = "Select:"
    private var onComplete : ((Int) -> Swift.Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPrompt!.text = prompt
        button1.setTitle(button1Text, for: UIControlState.normal)
        if (button2Text != nil) {
            button2.setTitle(button2Text, for: UIControlState.normal)
            button2.isHidden = false
            if (button3Text == nil) {
                button2.frame = CGRect(x:0,y:0,width:buttonBaseView.frame.size.width,height:buttonBaseView.frame.size.height)
            }
        } else {
            button2.isHidden = true
        }
        if (button3Text != nil) {
            button3.setTitle(button3Text, for: UIControlState.normal)
            button3.isHidden = false
        } else {
            button3.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayDialog(prompt: String, button1: String, button2: String! = nil, button3: String! = nil, onComplete: @escaping ((Int)->Swift.Void), parent:UIViewController) {
        Prompt = prompt
        button1Text = button1
        button2Text = button2
        button3Text = button3
        OnComplete = onComplete
        parent.present(self, animated:true, completion:nil)
    }
    
    public func dismissSubviews() {
        dismiss(animated: false, completion:nil)
    }
    
    public var Prompt : String {
        get { return userPrompt.text! }
        set(newValue) {
            prompt = newValue
        }
    }
    
    public var OnComplete : (Int) -> Swift.Void {
        get { return onComplete! }
        set (block) {
            onComplete = block
        }
    }
    
    @IBAction func onButton1() {
        dismiss(animated: false, completion: nil)
        onComplete!(SelectionPromptViewController.BUTTON_1)
    }
    
    @IBAction func onButton2() {
        dismiss(animated: false, completion: nil)
        onComplete!(SelectionPromptViewController.BUTTON_2)
    }
    
    @IBAction func onButton3() {
        dismiss(animated: false, completion: nil)
        onComplete!(SelectionPromptViewController.BUTTON_3)
    }
    
}
