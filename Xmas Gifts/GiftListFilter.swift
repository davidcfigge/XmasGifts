//
//  GiftListFilter.swift
//  Xmas Gifts
//
//  Created by David Figge on 1/16/18.
//  Copyright © 2018 WildTangent. All rights reserved.
//

import UIKit

class GiftListFilter: NSObject {
    public enum types:Int { case item=0, categoryAndItem=1, status=2, store=3, packageId=4 }
    static var mapping : [Int:String] = [
        types.item.rawValue: "Item",
        types.categoryAndItem.rawValue: "Category and Item",
        types.status.rawValue: "Purchase Status",
        types.store.rawValue: "Store",
        types.packageId.rawValue: "Package Identifier",
    ]
    
    public static var descriptions : [String] {
        get {
            var descriptions = [String]()
            for index in keys {
                descriptions.append(mapping[index]!)
            }
            return descriptions
        }
    }
    
    public static func description(type:types) -> String! {
        return mapping[type.rawValue]
    }
    
    public static func description(rawValue:Int) -> String! {
        return mapping[rawValue]
    }

    public static var count : Int {
        get { return mapping.count }
    }
    
    public static var keys : [Int] {
        return mapping.keys.sorted()
    }

}
