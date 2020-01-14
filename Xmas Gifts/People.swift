//
//  People.swift
//  Xmas Gifts
//
//  Created by David Figge on 3/2/17.
//  Copyright © 2017 WildTangent. All rights reserved.
//
//  This class provides a (singleton, static) interface into the Firebase database associate with this application
//  Much of what this class provides is a static wrapper around instance methods of the FirebaseDB class
//  There are also some specific methods for common Person/Gift oriented tasks from the higher Database level

import Foundation
import FirebaseDatabase

class People : FirebaseDB<Person>  {
    static let ROOT_PATH = "xmas-list-items"
    private static var database : FirebaseDB<Person>! = nil
    
    private init() {
        super.init(rootPath: People.ROOT_PATH, child:Configuration.getSettingsData(createIfNeeded:true).DataKey)
//    createInitialData()       // Create test data
    }
    
    // Call this method to initialize the (singleton) connection to the database data
    // Calling multiple times will not impact, as only the first call instantiates the instance reference
    static func initialize() {
        if database == nil {
            database = People()
        }
    }
    
    // Add a listener so a class can be notified of database changes
    static func addListener(listener: FirebaseDBListener, className: String) {
        database.addListener(listener: listener, className: className)
    }
    
    // Remove a listener so the class is no longer notified of database changes
    static func removeListener(className: String) {
        database.removeListener(className: className)
    }
    
    // Reset the database connection. Useful for times when the root data key has changed
    static func reset() {
        database.reset()
    }
    
    // Get the list of active keys
    static var keys : [String] {
        get {
            return database.Keys
        }
    }
    
    // Get the number of person records active
    static var Count : Int {
        get { return database.Count }
    }
    
    static var Entries : FirebaseDB<Person>! {
        get { return database }
    }
    
    // Add a new person record
    static func addPerson(person: Person) {
        person.IsChanged = true
        database[person.getKey()] = person
    }
    
    // Delete an existing person record
    static func deletePerson(person: Person) {
        database.delete(element:person)
    }
    
    // Save changes that have occurred.
    // This only saves records that have been modified
    static func saveChanges() {
        for key in database.Keys {
            database[key].saveChanges(databaseRef: database.databaseRef(forKey:key))
        }
    }
    
    // Change the name of the gift
    // This is a little tricky because the name of the gift is also the key for that gift.
    static func changeGiftName(person : Person, oldName: String, newName: String) {
        person.changeKey(database: database.databaseRef(forElement: person),originalKey: oldName,newKey: newName)
    }
    
    // Delete the specified gift for the specified person
    static func deleteGift(person: Person, giftName: String) {
        person.deleteGift(database: database.databaseRef(forElement:person), key: giftName)
    }
        
    // Create initial test data
    static private func createInitialData() {
        //var names : Array<String> = [ "Anne", "Ellen", "Melissa", "Evan", "Emma"]
        var names : Array<String> = [
            "Anne Figge", // Anne
            "Ellen Martin", // Ellen
            "Melissa Figge", // Melissa
            "Evan Figge", //Evan
            "Emma Martin"  // Emma
            
//            "John Appleseed", // John Appleseed
//            "Kate Bell",  // Kate Bell
//            "Anna Haro",  // Anna Haro
//            "Daniel Higgins",  // Daniel Higgins
//            "David Taylor" // David Taylor
            //            "9E3E5A5F-C64A-41BC-BB26-2E9B376E430A" // Hank Zakroff
            
        ]
        
        var people = [String : Person]()
        
        people[names[0]] = Person(fullName:names[0], budget:35000)
        people[names[1]] = Person(fullName:names[1], budget:20000)
        people[names[2]] = Person(fullName:names[2], budget:20000)
        people[names[3]] = Person(fullName:names[3], budget:20000)
        people[names[4]] = Person(fullName:names[4], budget:10000)
        
        //        initNames(array: &people)
        // Anne's gifts
        var gifts = [Gift]()
        
        gifts.append(Gift(oneLine: "CDs:Judy Collins, Judy Collins Best Hits,Amazon,10.95"))
        gifts.append(Gift(oneLine: "Purse,White dress purse, TJMaxx, 28.00, true"))
        gifts.append(Gift(oneLine: "Kitchen:Grinder,Meat Grinder,Macy's,37.95"))
        gifts.append(Gift(oneLine: "Cruise Souvineer, Buy something on the cruise,,300"))
        gifts.append(Gift(oneLine: "CDs:Joan Baez, Essential Joan Baez, Amazon, 10.95"))
        gifts.append(Gift(oneLine: "CDs:Joni MItchell, Bridges, Amazon, 7.95, true"))
        gifts.append(Gift(oneLine: "CDs:Jim Croce, Photographs and Memories, Amazon, 6.95"))
        gifts.append(Gift(oneLine: "Kitchen:Pot Holders, A pair of pot holders, Sur La Table, 20.00"))
        gifts.append(Gift(oneLine: "Scarf, Wool or blend, Amazon, 20.00"))
        gifts.append(Gift(oneLine: "FitBit Charge 2, Black, Amazon, 150, true"))
        gifts.append(Gift(oneLine: "DVDs:Kudos and the 2 Strings,,Amazon,10.95"))
        
        // Append gifts on to Anne's record
        for gift in gifts {
            people[names[0]]?[gift.getKey()] = gift
        }
        
        // Ellen's gifts
        gifts = [Gift]()
        
        gifts.append(Gift(oneLine: "Bath:Hair Dryer, High heat, Amazon, 15.95, true"))
        gifts.append(Gift(oneLine: "Pete's Coffee, 1 Pound, Pete's, 12.95"))
        gifts.append(Gift(oneLine: "Kitchen:Mixing Bowl, Stainless Steel, Macy's, 18.95, true"))
        gifts.append(Gift(oneLine: "Universal Remote, Sanyo, Best Buy, 35.95"))
        gifts.append(Gift(oneLine: "Living Room:Ottoman, White with storage, Breenbaums, 185"))
        
        // Append gifts on to Ellen's record
        for gift in gifts {
            people[names[1]]?[gift.getKey()] = gift
        }

        // Melissa's gifts
        gifts = [Gift]()
        
        gifts.append(Gift(oneLine: "Check,,,200"))
        gifts.append(Gift(oneLine: "Harry Potter and the Chamber of Secrets,Illustrated Version,Powell's,19.95,true"))
        gifts.append(Gift(oneLine: "Bedroom:Electric Blanket,Queen size, Fred Meyer, 60"))
        
        // Append gifts on to Melissa's record
        for gift in gifts {
            people[names[2]]?[gift.getKey()] = gift
        }

        // Evan's gifts
        gifts = [Gift]()
        
        gifts.append(Gift(oneLine: "Scarf,Gray,,28.75,true"))
        gifts.append(Gift(oneLine: "Coat,Weather proof size XXL,Big and Tall,127.95"))
        gifts.append(Gift(oneLine: "Belt,42 inches,Big and Tall,15.95,true"))
        
        // Append gifts on to Evan's record
        for gift in gifts {
            people[names[3]]?[gift.getKey()] = gift
        }

        // Emma's gifts
        gifts = [Gift]()
        
        gifts.append(Gift(oneLine: "Toy:Code-a-Pillar,,Amazon,19.95"))
        gifts.append(Gift(oneLine: "Toy:B Snug Bugs,,Amazon,10.95,true"))
        gifts.append(Gift(oneLine: "Toy:Color Flashlight, Red and Blue, Amazon, 9.95"))
        gifts.append(Gift(oneLine: "Toy:Chunky Pegs,,Amazon,12.95,true"))
        gifts.append(Gift(oneLine: "Water Bottle,Red with straw,Amazon,14.95,true"))
        gifts.append(Gift(oneLine: "Car Seat,Cosco model CR-224,Toys R Us,185"))
        
        // Append gifts on to Emma's record
        for gift in gifts {
            people[names[4]]?[gift.getKey()] = gift
        }

        
//        people[names[0]]?.Gifts["Judy Collins"] = Gift(item:"Judy Collins",category:"CDs", description:"Judy Collins Best Hits", store:"Amazon", price:1095, purchased:false)
//        people[names[0]]?.Gifts["Purse"] = Gift(item:"Purse",category:"", description:"White dress purse", store:"TJMaxx", price:2800, purchased:true)
//        people[names[0]]?.Gifts["Grinder"] = Gift(item:"Grinder",category:"Kitchen", description:"Meat Grinder", store:"Macy's", price:3795, purchased:false)
//        people[names[0]]?.Gifts["Cruise Souvineer"] = Gift(item:"Cruise Souvineer",category:"", description:"Buy something on the cruise", store:"", price:30000, purchased:false)
//        people[names[0]]?.Gifts["Joan Baez"] = Gift(item:"Joan Baez",category:"CDs", description:"Essential Joan Baez", store:"Amazon", price:1095, purchased:false)
//        people[names[0]]?.Gifts["Joni Mitchell"] = Gift(item:"Joni Mitchell",category:"CDs", description:"Bridges", store:"Amazon", price:795, purchased:true)
//        people[names[0]]?.Gifts["Jim Croce"] = Gift(item:"Jim Croce",category:"CDs", description:"Photographs and Memories", store:"Amazon", price:695, purchased:false)
//        people[names[0]]?.Gifts["Pot Holders"] = Gift(item:"Pot Holders",category:"Kitchen", description:"A pair of pot holders", store:"Sur La Table", price:2000, purchased:true)
//        people[names[0]]?.Gifts["Scarf"] = Gift(item:"Scarf",category:"", description:"Wool or blend", store:"Amazon", price:2000, purchased:false)
//        people[names[0]]?.Gifts["FitBit Charge 2"] = Gift(item:"FitBit Charge 2",category:"", description:"Black", store:"Amazon", price:15000, purchased:true)
//        people[names[0]]?.Gifts["Kudos and the 2 Strings"] = Gift(item:"Kudos and the 2 Strings",category:"DVDs", description:"", store:"Amazon", price:1095, purchased:false)
//        
//        // Ellen
//        people[names[1]]?.Gifts["Hair Dryer"] = Gift(item:"Hair Dryer",category:"Bath", description:"High heat", store:"Amazon", price:1595, purchased:true)
//        people[names[1]]?.Gifts["Pete's Coffee"] = Gift(item:"Pete's Coffee",category:"", description:"1 Pound", store:"Pete's", price:1295, purchased:false)
//        people[names[1]]?.Gifts["Mixing bowl"] = Gift(item:"Mixing bowl",category:"Kitchen", description:"Stainless Steel", store:"Macy's", price:1895, purchased:true)
//        people[names[1]]?.Gifts["Universal Remote"] = Gift(item:"Universal Remote",category:"", description:"Sanyo", store:"Best Buy", price:3595, purchased:false)
//        people[names[1]]?.Gifts["Ottoman"] = Gift(item:"Ottoman",category:"Living Room", description:"White with storage", store:"Greebaums", price:18500, purchased:false)
//        
//        // Melissa
//        people[names[2]]?.Gifts["Check"] = Gift(item:"Check",category:"", description:"", store:"", price:20000, purchased:false)
//        people[names[2]]?.Gifts["Harry Potter and the Chamber of Secrets"] = Gift(item:"Harry Potter and the Chamber of Secrets",category:"", description:"Illustrated Version", store:"Powell's", price:1995, purchased:true)
//        people[names[2]]?.Gifts["Electric Blanket"] = Gift(item:"Electric Blanket",category:"Bedroom", description:"Queen size", store:"Fred Meyer", price:6000, purchased:false)
//        
//        // Evan
//        people[names[3]]?.Gifts["Scarf"] = Gift(item:"Scarf",category:"", description:"Gray", store:"", price:2875, purchased:true)
//        people[names[3]]?.Gifts["Coat"] = Gift(item:"Coat",category:"", description:"Weather proof size XXL", store:"Big and Tall", price:12795, purchased:false)
//        people[names[3]]?.Gifts["Belt"] = Gift(item:"Belt",category:"", description:"42 inches", store:"Big and Tall", price:1595, purchased:true)
//        
//        // Emma
//        people[names[4]]?.Gifts["Code-a-Pillar"] = Gift(item:"Code-a-Pillar",category:"Toy", description:"", store:"Amazon", price:1995, purchased:false)
//        people[names[4]]?.Gifts["B Snug Bugs"] = Gift(item:"B Snug Bugs",category:"Toy", description:"", store:"Amazon", price:1095, purchased:true)
//        people[names[4]]?.Gifts["Color Flashlight"] = Gift(item:"Color Flashlight",category:"Toy", description:"Red and Blue", store:"Amazon", price:995, purchased:false)
//        people[names[4]]?.Gifts["Chunky Pegs"] = Gift(item:"Chunky Pegs",category:"Toy", description:"", store:"Amazon", price:1295, purchased:true)
//        people[names[4]]?.Gifts["Water Bottle"] = Gift(item:"Water Bottle",category:"", description:"Red with straw", store:"Amazon", price:1495, purchased:true)
//        people[names[4]]?.Gifts["Car Seat"] = Gift(item:"Car Seat",category:"", description:"Cosco model CR-224", store:"Toys R Us", price:18500, purchased:false)
        
        // Save records into database
        for name in people.keys {
            database[name] = people[name]
        }
        
    }
}
