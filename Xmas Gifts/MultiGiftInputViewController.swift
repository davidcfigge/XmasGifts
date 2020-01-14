//
//  MultiGiftInputViewController.swift
//  Xmas List
//
//  Created by David Figge on 1/19/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  This class presents a view that asks the user for a list of gift items to add. This list is returned in the completion closure

import UIKit

class MultiGiftInputViewController: UIViewController, DismissSubviewDelegate {
    @IBOutlet weak var textView : UITextView!
    
    var onCompletion : (([String]) -> Void)! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func dismissSubviews() {
        onCancel()
    }
    
    @IBAction func onDone() {
        dismiss(animated: true, completion: nil)
        let input = textView.text
        let newlineChars = NSCharacterSet.newlines
        let lines = input?.components(separatedBy: newlineChars)
        onCompletion(lines!)

    }
    
    @IBAction func onCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func setOnCompletion(newValue: @escaping ([String]) -> Void) {
        onCompletion = newValue
    }
    

}
