//
//  Configuration.swift
//  Xmas List
//
//  Created by David Figge on 12/16/16.
//  Copyright © 2016 David Figge. All rights reserved.
//
//  This class encapsulates the configuration settings for the application
//  It projects a Settings (singleton) object to the programmer, which is the primary interface for configuration items
//  This settings object automatically loads and saves data when needed

import Foundation
import UIKit
import CoreData
import LocalAuthentication

class Configuration: NSObject {
    // Available search engines
    static let AMAZON_SEARCH_ENGINE_KEY = "Amazon"
    static let GOOGLE_SEARCH_ENGINE_KEY = "Google"
    static let DEFAULT_SEARCH_ENGINE_KEY = AMAZON_SEARCH_ENGINE_KEY     // Use this key if none set by the user
    
    // Core Data constants
    static let DATABASE_NAME = "XmasData"
    static let ENTITY_NAME = "Settings"
    static let PASSWORD_KEY = "usePassword"
    static let DATA_KEY = "dataKey"
    static let SEARCH_KEY = "searchEngine"
    static var settingsDatabase = [NSManagedObject]()
    
    // The userID, which is the key to the JSON data from the database. Defaults to owner's name
    private static let userId = getOwnerName()

    // Retrieve the owner's name from the device configuration
    static func getOwnerName() -> String {
        let fullName = UIDevice.current.name                                        // This is in the form of "David's iPhone", or something similar
        let stringProcessor = StringProcessor(line: fullName)
        let name = stringProcessor.nextString(delimiter: "'- ,.?/!@#$%^&*_=+")      // Stop at any character that might possibly be at the end of someone's name
        return name.lowercased()                                                    // Return the value. This is not guaranteed to be perfect, but should return some usable value
    }
    
    // Retrieve the settings data from core data, putting it into a new Settings object. If the data record isn't there (e.g. first run), default the data if createIfNeeded is true
    static func getSettingsData(createIfNeeded:Bool = false) -> Settings! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate                 // Get the appDelegate
        let managedContext = appDelegate.persistentContainer.viewContext                // From there, get the viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:ENTITY_NAME)      // Try to retrieve the data
        do {
            settingsDatabase = try managedContext.fetch(fetchRequest)                   // Fetch the records
            let settings = settingsDatabase.first                                       // Try to read in the first Settings record
            if settings == nil {                                                        // If not found, either create a default Settings object or return nil
                if createIfNeeded {
                    return DefaultSettings
                }
                return nil  // Don't create if not there
            }
            // Data retrieved. Create a new Settings object with retrieved information
            return Settings(requirePassword: settings?.value(forKey: PASSWORD_KEY) as! Bool, dataKey: settings?.value(forKey: DATA_KEY) as! String, searchEngine:settings?.value(forKey: SEARCH_KEY) as! String)
        } catch let error as NSError {
            NSLog("Unable to fetch from " + ENTITY_NAME + ": \(error)")
        }
        if createIfNeeded {         // If an exception occurred and still wanted default values, create and return it
            return DefaultSettings
        }
        return nil                  // An error occurred (and createIfNeeded = false)
    }
    
    // Determine if this device supports TouchID or not
    public static func supportsTouchId() -> Bool {
        var error:NSError?
        
        let authenticationContext = LAContext()
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        return true

    }
    
    // Create a new Settings object with default values
    public static var DefaultSettings : Settings {
        get { return Settings(
            requirePassword: false,
            dataKey: Configuration.getOwnerName(),
            searchEngine: Configuration.DEFAULT_SEARCH_ENGINE_KEY)
        }
    }
    
    // Save the settings to core data
    static func saveSettingsData(settings:Settings) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate                     // Get the appDelegate
        let managedContext = appDelegate.persistentContainer.viewContext                    // Get the ViewContext from the AppDelegate
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:ENTITY_NAME)
        var settingsRecord : NSManagedObject! = nil
        do {
            settingsDatabase = try managedContext.fetch(fetchRequest)                       // Get the settings record from the first slot
            if settingsDatabase.count > 0 {
                settingsRecord = settingsDatabase.first!
            }
        } catch {
            let entity = NSEntityDescription.entity(forEntityName: ENTITY_NAME, in: managedContext) // If record doesn't exist, save out a new one
            settingsRecord = NSManagedObject(entity:entity!, insertInto:managedContext)
        }
        if (settingsRecord == nil) {
            let entity = NSEntityDescription.entity(forEntityName: ENTITY_NAME, in: managedContext)
            settingsRecord = NSManagedObject(entity:entity!, insertInto:managedContext)
        } else {    // Save new data only if it is different from the already store Settings record
            if settingsRecord.value(forKey: PASSWORD_KEY) as! Bool == settings.RequirePassword && settingsRecord.value(forKey: DATA_KEY) as! String == settings.DataKey && settingsRecord.value(forKey: SEARCH_KEY) as! String == settings.SearchEngine {
                return true         // No need to save data, it hasn't been changed
            }
        }
        settingsRecord.setValue(settings.RequirePassword, forKey: PASSWORD_KEY)
        settingsRecord.setValue(settings.DataKey, forKey: DATA_KEY)
        settingsRecord.setValue(settings.searchEngine, forKey: SEARCH_KEY)
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            NSLog("Unable to fetch from " + ENTITY_NAME + ": \(error)")
        }
        return false
        
    }
    
    // The Settings class, incorporating the various settings elements for the program
    class Settings {
        var requirePassword : Bool                  // Set if password is required (really only uses TouchID, password alternatives aren't supported)
        var dataKey : String                        // The data key identifies the data used in the JSON. Identical keys will access shared data
        var searchEngine : String                   // The search engine to use on initial loading of Search browser
        var RequirePassword : Bool {
            get { return requirePassword }
            set (requirePassword) { self.requirePassword = requirePassword }
        }
        var DataKey : String {
            get { return dataKey }
            set (dataKey) { self.dataKey = dataKey }
        }
        var SearchEngine : String {
            get { return searchEngine }
            set(searchEngine) { self.searchEngine = searchEngine }
        }
        init(requirePassword:Bool, dataKey:String, searchEngine:String) {
            self.requirePassword = requirePassword
            self.dataKey = dataKey
            self.searchEngine = searchEngine
        }
    }
    
}
