//
//  SelectionPrompt.swift
//  Xmas List
//
//  Created by David Figge on 1/17/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  This class manages the prompting of users for 1, 2, or 3 specific options. Example: "What would you like to do", with options "Enable the feature", "Disable the feature", "Cancel"
//  You have up to 3 buttons you can define. Undefined buttons are not displayed (so you have options like "The document has loaded" with "OK" as the button
//  To use:
//  1) Call the constructor passing in
//     a) The title (e.g. "Confirmation")
//     b) The prompt telling the user about the choice they are making or what they need to know (if just an OK button)
//     c) The buttons needed in button1, button2, and button3. If not specified, the first button is OK and the others are not displayed
//     d) The parent view controller (the options will appear rising up from the bottom of the screen)
//     e) The completion closure, which will pass an integer indicating which button was selected (BUTTON_OK, BUTTON_CANCEL, BUTTON1, BUTTON2, BUTTON3). Typically the closure contains a switch based on the options the user might have chosen.

import UIKit

class SelectionPrompt: NSObject {
    public static let BUTTON_OK = UserPromptControllerViewController.BUTTON_OK
    public static let BUTTON_CANCEL = UserPromptControllerViewController.BUTTON_CANCEL
    public static let BUTTON_NONE = UserPromptControllerViewController.BUTTON_NONE
    private static let DEFAULT_POSITION = CGPoint(x:0,y:600)
    private static let DEFAULT_SIZE = CGSize(width:375,height:100)
    private var controller : SelectionPromptViewController? = nil
    private var prompt : String = ""
    private var enteredText : String = ""
    private var buttonPressed = 0
    private var onComplete : ((Int) -> Swift.Void)? = nil
    
    public var Prompt : String {
        get { return prompt }
        set(newValue) {
            prompt = newValue
            controller!.Prompt = newValue
        }
    }
    
    convenience init(title:String, prompt: String, button1 : String = "OK", button2: String! = nil, button3: String! = nil, parent : UIViewController, completion: ((Int) -> Swift.Void)? = nil) {
        self.init()
        display(title:title, prompt:prompt, button1:button1, button2:button2, button3:button3, onComplete: completion, parent:parent)
        //        onComplete = completion
    }
    
    convenience override init() {
        self.init(frame: CGRect(origin:SelectionPrompt.DEFAULT_POSITION, size:SelectionPrompt.DEFAULT_SIZE))
    }
    
    init(frame: CGRect) {
        controller = SelectionPromptViewController()
    }
    
    
    
    public func display(title:String, prompt:String, button1:String, button2:String!, button3:String!, onComplete: ((Int)->Swift.Void)?, parent:UIViewController) {
        controller!.modalPresentationStyle = .overCurrentContext
        controller!.modalTransitionStyle = .crossDissolve
        controller!.displayDialog(prompt: prompt, button1:button1, button2:button2, button3:button3, onComplete: onComplete!, parent:parent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
