//
//  KeyboardManager.swift
//  Xmas List
//
//  Created by David Figge on 1/12/17.
//  Copyright © 2017 David Figge. All rights reserved.
//

import Foundation
import UIKit

// This class manages scrolling the content of the window when the soft keyboard is displayed or hidden. This is only done if the control
// in question will be hidden. To use this class:
// 1) Place all editable fields into a scrollview. This is the view that will be scrolled when input is requested
// 2) In viewDidLoad, initialize this object passing in the base view (e.g. self.view) and the scrollview
// 2a) If you have a view as a container for the text fields you can pass that to the constructor under hostView
// 2b) If you have a footer at the bottom of the page, you can pass that in as footerView
// 3) Register for keyboard notifications via the NotificationCenter.default.addObserver call. Register for UIKeyboardWillShow and UIKeyboardWillHide You'll need to make the view controller a UITextFieldDelegate for this.
// 4) When the notification for keyboard shown comes, call onKeyboardShown passing in the notification and the active field
// 5) When the notification for keyboard hidden comes, call onKeyboardHidden

class KeyboardManager {
    let baseView : UIView!
    let scrollView : UIScrollView
    let hostView : UIView!
    let footerView : UIView!
    let isAnimated : Bool
    var doneButtonTextView : UITextField! = nil
    
    var keyboardHeight : CGFloat = 0.0
    var scrollRestoreOffset = 0.0
    
    init(baseView : UIView!, scrollView : UIScrollView!, isAnimated : Bool = false, hostView : UIView! = nil, footerView : UIView! = nil) {
        self.baseView = baseView
        self.scrollView = scrollView
        self.hostView = hostView
        self.footerView = footerView
        self.isAnimated = isAnimated
    }
    
    func isPhysicalKeyboardAttached(notification:NSNotification) -> Bool {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        let keyboard = baseView.convert(keyboardFrame, from: baseView.window)
        
        return keyboard.size.height < 100        // iOS may show a toolbar, which isn't a keyboard but allows for special keys. This check is arbitrary, but not sure of a better way...
    }
    
    func onKeyboardShown(notification:NSNotification, activeView: UIView!) {
        if activeView == nil {
            return
        }
        
        if isPhysicalKeyboardAttached(notification: notification) {
            return;             // If using a physical keyboard, no need to scroll (even if using toolbar on numerical editing)
        }
        
        // Calculate keyboard size
        var info = notification.userInfo!
        keyboardHeight = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var visibleRect = baseView.frame
        visibleRect.size.height -= keyboardHeight
        var controlRect = activeView.frame
        if (hostView != nil) {
            controlRect.origin.y += hostView.frame.origin.y
        }
        var scrollOffset = CGFloat(keyboardHeight)
        if (footerView != nil) {
            scrollOffset -= footerView.frame.size.height
        }
        if (!visibleRect.contains(controlRect.origin)) {
            scrollRestoreOffset = Double(keyboardHeight - (footerView != nil ? footerView.frame.size.height : 0))
            if scrollRestoreOffset <= 0 {
                scrollRestoreOffset = 0
            }
            scrollView.setContentOffset(CGPoint(x:0,y:scrollRestoreOffset), animated: isAnimated)
        }
        
        scrollView.isScrollEnabled = true
    }
    
    func addDoneButtonForField(field:UITextField)
    {
        doneButtonTextView = field
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0, width:320, height:50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.onDoneButton))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        field.inputAccessoryView = doneToolbar
    }
    
    @objc func onDoneButton() {
        onDoneKey(activeView:doneButtonTextView)
    }
    
    func onKeyboardHidden(notification: NSNotification) {
        let isKeyboardAttached = isPhysicalKeyboardAttached(notification: notification)
        let contentInsets = UIEdgeInsetsMake(0.0,0.0,-keyboardHeight,0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        if !isKeyboardAttached {        // If there's not a physical keyboard, hiding the keyboard means end editing. If physical keyboard, virtual one is hidden at start of editing
            baseView.endEditing(true)
        }
        scrollView.isScrollEnabled = false
    }
    
    @objc func onDoneKey(activeView:UIView!) {
        activeView!.resignFirstResponder()
    }
}
