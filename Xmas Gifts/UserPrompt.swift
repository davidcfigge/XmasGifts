//
//  UserPrompt.swift
//  Xmas List
//
//  Created by David Figge on 1/3/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  This class prompts the user and lets them type in an answer. For example, "Enter your name".
//  To use this, call the constructor passing in
//  a) The prompt ("Enter your name")
//  b) A default value (optional, defaults to empty string)
//  c) The parent view controller (used for presentation)
//  d) The completion closure, which will be called when the user dismisses the dialog
//     1) The Int parameter will be BUTTON_OK if the user pressed OK, and BUTTON_CANCEL if the user canceled
//  e) The keyboard type, which defaults to the standard character keyboard. Override this if you need (for example) the number keyboard

import UIKit

class UserPrompt : NSObject {
    public static let BUTTON_OK = UserPromptControllerViewController.BUTTON_OK
    public static let BUTTON_CANCEL = UserPromptControllerViewController.BUTTON_CANCEL
    public static let BUTTON_NONE = UserPromptControllerViewController.BUTTON_NONE
    private static let DEFAULT_POSITION = CGPoint(x:400,y:100)
    private static let DEFAULT_SIZE = CGSize(width:200,height:100)
    private var controller : UserPromptControllerViewController? = nil
    private var prompt : String = ""
    private var enteredText : String = ""
    private var buttonPressed = 0
    
    public var Prompt : String {
        get { return prompt }
        set(newValue) {
            prompt = newValue
            controller!.Prompt = newValue
        }
    }
    
    convenience init(prompt: String, defaultValue : String = "", parent : UIViewController, completion: ((Int, String) -> Swift.Void)? = nil, keyboard:UIKeyboardType = UserPromptControllerViewController.DEFAULT_KEYBOARD) {
        self.init()
        display(prompt:prompt, defaultValue:defaultValue, onComplete: completion, parent:parent, keyboard:keyboard)
//        onComplete = completion
    }
    
    convenience override init() {
        self.init(frame: CGRect(origin:UserPrompt.DEFAULT_POSITION, size:UserPrompt.DEFAULT_SIZE))
    }
    
    init(frame: CGRect) {
        controller = UserPromptControllerViewController()
    }
    
    public func display(prompt:String, defaultValue:String, onComplete: ((Int,String)->Swift.Void)?, parent:UIViewController, keyboard:UIKeyboardType) {
        controller!.modalPresentationStyle = .overCurrentContext
        controller!.modalTransitionStyle = .crossDissolve
        controller!.displayDialog(prompt: prompt, defaultValue: defaultValue, onComplete: onComplete!, parent:parent, keyboard:keyboard)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
