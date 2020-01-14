//
//  Sorter.swift
//  Xmas Gifts
//
//  Created by David Figge on 12/30/17.
//  Copyright © 2017 WildTangent. All rights reserved.
//

import UIKit

class Sorter: NSObject {
    var sortStringsAndKeys = [String : String]()
    var sortedKeys = [String]()
    var count : Int {
        get { return sortedKeys.count }
    }
    
    public func keyFromIndex(index:Int) -> String? {
        if index >= sortedKeys.count { return nil }
        let key = sortedKeys[index]
        return sortStringsAndKeys[key]
    }
    
    public func indexFromKey(key:String) -> String? {
        return sortStringsAndKeys[key]
    }
    
    override init() {
        super.init()
        sortStringsAndKeys = [String : String]()
        sortedKeys = [String]()
    }
    
    convenience init(retrieveDataObject:(Int)->Any?, extractKeyFromDataObject:(Any)->(String?,String?)) {
        self.init()
        var index = 0
        var obj : Any?
        obj = retrieveDataObject(index)
        while (obj != nil) {
            let (key,value) = extractKeyFromDataObject(obj!)
            if key != nil {
                sortStringsAndKeys[value!] = key
            }
            index += 1
            obj = retrieveDataObject(index)
        }
        sortedKeys = sortStringsAndKeys.keys.sorted(by:<)
    }
}
