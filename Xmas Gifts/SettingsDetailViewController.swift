//
//  SettingsDetailViewController.swift
//  Xmas List
//
//  Created by David Figge on 2/10/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  View Controller for the settings detail view

import UIKit
class SettingsDetailViewController: UIViewController, UITextFieldDelegate, DismissSubviewDelegate {

    let CLASS_NAME = "GiftDetailsViewController"

    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var containerView : UIView!       // All input-based controls are on this view
    @IBOutlet weak var referenceField : UITextField!
    @IBOutlet weak var searchEngineLabel : UILabel!
    @IBOutlet weak var passwordButton : UIButton!
    @IBOutlet weak var passwordInfoLabel : UILabel!
    @IBOutlet weak var footerView : UIView!
    
    var keyboardManager : KeyboardManager! = nil
    var activeField : UITextField!
    var scrollRestoreOffset = 0.0
    var isMenuOpen = false
    var settings : Configuration.Settings!
    var rootKeyDatabase : RootKeys! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        referenceField.delegate=self            // Set things up to use the keyboard manager and scrollview to move things out of the way of the keyboard
        keyboardManager = KeyboardManager(baseView:view, scrollView:scrollView, hostView:containerView, footerView:footerView)
        registerForKeyboardNotifications()
        settings = Configuration.getSettingsData(createIfNeeded:true)
        
        if !AuthenticationViewController.canAuthenticateUser() {
            passwordButton.isEnabled = false
            passwordInfoLabel.text = "Secure access using TouchID (TouchID not available)"
        } else {
            passwordButton.isEnabled = true
            passwordInfoLabel.text = "Secure access using TouchID"
        }
        updateView()
        rootKeyDatabase = RootKeys()
    }
    
    @IBAction func ignore(_ sender: Any) {
    }
    
    public func dismissSubviews() {
        if presentedViewController != nil {
            let controller = presentedViewController as! DismissSubviewDelegate
            controller.dismissSubviews()
        }
        onBackClick()
    }
    
    func updateView() {
        setPasswordButtonImage()
        referenceField.text = settings.DataKey
        searchEngineLabel.text = settings.SearchEngine
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        keyboardManager.onKeyboardShown(notification:notification, activeView:activeField)
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        keyboardManager.onKeyboardHidden(notification: notification)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyboardManager.onDoneKey(activeView:activeField)
        return false
    }
    
    @IBAction func createReferenceKey() {
        let originalNameOption = Configuration.getOwnerName()
        var nameOption = originalNameOption
        var appendNumber : Int = 0
        let keys = rootKeyDatabase.Keys
        while keys.contains(nameOption) {
            appendNumber += 1
            nameOption = "\(originalNameOption)\(appendNumber)"
        }
        referenceField.text = nameOption
    }
    
    @IBAction func onPasswordToggle() {
        settings.RequirePassword = !settings.RequirePassword
        setPasswordButtonImage()
    }
    
    func setPasswordButtonImage() {
        passwordButton.setImage(getPasswordRequiredImage(), for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseSearchEngine() {
        _ = SelectionPrompt(title: "Search on", prompt: "Which search engine do you want to use for lookups?", button1: "Cancel", button2: Configuration.GOOGLE_SEARCH_ENGINE_KEY, button3: Configuration.AMAZON_SEARCH_ENGINE_KEY, parent: self) { (button) in
            switch(button) {
            case SelectionPromptViewController.BUTTON_2:
                self.settings?.SearchEngine = Configuration.GOOGLE_SEARCH_ENGINE_KEY
                break
            case SelectionPromptViewController.BUTTON_3:
                self.settings?.SearchEngine = Configuration.AMAZON_SEARCH_ENGINE_KEY
                break
            case SelectionPromptViewController.BUTTON_1:
                fallthrough
            default:
                break
            }
            self.updateView()
        }
    }
    
    @IBAction func onBackClick() {
        let originalKey = settings.DataKey
        settings.DataKey = referenceField.text!
        _=Configuration.saveSettingsData(settings: settings)
        self.dismiss(animated: true, completion: nil)
        if originalKey != settings.DataKey {
            People.reset()
        }
    }
    
    func getPasswordRequiredImage() -> UIImage {
        return UIImage(named:(settings.RequirePassword ? "checkbox-marked-circle.png" : "checkbox-blank-circle-outline.png"))!
    }
    
}
