//
//  GiftListViewController.swift
//  Xmas List
//
//  Created by David Figge on 12/1/16.
//
//  This class displays a list of gift options for the specified user (set in person by MasterView before displaying)

import UIKit

class GiftListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FirebaseDBListener, AuthenticationDelegate, DismissSubviewDelegate {
    let CLASS_NAME = "GiftListViewController" // Unique identifier for FirebaseDBListener
    let cellReuseIdentifier = "giftCell"
    let nameLabelTag = 201                    // We have 4 items in our cell. Name, description, price, purchased (check)
    let descriptLabelTag = 202
    let priceLabelTag = 203
    let checkButtonTag = 204
    let pieChart = PieChart()               // PieChart object manages data and draws the pie chart
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var summaryLabel : UILabel!
    @IBOutlet weak var pieChartHost : UIView!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var menuButton : UIButton!
    @IBOutlet weak var settingsButton : UIButton!
    @IBOutlet weak var deleteButton : UIButton!
    @IBOutlet weak var plusButton : UIButton!
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var purchasedItemsLabel : UILabel!
    
    var selectedName : String! = nil
    var person : Person! = nil
    var selectedItem : Gift! = nil
    var selectedKey : String! = nil // Key to selected gift
    var isMenuOpen = false
    var sorter = Sorter()
    var currentlySortedBy : GiftListFilter.types = GiftListFilter.types.categoryAndItem

    func onFirebaseDBChanged() {
        updateDisplay()
    }
    
    // Called to update the display, typically at start and if data changes
    func updateDisplay() {
        let collapsed = !splitViewController!.isCollapsed
        backButton.isHidden = collapsed     // If in collapsed mode, don't display the back button
        if selectedName == nil {        // selectedName will be nil if on iPad (detail view always visibile)
            nameLabel.isHidden = true
            summaryLabel.isHidden = true
            purchasedItemsLabel.isHidden = true
            menuButton.isHidden = true
            return
        }
        // We have data to show!
        nameLabel.isHidden = false
        summaryLabel.isHidden = false
        purchasedItemsLabel.isHidden = false
        menuButton.isHidden = false
        person = People.Entries[selectedName]
        if person == nil {
            return
        }
        currentlySortedBy = GiftListFilter.types(rawValue:person!.SortKey)!
        nameLabel.text = person!.FirstName
        let picture = person!.Photo
        if (picture != nil) {
            imageView.image = picture               // Display the picture from Contacts
            imageView.layer.borderWidth=1.0         // This code displays it in a circle
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.clear.cgColor
            imageView.layer.cornerRadius = 13
            imageView.layer.cornerRadius = imageView.frame.size.height/2
            imageView.clipsToBounds = true
        }
        summaryLabel.text = DataUtils.getSummaryString(person:person)
        updatePieChart()
        pieChart.show(host:pieChartHost)
        updateSorting(type: currentlySortedBy)
        tableView.reloadData()
    }
    
    // Called when we need to force a re-login
    public func presentAuthenticationViewController() {
        performSegue(withIdentifier: "Gifts2Login", sender: self)
    }
    
    // Called when going into background. Get back to primary views.
    public func dismissSubviews() {
        if presentedViewController != nil && presentedViewController is DismissSubviewDelegate {
            let controller = presentedViewController as! DismissSubviewDelegate
            controller.dismissSubviews()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        People.addListener(listener: self, className: CLASS_NAME)
        updateDisplay()
    }
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
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
        case "GiftList2Gift" :
            let destination = segue.destination as! GiftDetailsViewController
            destination.giftName = selectedKey
            destination.personName = selectedName
            break;
        case "GiftList2FilterPicker":
            let destination = segue.destination as! GiftListFilterPickerViewController
            destination.setFilterAndSwitch(filterSetting: currentlySortedBy.rawValue, hideSwitch: person!.HideUnpurchased, onFinish: { (sortBy, hideUnpurchased) in
                let newDisplay = GiftListFilter.types(rawValue:sortBy)!
                if newDisplay != self.currentlySortedBy || hideUnpurchased != self.person!.HideUnpurchased {
                    self.person!.HideUnpurchased = hideUnpurchased
                    self.person!.SortKey = sortBy
                    self.currentlySortedBy = GiftListFilter.types(rawValue:sortBy)!
                    People.saveChanges()
                    self.updateSorting(type: self.currentlySortedBy)
               }
                self.tableView.reloadData();
            })
        default:
            break;
        }
    }
    
    func updatePieChart() {
        pieChart.reset()
        for key in person.Gifts.keys {
            let gift = person.Gifts[key]
            if (gift!.Purchased) {
                pieChart.addSegment(title:key, value:CGFloat(DataUtils.getDollarInt(amount:gift!.Price)))
            }
        }
        pieChart.addSegment(title:"Remaining", value:CGFloat(DataUtils.getDollarInt(amount:person.getBudgetRemaining())), color:UIColor.lightGray)
    }
    
    func updateSorting() {
        updateSorting(type: currentlySortedBy)
    }
    func updateSorting(type : GiftListFilter.types) {
        sorter = Sorter(
            retrieveDataObject: { (index) -> Any? in
                if index > person!.Gifts.count { return nil }
                return person![index]
        }, extractKeyFromDataObject: { (giftObject) -> (String?,String?) in
            let gift = giftObject as! Gift
            if !gift.Purchased && person!.HideUnpurchased { return (nil, nil) }
            switch type {
            case .categoryAndItem:
                return (gift.Item, gift.Category + ":" + gift.Item)
            case .store:
                return (gift.Item, gift.Store + ":" + gift.Item)
            case .status:
                return (gift.Item, String(gift.Status.rawValue) + ":" + gift.Item)
            case .packageId:
                return (gift.Item, gift.Identifier + ":" + gift.Item)
            case .item:
                fallthrough
            default:
                return (gift.Item, gift.Item)
            }
        })
    }
    
    // Open the menu if it isn't already open
    func openMenu() {
        if !isMenuOpen {
            onMenu()
        }
    }
    
    // Close the menu if it isn't already closed
    func closeMenu() {
        if isMenuOpen {
            onMenu()
        }
    }
    
    // User clicked on the menu
    @IBAction func onMenu() {
        isMenuOpen = !isMenuOpen
        let buttonsHidden = isMenuOpen ? false : true
        settingsButton.isHidden = buttonsHidden
        plusButton.isHidden = buttonsHidden
        deleteButton.isHidden = buttonsHidden
        filterButton.isHidden = buttonsHidden
        menuButton.setImage(getMenuImage(), for: UIControlState.normal)
    }
    
    // Return the appropriate menu image based on the menu state
    func getMenuImage() -> UIImage! {
        if isMenuOpen {
            return UIImage(named: "close-circle")
        }
        return UIImage(named: "menu-circle")
    }
    
    // User clicked on the back button
    @IBAction func onBackClick() {
        People.saveChanges()
        person = nil
        navigationController!.navigationController!.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFilter(_ sender: Any) {
        closeMenu()
        performSegue(withIdentifier: "GiftList2FilterPicker", sender: self)
    }
    // User clicked on the settings button
    @IBAction func onEdit() {
        closeMenu()
        _ = UserPrompt(prompt:"Enter Budget Amount", defaultValue:DataUtils.getEditableDollarCentString(amount:person!.Budget), parent:self, completion: { (button:Int, text:String) -> Void in
            if button == UserPrompt.BUTTON_OK {
                self.person!.Budget = DataUtils.getIntFromAmountString(amountString: text)
                People.saveChanges()
                
            }
        }, keyboard:UIKeyboardType.decimalPad)
    }
    
    // User clicked on the Purchased button (in the cell)
    @IBAction func purchasedButtonClick(_ sender: Any) {
        var indexPath: NSIndexPath!
        
        let button : UIButton = (sender as? UIButton)!
        if let superview = button.superview {
            if let cell = superview.superview as? UITableViewCell {
                indexPath = tableView.indexPath(for: cell) as NSIndexPath! // Get the index of the currently selected cell
            }
        }
        if indexPath != nil {
            let giftKey = sorter.keyFromIndex(index: indexPath.row)
            let gift = person[giftKey!]      // This is the record in the cell
            _ = gift?.nextStatus()
            People.saveChanges()                                        // Save the changes. This will cause the table (and the rest of the view) to be redisplayed
        }
    }
    
    @IBAction func onDelete() {
        closeMenu()
        _ = SelectionPrompt(title:"Delete", prompt: "Delete all gifts or remove person?", button1: "Cancel", button2: "Delete All Gifts", button3: "Remove Person and Gifts", parent: self, completion: { (button:Int) -> Void in
            if button == SelectionPromptViewController.BUTTON_2 {
                self.deleteAllGifts()
                return
            }
            if button == SelectionPromptViewController.BUTTON_3 {
                People.removeListener(className: self.CLASS_NAME)
                self.navigationController!.navigationController!.popToRootViewController(animated: true)
                self.dismiss(animated: false, completion: nil)
                People.deletePerson(person:self.person)
            }
            })
    }
    
    @IBAction func onAddGift() {
        closeMenu()
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
        let multiGiftInputViewController = MultiGiftInputViewController()
        multiGiftInputViewController.setOnCompletion(newValue: { (giftList : [String]) -> Void in
            for line in giftList {
                if line.count == 0 {
                    continue
                }
                let key = Gift.getGiftKey(oneLine: line)
                let gift = Gift(oneLine: line)
                if gift.getKey().count == 0 {
                    continue
                }
                gift.IsChanged = true
                self.person!.Gifts[key] = gift
            }
            People.saveChanges()
        })
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        present(multiGiftInputViewController, animated: true, completion: nil)
    }
    
    // Remove all the gifts for this person
    func deleteAllGifts() {
        for gift in person.Gifts {
            People.deleteGift(person:person, giftName:gift.key)
        }
        person.HideUnpurchased = false
        People.saveChanges()
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if person == nil {
            return 0
        }
        return sorter.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier))!
        
        // set the text from the data
        let dataIndex = indexPath.row
        let nameLabel = cell.viewWithTag(nameLabelTag) as! UILabel
        let summaryLabel = cell.viewWithTag(descriptLabelTag) as! UILabel
        let priceLabel = cell.viewWithTag(priceLabelTag) as! UILabel
        let purchasedButton = cell.viewWithTag(checkButtonTag) as! UIButton
        //let gift = person[dataIndex]
        let giftkey = sorter.keyFromIndex(index: dataIndex)
        let gift = person[giftkey!]
        let category = (gift?.Category.count)! > 0 ? (gift?.Category)! + ": " : ""
        let identifier = (self.currentlySortedBy == .packageId && (gift?.Identifier.count)! > 0) ? "(" + (gift?.Identifier)! + ") " : ""
        let item = (gift?.Item)!
        nameLabel.text = identifier + category + item
        nameLabel.textColor = pieChart.getSegmentColor(title:item)
        summaryLabel.text = gift?.Description
        priceLabel.text = DataUtils.getDollarCentString(amount: (gift?.Price)!)
        purchasedButton.setImage(gift?.getPurchaseStatusIcon(), for:.normal)
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        closeMenu()
        selectedKey = sorter.keyFromIndex(index: indexPath.row)
        selectedItem = person[selectedKey]
//        selectedKey = People.Entries[selectedName][indexPath.row].getKey()
//        selectedItem = People.Entries[selectedName][indexPath.row]
        performSegue(withIdentifier: "GiftList2Gift", sender: self)
    }
    
}
