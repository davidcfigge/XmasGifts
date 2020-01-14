//
//  Gift.swift
//  Xmas List
//
//  Created by David Figge on 12/15/16.
//  Copyright © 2016 David Figge. All rights reserved.
//
//  Data model for a Gift
//  Gifts are owned by a Person object

import Foundation
import FirebaseDatabase
import UIKit

public class Gift : Comparable, Equatable {
    public enum PurchaseStatus : Int {
        case unpurchased = 0        // Blank circle
        case interested = 1         // Lightbulb
        case ordered = 2            // Shopping cart
        case shipped = 3            // Truck
        case received = 4           // Boxed Package
        case wrapped = 5            // Gift
        case packaged = 6           // Packaged
        case sent = 7               // Sent/mailed
        case complete = 8           // Done!
    }
    
    public let PurchaseStatusText = [
        "",
        "Interested",
        "Purchased",
        "Shipped",
        "Arrived",
        "Wrapped",
        "Packaged",
        "Mailed",
        "Complete"]
    
    private static let PurchaseStatusImages = [
        "checkbox-blank-circle-outline.png",        // Unpurchased
        "interested-circle.png",
        "purchased-circle.png",
        "shipped-circle.png",
        "arrived-circle.png",
        "wrapped-circle.png",
        "packaged-circle.png",
        "mailed-circle.png",
        "checkbox-marked-circle.png"
        ]
    
    // Keys for fields saved to the database
    private static let CATEGORY_KEY = "category"        // Definitions of the keys used to store data in the JSON
    private static let DESCRIPTION_KEY = "description"
    private static let STORE_KEY = "store"
    private static let PRICE_KEY = "price"
    private static let PURCHASED_KEY = "purchased"
    private static let PURCHASE_STATUS_KEY = "status"
    private static let IDENTIFIER_KEY = "identifier"
    
    // Everything but Item is optional
    private var item : String           // Item name (also the key)
    private var category : String       // Category
    private var description : String    // Description of item
    private var store : String          // The store to purchase from
    private var price : Int             // The best price so far
    private var identifier : String     // The package identifier
    private var purchaseStatus : PurchaseStatus // The purchase status of the item (from none to purchased to shipped to wrapped to complete
    private var purchased : Bool        // Set if already purchased
    private var changed : Bool          // Set if data within the gift has changed
    
    // This function (essential to read in the data) identifies the data stored in the JSON. Once retrieved, use value[key] to retrieve and cast the data from value
    func toAnyObject() -> Any {
        return [
            Gift.CATEGORY_KEY : category,
            Gift.DESCRIPTION_KEY : description,
            Gift.STORE_KEY : store,
            Gift.PRICE_KEY : price,
            Gift.PURCHASED_KEY : purchased,
            Gift.PURCHASE_STATUS_KEY : purchaseStatus.rawValue,
            Gift.IDENTIFIER_KEY : identifier
        ]
    }
    // Property definitions
    public var Category : String {
        get { return category }
        set(newValue) {
            if (newValue != category) {
                category = newValue
                changed = true
            }
        }
    }
    
    public var Item : String {
        get { return item }
    }
    public var Description : String {
        get { return description }
        set(newValue) {
            if (newValue != description) {
                description = newValue
                changed = true
            }
        }
    }
    
    public var Store : String {
        get { return store }
        set(newValue) {
            if (newValue != store) {
                store = newValue
                changed = true
            }
        }
    }
    
    public var Price : Int {
        get { return price }
        set(newValue) {
            if (newValue != price) {
                price = newValue
                changed = true
            }
        }
    }
    
    public var Identifier : String {
        get { return identifier }
        set(newValue) {
            if (newValue != identifier) {
                identifier = newValue
                changed = true
            }
        }
    }
    
    public var Status : PurchaseStatus {
        get { return purchaseStatus }
        set(newValue) {
            if (newValue != purchaseStatus) {
                purchaseStatus = newValue
                purchased = (newValue.rawValue <= PurchaseStatus.interested.rawValue) ? false : true
                changed = true
            }
        }
    }
    
    public var StatusDescription : String! {
        get { return PurchaseStatusText[purchaseStatus.rawValue] }
    }
    
    public var Purchased : Bool {
        get { return Status.rawValue >= PurchaseStatus.ordered.rawValue }
//        set(newValue) {
//            if (newValue != purchased) {
//                purchased = newValue
//                if purchased == true && purchaseStatus == PurchaseStatus.unpurchased {
//                    Status = PurchaseStatus.complete
//                } else {
//                    Status = PurchaseStatus.unpurchased
//                }
//                changed = true
//            }
//        }
    }
    
    
    public var IsChanged : Bool {
        get { return changed }
        set(value) {
            changed = value
        }
    }
    
    // Return the key used in the json for this item
    public func getKey() -> String {
        return item
    }
    
    public func nextStatus() -> PurchaseStatus {
        if Status == PurchaseStatus.complete {
            Status = PurchaseStatus.unpurchased
        } else {
            Status = PurchaseStatus(rawValue: Status.rawValue+1)!
        }
        return Status
    }
    
    // Given the specific data, initialize the gift object
    init(item:String="", category:String="", description:String="", store:String="", price:Int=0, identifier:String="", purchased:Bool=false, status:PurchaseStatus = PurchaseStatus.unpurchased) {
        var status = status
        self.item = item
        self.category = category
        self.description = description
        self.store = store
        self.price = price
        self.identifier = identifier
        self.purchased = purchased
        var newStatus = status
        if purchased == true && status == PurchaseStatus.unpurchased {
            newStatus = PurchaseStatus.ordered
        }
        self.purchaseStatus = newStatus
        changed = false
    }
    
    // Given a line entry (typically how the user inputs the data), initialize the object
    convenience init(oneLine:String) {
        let sp = StringProcessor(line: oneLine)
        var cat = ""                                        // Default category (none)
        if sp.firstDelimiter(delimiters: ":,") == ":" {     // If category specified,
            cat = sp.nextString(delimiter: ":,")            // Use it
        }
        let item = sp.nextString(delimiter: ",")            // Next is the item
        let desc = sp.nextString(delimiter: ",")            // Description
        let store = sp.nextString(delimiter: ",")           // Store
        let price = sp.nextString(delimiter: ",", defaultValue:"0.00")  // Price
        let purchased = sp.nextString(delimiter: ",", defaultValue:"false")     // Purchased
        self.init(item:item, category:cat, description:desc, store:store, price:DataUtils.getIntFromAmountString(amountString: price), identifier:"", purchased:purchased.lowercased() == "true" ? true : false)
    }
    
    // Read the data in from the database
    convenience init(snapshot: DataSnapshot, key:String) {
        let item = key                                          // Save the key in the Item field
        let value = snapshot.value as! [String: AnyObject]      // Read the data from the database
        var category = "";
        var description = "";
        var store = "";
        var price = 0;
        var identifier = "";
        var status = PurchaseStatus.unpurchased;
        var purchased = false;
        if value[Gift.CATEGORY_KEY] != nil { category = value[Gift.CATEGORY_KEY] as! String }      // Retrieve the category
        if value[Gift.DESCRIPTION_KEY] != nil { description = value[Gift.DESCRIPTION_KEY] as! String }    // Description
        if value[Gift.STORE_KEY] != nil { store = value[Gift.STORE_KEY] as! String }            // Store
        if value[Gift.PRICE_KEY] != nil { price = value[Gift.PRICE_KEY] as! Int }               // Price
        if value[Gift.IDENTIFIER_KEY] != nil { identifier = value[Gift.IDENTIFIER_KEY] as! String }        // Identifier
        if value[Gift.PURCHASED_KEY] != nil { purchased = value[Gift.PURCHASED_KEY] as! Bool }      // Purchased
        if value[Gift.PURCHASE_STATUS_KEY] != nil { status = PurchaseStatus.init(rawValue: value[Gift.PURCHASE_STATUS_KEY] as! Int)!}
        self.init(item:item, category:category, description:description, store:store, price:price, identifier:identifier, purchased:purchased, status:status)
    }
    
    // Return the item given the one line input string (without creating the object first)
    static func getGiftKey(oneLine : String) -> String {
        let sp = StringProcessor(line: oneLine)
        if sp.firstDelimiter(delimiters: ":,") == ":" { // If there's a category specified, skip it
            _ = sp.nextString(delimiter: ":")
        }
        
        let key = sp.nextString(delimiter: ",")     // Extract the next section as the item name (key)
        return key
    }
    
    // Return the appropriate icon based on if the item was purchased or not
    func getDefaultPurchaseIcon() -> UIImage {
        return UIImage(named:(purchased ? "checkbox-marked-circle.png" : "checkbox-blank-circle-outline.png"))!
    }
    
    func getPurchaseStatusIcon() -> UIImage {
        return UIImage(named:Gift.PurchaseStatusImages[Status.rawValue])!
    }
    
    // Save the gift object to the database
    func save(databaseRef: DatabaseReference) {
        databaseRef.setValue(toAnyObject())
    }
    
    // Save the data to the database only if the data has changed.
    func saveChanges(databaseRef: DatabaseReference) {
        if (changed) {
            save(databaseRef: databaseRef)
            changed = false
        }
    }
    
    public static func < (lhs:Gift, rhs: Gift) -> Bool {
        return lhs.category + ":" + lhs.item < rhs.category + ":" + rhs.item
//        if (lhs.category != rhs.category) {
//            return lhs.category < rhs.category
//        }
//        return lhs.item < rhs.item
    }
    
    public static func <= (lhs:Gift, rhs:Gift) -> Bool {
        return lhs == rhs || lhs < rhs
    }
    
    public static func > (lhs:Gift, rhs:Gift) -> Bool {
        return !(lhs <= rhs)
    }
    
    public static func >=(lhs:Gift, rhs:Gift) -> Bool {
        if lhs == rhs { return true }
        return !(lhs < rhs)
    }
    
    public static func ==(lhs:Gift, rhs:Gift) -> Bool {
        if lhs.category != rhs.category { return false }
        if lhs.description != rhs.description { return false }
        if lhs.store != rhs.store { return false }
        if lhs.price != rhs.price { return false }
        return true
    }
    
    public static func != (lhs:Gift, rhs:Gift) -> Bool {
        return !(lhs == rhs)
    }
}

