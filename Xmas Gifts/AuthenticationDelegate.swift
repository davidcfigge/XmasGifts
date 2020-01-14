//
//  AuthenticationDelegate.swift
//  Xmas Gifts
//
//  Created by David Figge on 2/28/17.
//  Copyright © 2017 WildTangent. All rights reserved.
//
//  This protocol supports presenting the Authentication view controller when the non-use timer has expired
//  The AppDelegate will call this method when the top view controller must present the AuthenticationViewController and force the user to re-login
//  This only happens if a) the non-use timer has expired and b) the user has specified secure access on
//  This protocol must be supported by the top view controller. At the moment, that is narrowed down to the MasterViewController and the GiftListViewController

import Foundation

protocol AuthenticationDelegate {
    func presentAuthenticationViewController()
}
