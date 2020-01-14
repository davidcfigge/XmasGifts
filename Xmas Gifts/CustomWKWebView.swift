//
//  WTWebView.swift
//  quickgames
//
//  Created by David Figge on 1/31/17.
//  Copyright © 2017 WildTangent. All rights reserved.
//
//  This class encapsulates functionality around the WKWebView element. The primary purposes are to:
//  1) Provide an easy mechanism to have the webview seamlessly replace the container view. It does this by
//     adding the webview as a subview and setting constraints so it completely covers the container and resizes with it
//  2) Provide a simplified interface for handling load and navigational errors. The hosting ViewController just implements the
//     WebErrorDelegate protocol and HTML errors from the WKWebView are redirected to it
//

import UIKit
import WebKit

class CustomWKWebView: WKWebView,WKNavigationDelegate {
    var webErrorDelegate : WebErrorDelegate! = nil              // Specified if the hosting class is interested in errors that may occur
    var webNavigationDelegate : WebNavigationDelegate! = nil    // Specified if the hosting class is interested in navigation completing
    
    init(container:UIView!, errorHandler:WebErrorDelegate! = nil, webNavigationDelegate:WebNavigationDelegate! = nil, configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        self.webErrorDelegate = errorHandler
        self.webNavigationDelegate = webNavigationDelegate
        let bounds = container.bounds                   // Adhere to the bounds of the container view
        super.init(frame:bounds,configuration:configuration)
        container!.addSubview(self)
        
        // Set up the various constraints to for the webview to resize with the container view
        let topConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        translatesAutoresizingMaskIntoConstraints = false
        container!.addConstraints([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
        
        navigationDelegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported for this class")
    }
    
    //
    // WKNavigationDelegate Methods
    //
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if (webErrorDelegate != nil) {
            webErrorDelegate.onHtmlLoadError(error: withError)
        }
    }
    
    func webView(_: WKWebView, didFail didFailNavigation: WKNavigation!, withError: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if (webErrorDelegate != nil) {
            webErrorDelegate.onHtmlLoadError(error: withError)
        }
    }
    
    //
    // UIWebViewDelegate Methods
    //
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if (webErrorDelegate != nil) {
            webErrorDelegate.onHtmlLoadError(error: error)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let newUrl = navigationAction.request.url?.absoluteString
        if (webNavigationDelegate != nil) {
            webNavigationDelegate.onNavigationTo(url:newUrl!)
        }
        decisionHandler(.allow)
    }
    
}
