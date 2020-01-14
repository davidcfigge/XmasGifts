//
//  GiftDetailsViewController.swift
//  Xmas List
//
//  Created by David Figge on 12/7/16.
//  Copyright © 2016 David Figge. All rights reserved.
//

import UIKit

class GiftDetailsViewController: UIViewController, FirebaseDBListener, UITextFieldDelegate, UITextViewDelegate, DismissSubviewDelegate {
    let CLASS_NAME = "GiftDetailsViewController"
    
    @IBOutlet weak var giftLabel : UILabel!
    @IBOutlet weak var descriptionTextView : UITextView!
    @IBOutlet weak var categoryTextView : UITextField!
    @IBOutlet weak var storeTextView : UITextField!
    @IBOutlet weak var priceTextView : UITextField!
    @IBOutlet weak var packageIdTextField: UITextField!
    @IBOutlet weak var purchasedButton : UIButton!
    @IBOutlet weak var searchButton : UIButton!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var containerView : UIView!       // All input-based controls are on this view
    @IBOutlet weak var menuButton : UIButton!
    @IBOutlet weak var deleteButton : UIButton!
    @IBOutlet weak var footer : UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var keyboardManager : KeyboardManager! = nil
    var activeField : UITextField!
    var scrollRestoreOffset = 0.0
    var isMenuOpen = false
    
    var gift : Gift? = nil
    let pieChart = PieChart()
    var person : Person? = nil
    var personName = String()       // This is set during the segue
    var giftName = String()         // This is set during the segue
    
    func onFirebaseDBChanged() {
        updateDisplay()
    }
    
    // Called whenever the display needs updating, like at the start or when the underlying data changes
    func updateDisplay() {
        person = People.Entries[personName]
        gift = person!.Gifts[giftName]
        if gift == nil {
            return
        }
        giftLabel.text = giftName
        descriptionTextView.text = gift?.Description
        categoryTextView.text = gift?.Category
        storeTextView.text = gift?.Store
        priceTextView.text = DataUtils.getEditableDollarCentString(amount: (gift?.Price)!)
        packageIdTextField.text = gift?.Identifier
        setPurchasedImage()
        statusLabel.text = gift?.StatusDescription
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        People.addListener(listener: self, className: CLASS_NAME)
        giftLabel.isUserInteractionEnabled = true
        giftLabel.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(onGiftLabelTapped)))
        updateDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priceTextView.delegate = self       // We need to know when the textviews are selected so we can scroll if needed
        categoryTextView.delegate = self
        storeTextView.delegate = self
        descriptionTextView.delegate = self
        keyboardManager = KeyboardManager(baseView:view, scrollView:scrollView, hostView:containerView, footerView:footer)  // Let the keyboard manager be aware of what's happening
        keyboardManager.addDoneButtonForField(field:priceTextView)      // Add a Done button view for priceTextView
        registerForKeyboardNotifications()                              // Ready for keyboard notifications now
    }
    
    func dismissSubviews() {
        if presentedViewController != nil {
            let controller = presentedViewController as! DismissSubviewDelegate
            controller.dismissSubviews()
        }
        onBackClick()
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            view.endEditing(true)
            return false
        }
        else
        {
            return true
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        People.removeListener(className: CLASS_NAME)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier!) {
        case "GiftDetail2Search":
            let searchView = segue.destination as! SearchViewController
            searchView.searchItem = giftName
            searchView.searchDetails = descriptionTextView.text
            searchView.searchString = giftName + " " + descriptionTextView.text
        default:
            break;
        }
    }
    
    func updatePieChart() {
        pieChart.reset()
        let gifts = person?.Gifts
        for key in gifts!.keys {
            let gift = gifts?[key]
            if (gift!.Purchased) {
                pieChart.addSegment(title:key, value:CGFloat(DataUtils.getDollarInt(amount:(gift?.Price)!)))
            }
        }
        pieChart.addSegment(title:"Remaining", value:CGFloat(DataUtils.getDollarInt(amount:person!.getBudgetRemaining())), color:UIColor.lightGray)
    }
    
    func openMenu() {
        if !isMenuOpen {
            onMenu()
        }
    }
    
    func closeMenu() {
        if isMenuOpen {
            onMenu()
        }
    }
    
    @IBAction func onMenu() {
        NSLog("OnMenu")
        isMenuOpen = !isMenuOpen
        let buttonsHidden = isMenuOpen ? false : true
        searchButton.isHidden = buttonsHidden
        deleteButton.isHidden = buttonsHidden
        menuButton.setImage(getMenuImage(), for: UIControlState.normal)
    }
    
    func getMenuImage() -> UIImage! {
        if isMenuOpen {
            return UIImage(named: "close-circle")
        }
        return UIImage(named: "menu-circle")
    }
    
    @IBAction func onDelete() {
        closeMenu()
        _ = SelectionPrompt(title:"Are you sure?", prompt: "Delete \(giftName)?", button1: "Cancel", button2: "Delete", parent: self, completion: { (button:Int) -> Void in
            if button == SelectionPromptViewController.BUTTON_2 {
                self.dismiss(animated: true, completion: nil)
                People.deleteGift(person:self.person!, giftName:self.giftName)
            }
        })        
    }
    
    @IBAction func onSearch() {
        closeMenu()
    }
    
    @IBAction func onBackClick() {
        gift?.Description = descriptionTextView.text
        gift?.Category = categoryTextView.text!
        gift?.Store = storeTextView.text!
        let amount = DataUtils.getIntFromAmountString(amountString: priceTextView.text!)
        gift?.Price = amount
        gift?.Identifier = packageIdTextField.text!
        People.saveChanges()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPurchasedClick() {
        _ = gift?.nextStatus()
        let image = gift?.getPurchaseStatusIcon()
        purchasedButton.setImage(image, for:.normal)
        statusLabel.text = gift?.StatusDescription;
//        gift?.Purchased = !((gift?.Purchased)!)
//        People.saveChanges()
    }
    
    @objc func onGiftLabelTapped(sender:UITapGestureRecognizer) {
        _ = UserPrompt(prompt:"Enter Item Description", defaultValue:giftName, parent:self, completion: { (button:Int, text:String) -> Void in
            if button == UserPrompt.BUTTON_OK {
                People.changeGiftName(person:self.person!, oldName:self.giftName, newName:text)
                self.giftName = text
                People.saveChanges()
            }
        })
    }
    
    func setPurchasedImage() {
        purchasedButton.setImage(gift?.getPurchaseStatusIcon(), for:.normal)
    }
    
    
}
