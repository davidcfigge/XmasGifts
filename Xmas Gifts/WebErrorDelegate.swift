//
//  WebErrorDelegate.swift
//  Xmas List
//
//  Created by David Figge on 2/15/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  This protocol definition supports classes handling HTML load errors from a wkwebview


protocol WebErrorDelegate {
    func onHtmlLoadError(error:Error)
}
