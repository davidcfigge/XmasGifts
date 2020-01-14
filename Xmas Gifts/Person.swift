//
//  Person.swift
//  Xmas List
//
//  Created by David Figge on 12/15/16.
//  Copyright © 2016 David Figge. All rights reserved.
//
//  Data model for the person.
//  Persons also have 0-many gifts

import Foundation
import FirebaseDatabase
import UIKit
import Contacts
import ContactsUI
import AddressBook
import AddressBookUI

public class Person : FirebaseDBElement {
    static let GIFT_KEY = "gifts"                       // Key for array of gifts
    private static let BUDGET_KEY = "budget"            // Key for budget amount
    private static let FIRSTNAME_KEY = "firstname"      // Key for first name of person
    private static let LASTNAME_KEY = "lastname"        // Key for last name of person
    private static let IDENTIFIER_KEY = "id"            // Person's ID. This may or may not directly link to contact on device (linked on initial "add user" device only)
    private static let HIDE_UNPURCHASED_KEY = "hideUnpurchased" // Key for boolean flag indicating hide/unhide unpurchased items in gift list
    private static let SORTKEY_KEY = "sortKey"          // Key for int value describing sorting logic for gift list
    
    private var id : String                             // Various holders for values associated with person
    private var firstname : String
    private var lastname : String
    private var budget : Int
    private var hideUnpurchased : Bool
    private var sortKey : Int
    private var changed : Bool                          // Set if any field has changed
    private var photo : UIImage!                        // The photo of the person from the contacts database
    private var gifts = [String:Gift]()                 // Dictionary of key:gifts array
    private var saveId = false                          // Set if we should save the ID with this record (pretty much original add only)
    
    // Required method of the FirebaseDBElement base class
    public override func getKey() -> String! {
        return FullName
    }
    
    // This function (essential to read in the data) identifies the data stored in the JSON. Once retrieved, use value[key] to retrieve and cast the data from value
    func toAnyObject() -> Any {
        return [
            Person.BUDGET_KEY : budget,
            Person.FIRSTNAME_KEY : firstname,
            Person.IDENTIFIER_KEY : id,
            Person.LASTNAME_KEY : lastname,
            Person.SORTKEY_KEY : sortKey,
            Person.HIDE_UNPURCHASED_KEY : hideUnpurchased,
        ]
    }
    
    // Property definitions
    public var FirstName : String {
        get { return firstname }
        set(value) {
            firstname = value
            changed = true
        }
    }
    
    public var LastName : String {
        get { return lastname }
        set(value) {
            lastname = value
            changed = true
        }
    }
    
    public var FullName : String {      // Calculated from first and last name
        get {
            if lastname == "" {
                return firstname
            }
            return lastname + " " + firstname
        }
    }
    
    public var Photo : UIImage! {
        get { return photo }
    }
    
    public var Budget : Int {
        get { return budget }
        set(newValue) {
            if (newValue != budget) {
                budget = newValue
                changed = true
            }
        }
    }
    
    public var SortKey : Int {
        get { return sortKey }
        set(newValue) {
            if (newValue != sortKey) {
                sortKey = newValue
                changed = true
            }
        }
    }
    
    public var HideUnpurchased : Bool {
        get { return hideUnpurchased }
        set(newValue) {
            if (newValue != hideUnpurchased) {
                hideUnpurchased = newValue
                changed = true
            }
        }
    }
    
    public var Id : String {
        get { return id }
        set(newId) {
            id = newId
            saveId = true
            changed = true
        }
    }
    
    public subscript(index:String) -> Gift! {
        get { return Gifts[index]! }
        set(gift) {
            Gifts[gift.getKey()] = gift
        }
    }
    
    public subscript(index:Int) -> Gift! {
        get {
            let keys = Array(Gifts.keys).sorted(by:<)
            if index >= keys.count {
                return nil
            }
            return gifts[keys[index]]
        }
    }
    public var Gifts : [String:Gift] {
        get { return gifts }
        set(newValue) {
            gifts = newValue
            changed = true
        }
    }
    
    public var IsChanged : Bool {
        get { return changed || giftsChanged() }
        set(value) {
            changed = value
            for key in gifts.keys {
                let gift = gifts[key]
                gift!.IsChanged = value
            }
        }
    }
    
    // Create a new object given core data elements required
    init(firstName:String, lastName:String, id:String!, budget:Int = 0, sortKey:Int = 1, hideUnpurchased:Bool = false) {
        self.id = id
        self.firstname = firstName
        self.lastname = lastName
        changed = false
        var contact:CNContact! = nil
        if id != nil && id != "" {
            // Try to get the contact by the ID
            contact = Person.getContactFromId(id: id)
        }
        if (contact == nil) {
            // See if we can find the contact by name
            contact = Person.getContactFromName(first: firstName, last: lastName)
            if contact != nil && (id == nil || id == "") {
                self.id = contact.identifier
                saveId = true
            }
        }
        if (contact != nil) {
            let data : Data! = contact?.thumbnailImageData as Data!
            if (data != nil) {
                photo = UIImage(data: data)
            } else {
                photo = nil
            }
        }
        self.budget = budget
        self.sortKey = sortKey
        self.hideUnpurchased = hideUnpurchased
        super.init()
    }
    
    // Create a new object based on the person's fullname
    convenience init(fullName:String, budget:Int = 0) {
        let sp = StringProcessor(line: fullName)
        let first = sp.nextString(delimiter: " ")
        let last = sp.nextString(delimiter: " ")
        self.init(firstName:first, lastName:last, id:"", budget:budget)
    }
    
    // Create a new object by retrieving data from the Firebase database reference
    required public convenience init(snapshot: DataSnapshot!) {
        let value = snapshot.value as! [String: AnyObject]          // Read the data into the value dictionary from the snapshot (based on the toAnyObject function below)
        let budget = value[Person.BUDGET_KEY] as! Int               // Get the budget from the values retrieved
        let firstName = value[Person.FIRSTNAME_KEY] as! String      // Get the first name from the values retrieved
        let lastName = value[Person.LASTNAME_KEY] as! String        // Get the last name from the values retrieved
        let sortKey = (value[Person.SORTKEY_KEY] == nil ? 2 : value[Person.SORTKEY_KEY] as! Int)              // Get the sortKey value
        let hideUnpurchased = (value[Person.HIDE_UNPURCHASED_KEY] == nil ? false : value[Person.HIDE_UNPURCHASED_KEY] as! Bool) // Get the hideUnpurchased key
        let identifier = value[Person.IDENTIFIER_KEY] as! String    // Get the identifier from the values retrieved
        self.init(firstName:firstName, lastName:lastName, id:identifier, budget:budget, sortKey:sortKey, hideUnpurchased:hideUnpurchased) // Store these in to the instance and initialize stuff
        let giftsSnapshot = snapshot.childSnapshot(forPath: Person.GIFT_KEY)    // Now do the same thing for the various gifts
        for giftSnapshot in giftsSnapshot.children {                // For each gift (snapshot)
            let giftKey = (giftSnapshot as! DataSnapshot).key    // Get the key for the gift
            gifts[giftKey] = Gift(snapshot:giftSnapshot as! DataSnapshot, key:giftKey)   // Instantiate the gift object
        }
    }
    
    // Calculate how much money has currently been spent on gifts
    func spent() -> Int {
        var spent = 0
        for key in gifts.keys {
            let gift = gifts[key]
            if (gift?.Purchased)! {
                spent += (gift?.Price)!
            }
        }
        return spent
    }

    // Change the key (item name) of a gift
    func changeKey(database:DatabaseReference, originalKey: String, newKey: String) {
        let gift = self[originalKey]
        let giftDbRef = database.child(Person.GIFT_KEY)
        giftDbRef.child(originalKey).removeValue()
        gift!.save(databaseRef:giftDbRef.child(newKey))
    }
    
    // Delete an entire gift
    func deleteGift(database:DatabaseReference, key:String) {
        let giftDbRef = database.child(Person.GIFT_KEY)
        giftDbRef.child(key).removeValue()
    }
    
    // Save the data
    public override func save(databaseRef : DatabaseReference!) {
        let key = getKey()
        databaseRef.setValue(toAnyObject())
        let giftsRef = databaseRef.child(key!).child(Person.GIFT_KEY)
        for key in gifts.keys {
            gifts[key]?.save(databaseRef:giftsRef.child(key))
        }
    }
    
    // Save data if changes have occurred
    func saveChanges(databaseRef: DatabaseReference) {
        if (changed) {
            let budgetRef = databaseRef.child(Person.BUDGET_KEY)
            budgetRef.setValue(budget)
            let firstNameRef = databaseRef.child(Person.FIRSTNAME_KEY)
            firstNameRef.setValue(firstname)
            let lastNameRef = databaseRef.child(Person.LASTNAME_KEY)
            lastNameRef.setValue(lastname)
            let sortKeyRef = databaseRef.child(Person.SORTKEY_KEY)
            sortKeyRef.setValue(sortKey)
            let hideUnpurchasedRef = databaseRef.child(Person.HIDE_UNPURCHASED_KEY)
            hideUnpurchasedRef.setValue(hideUnpurchased)
            if saveId {
                let idRef = databaseRef.child(Person.IDENTIFIER_KEY)
                idRef.setValue(id)
            }
            changed = false
            saveId = false
        }
        if (giftsChanged()) {
            let giftsRef = databaseRef.child(Person.GIFT_KEY)
            for key in gifts.keys {
                gifts[key]!.saveChanges(databaseRef:giftsRef.child(key))
            }
        }
    }
    
    // Return true if any of the gift objects have changed
    func giftsChanged() -> Bool {
        for key in gifts.keys {
            if (gifts[key]!.IsChanged) {
                return true
            }
        }
        return false
    }
    
    // Calculate how much budget is remaining for this person
    func getBudgetRemaining() -> Int {
        var remaining = budget
        for key in gifts.keys {
            let gift = gifts[key]
            if (gift!.Purchased) {
                remaining -= gift!.Price
            }
        }
        return remaining
    }
    
    // Given a name, retrieve a contact from the Contacts database
    static func getContactFromName(first:String, last:String) -> CNContact! {
        let store = CNContactStore()
        do {
            let predicate = CNContact.predicateForContacts(matchingName: first + " " + last)
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactThumbnailImageDataKey] as [Any]
            
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            if contacts.count == 0 {
                return nil
            }
            return contacts[0]
        } catch {
            return nil
        }
    }
    
    // Given an ID, retrieve a contact from the Contacts database
    static func getContactFromId(id : String) -> CNContact! {
        let store = CNContactStore()
        do {
            let predicate = CNContact.predicateForContacts(withIdentifiers: [id])
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactThumbnailImageDataKey] as [Any]
            
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            if contacts.count == 0 {
                return nil
            }
            return contacts[0]
        } catch {
            return nil
        }
    }
        
}
