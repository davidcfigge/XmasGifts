//
//  WebNavigationDelegate.swift
//  Xmas List
//
//  Created by David Figge on 2/15/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  This protocol passes notifications to delegates when URL navigation is complete

protocol WebNavigationDelegate {
    func onNavigationTo(url:String)
}
