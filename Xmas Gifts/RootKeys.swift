//
//  RootKeys.swift
//  Xmas Gifts
//
//  Created by David Figge on 3/10/17.
//  Copyright © 2017 WildTangent. All rights reserved.
//

import Foundation
import FirebaseDatabase

class RootKey:FirebaseDBElement {
    private var theKey : String
    public override func getKey() -> String! {
        return theKey
    }
    
    required public init(snapshot: DataSnapshot!) {
        theKey = snapshot.key
        super.init()
    }
}

class RootKeys : FirebaseDB<RootKey> {
    public init() {
        super.init(rootPath: People.ROOT_PATH, child:nil)
    }
}
