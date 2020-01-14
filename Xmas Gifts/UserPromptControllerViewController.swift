//
//  UserPromptControllerViewController.swift
//  Xmas List
//
//  Created by David Figge on 1/3/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  Prompt the user for some input. Access via the UserPrompt utility class

import UIKit

class UserPromptControllerViewController: UIViewController, DismissSubviewDelegate {
    public static let BUTTON_NONE = 0
    public static let BUTTON_OK = 1
    public static let BUTTON_CANCEL = 2
    public static let DEFAULT_KEYBOARD = UIKeyboardType.alphabet
    private var defaultValue : String = ""
    private var prompt : String = "Enter value"
    private var onComplete : ((Int, String) -> Swift.Void)? = nil
    private var keyboard : UIKeyboardType = UserPromptControllerViewController.DEFAULT_KEYBOARD

    override func viewDidLoad() {
        super.viewDidLoad()
        userInput!.text = defaultValue
        userPrompt!.text = (prompt == "" ? prompt : prompt + ":")
        userInput!.keyboardType = keyboard
        if keyboard == UIKeyboardType.alphabet {
            userInput!.autocapitalizationType = UITextAutocapitalizationType.words
        }
        userInput!.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userInput.selectAll(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func dismissSubviews() {
        dismiss(animated: false, completion: nil)
    }
    
    public var DefaultValue : String {
        get {
            return self.defaultValue
        }
        set(value) {
            self.defaultValue = value
        }
    }
    
    func displayDialog(prompt: String, defaultValue: String, onComplete: @escaping ((Int,String)->Swift.Void), parent:UIViewController, keyboard:UIKeyboardType) {
        Prompt = prompt
        DefaultValue = defaultValue
        OnComplete = onComplete
        self.keyboard = keyboard
        parent.present(self, animated:true, completion:nil)
    }
    
    public var Prompt : String {
        get { return userPrompt.text! }
        set(newValue) {
            prompt = newValue
        }
    }
    
    public var Input : String {
        get { return userInput.text! }
        set(newValue) { userInput.text = newValue }
    }
    
    public var OnComplete : (Int, String) -> Swift.Void {
        get { return onComplete! }
        set (block) {
            onComplete = block
        }
    }
    
    @IBOutlet var userPrompt : UILabel!
    @IBOutlet var userInput : UITextField!
    
    @IBAction func onDone() {
        dismiss(animated: false, completion: nil)
        onComplete!(UserPromptControllerViewController.BUTTON_OK, userInput!.text!)
    }
    
    @IBAction func onCancel() {
        dismiss(animated: false, completion: nil)
        onComplete!(UserPromptControllerViewController.BUTTON_CANCEL, userInput!.text!)
    }
    

}
