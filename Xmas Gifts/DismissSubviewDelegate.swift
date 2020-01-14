//
//  DismissSubviewDelegate.swift
//  Xmas Gifts
//
//  Created by David Figge on 2/28/17.
//  Copyright © 2017 WildTangent. All rights reserved.
//
//  This protocol is used by view controllers to dismiss subviews when the app is placed into the background.
//  When called, the dismissSubviews should
//  1) Call dismissSubviews for any subviews that might be showing on top of the ViewController
//  2) Dismiss yourself if you are not one of the main controllers (MasterViewController or DetailViewController)

import Foundation

protocol DismissSubviewDelegate {
    func dismissSubviews()
}
