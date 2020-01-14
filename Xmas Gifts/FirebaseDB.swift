//
//  FirebaseDB.swift
//  Xmas Gifts
//
//  Created by David Figge on 3/2/17.
//  Copyright © 2017 WildTangent. All rights reserved.
//
//  This class encapsulates the required elements to make use of the Firebase Database
//  Steps:
//    1) After incorporating the Firebase frameworks and such, include this file
//    2) Derive a data model class from FirebaseDBElement. Implement the init, save, and getKey methods
//    3) Create a FirebaseDB object for your data model. Call init passing in your root element
//    4) If you need to be aware of database changes, register and remove listeners as appropriate
//    5) You'll primarily use the [], add(), delete(), and save()

import Foundation
import FirebaseDatabase
import Firebase

// Any class that wants to be notified of changes in the database should implement this protocol. The onFirebaseDBChanged() will be
// called when database changes have occurred. This would be a time to clear and redisplay tableViews, etc.
protocol FirebaseDBListener {
    func onFirebaseDBChanged()  // Called when database indicates change in data
}

// Defines the base class for a data model supported by this file. The 3 methods -- init save, getKey -- must be overridden
public class FirebaseDBElement {
    public init() { }
    required public init (snapshot : DataSnapshot!) { }  // Create a new object based on data in the snapshot
    func save(databaseRef : DatabaseReference) {         // Save data from the model into the databaseRef reference
        fatalError("The FirebaseDBElement subclass must override the save(databaseRef:FIRDAtabaseReference, key:String) method")
    }
    func getKey() -> String! {                              // Provide the unique key for the record based on data in the model
        fatalError("The FirebaseDBElement subclass must override getKey()")
    }
}

// The main FirebaseDB class. Create a version of this using your FirebaseDBElement-derived model
// It is advised to have only one FirebaseDB object instantiated for each defined root path/key
public class FirebaseDB<T:FirebaseDBElement> {
    var rootPath : String! = nil                                // The root associated with this instance
    private var database : DatabaseReference! = nil          // The Firebase Database connection
    private var listeners = [String : FirebaseDBListener]()     // The list of active listeners waiting to be notified if the data has changed
    private var elements = [String:T!]()                        // The active list of database elements (refreshed as data changes)
    private var user : User! = nil                           // User auth token
    private var initialized = false                             // Set if database initialized (will wait for authentication to complete before opening)
    private var childElement : String! = nil                     // The child element to use for data access.
    
    // Return an element from the database via integer index
    subscript(index:Int) -> T! {
        get {
            if index < Count && index >= 0 {
                return elements[Keys[index]] as! T
            }
            return nil
        }
    }
    
    // Return an element from the database via a string key
    subscript(key:String) -> T! {
        get {
            if Keys.contains(key) {
                return elements[key]!
            }
            return nil
        }
        set(element) {  // Note this handles both saving and adding
            element.save(databaseRef: database.child(element.getKey()))
        }
    }
    
    public var User : User! {
        get { return user }
        set (user){
            self.user = user
            if !initialized {
                initialize()
            }
        }
    }
    
    // Return an array of the element keys
    public var Keys : [String] {
        get {
            return Array(elements.keys)
        }
    }
    
    public var RootReference : DatabaseReference {
        get { return Database.database().reference(withPath: rootPath) }
    }
    
    // Return an array of the elements themselves
    public var Elements : [T] {
        get {
            var list = [T]()
            for key in elements.keys {
                list.append(elements[key]!!)
            }
            return list
        }
    }
    
    // Return the count of active elements
    public var Count : Int {
        get { return elements.count }
    }
    
    // Initialize the object based on the root element
    public init(rootPath : String, child : String!) {
        self.rootPath = rootPath
        self.childElement = child
        let user = anonymousLogin()
        if user != nil {
            initialize()
        }
    }
    
    // Establish a connection to the Firebase Database based on the (instance variable) rootPath
    // This also establishes the observer, which gets called whenever the database contents change
    func initialize() {
        initialized = true
        if (database == nil) {
            if childElement == nil {
                database = RootReference
            } else {
                database = RootReference.child(Configuration.getSettingsData(createIfNeeded:true).DataKey)
            }
            database.observe(.value, with: { snapshot in
                var items = [String:T!]()
                for item in snapshot.children {
                    let key = (item as! DataSnapshot).key
                    let element = T(snapshot: item as! DataSnapshot)
                    items[key] = element
                }
                self.elements = items
                self.notifyListeners()
            })
        }
    }
    
   // Delete an existing element from the database
    func delete(element : T) {
        database.child(element.getKey()).removeValue()
    }
    
    // Register a listener for the database. This listener will get called when database changes occur
    func addListener(listener:FirebaseDBListener, className:String) {
        listeners[className] = listener
        listener.onFirebaseDBChanged()
    }
    
    // Remove a listener so they are no longer called when database chances occur
    func removeListener(className:String) {
        listeners.removeValue(forKey: className)
    }

    // Notify active listeners that data has changed. This is their cue to reset their data (instance data has already been updated)
    private func notifyListeners() {
        for listener in listeners {
            listener.value.onFirebaseDBChanged()
        }
    }
    
    // Retrieve a reference to the database referencing a specific element (or, of ommitted, the root)
    // This will establish a new key if it doesn't currently exist
    func databaseRef(forElement:T! = nil) -> DatabaseReference {
        return databaseRef(forKey: forElement.getKey())
    }
    
    // Retrieve a reference to the database for a speciic key
    // This will establish a new key if it doesn't currently exist
    func databaseRef(forKey:String) -> DatabaseReference {
        return database.child(forKey)
    }
    
    // Disconnect and reconnect the database. Useful for root key changes, etc.
    func reset() {
        database = nil
        initialize()
    }
    
    public func anonymousLogin() -> User! {
        if let userAuth = Auth.auth().currentUser {
            self.User = user
            return userAuth
        } else {
            Auth.auth().signInAnonymously(completion: { (result, error) in
                if error != nil {
                    NSLog("Authorization error: \(error!.localizedDescription)")
                }
                self.User = result?.user
            })
        }
        return nil
    }
    
}
