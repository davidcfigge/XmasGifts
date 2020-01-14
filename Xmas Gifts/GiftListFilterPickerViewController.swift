//
//  GiftListFilterPickerViewController.swift
//  Xmas Gifts
//
//  Created by David Figge on 1/11/18.
//  Copyright © 2018 WildTangent. All rights reserved.
//

import UIKit

class GiftListFilterPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var selectedFilter = 0;
    var hideUnpurchased = false;
    var finishClosure : ((Int,Bool)->Void)? = nil
    
    @IBOutlet weak var hideUnpurchasedButton: UIButton!
    @IBOutlet weak var filterPicker: UIPickerView!
    
    let pickerData = [
        GiftListFilter.descriptions
    ]
    
    public func setFilterAndSwitch(filterSetting:Int, hideSwitch:Bool, onFinish:@escaping (Int, Bool)->Void) {
        selectedFilter = filterSetting
        hideUnpurchased = hideSwitch
        finishClosure = onFinish
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        finishClosure?(selectedFilter, hideUnpurchased)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onHideUnpurchasedItems(_ sender: Any) {
        hideUnpurchased = !hideUnpurchased
        hideUnpurchasedButton.setImage(getHideUnpurchasedImage(), for:.normal)
    }
 
    func getHideUnpurchasedImage() -> UIImage {
        return UIImage(named:(hideUnpurchased ? "checkbox-marked-circle.png" : "checkbox-blank-circle-outline.png"))!
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filterPicker.selectRow(selectedFilter, inComponent: 0, animated: false)
        hideUnpurchasedButton.setImage(getHideUnpurchasedImage(), for: .normal)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count;
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pickerData[component][row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFilter = row
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string:pickerData[component][row], attributes:[NSAttributedStringKey.foregroundColor:UIColor.white])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
