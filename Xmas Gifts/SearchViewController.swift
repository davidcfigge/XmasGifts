//
//  SearchViewController.swift
//  Xmas List
//
//  Created by David Figge on 2/15/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  This class displays a search web view for the specified gift

import UIKit
import WebKit

class SearchViewController: UIViewController, WKUIDelegate, WebNavigationDelegate, WebErrorDelegate, DismissSubviewDelegate {
    let urls : [String:String] = [ Configuration.GOOGLE_SEARCH_ENGINE_KEY:"https://www.google.com",
                                   Configuration.AMAZON_SEARCH_ENGINE_KEY:"https://www.amazon.com" ]
    let query_params : [String:String] = [ Configuration.GOOGLE_SEARCH_ENGINE_KEY:"/#q=",
                                           Configuration.AMAZON_SEARCH_ENGINE_KEY:"/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords="]
    var hostKey : String = Configuration.AMAZON_SEARCH_ENGINE_KEY
    @IBOutlet weak var webHost : UIView!
    @IBOutlet weak var hostLabel : UILabel!
    @IBOutlet weak var itemLabel : UILabel!
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var forwardButton : UIButton!
    
    var searchString : String!
    var searchItem : String!            // The item to search for
    var searchDetails : String!         // The details of the item. We put searchItem + searchDetails together for the search string
    
    var webview : CustomWKWebView! = nil

    override func loadView() {
        super.loadView()
        let settings = Configuration.getSettingsData(createIfNeeded: true)
        if settings != nil {
            hostKey = Configuration.getSettingsData(createIfNeeded: true).searchEngine
        }
        webview = CustomWKWebView(container: webHost, errorHandler:self, webNavigationDelegate:self)        // Place a new WTWebView onto the container view, set this class up for supporting error handling and javascript calls

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        itemLabel.text = searchItem
        reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func dismissSubviews() {
        onClose()
    }
    
    func reload() {
        loadUrl(urlKey:hostKey, searchfor:searchItem + " " + searchDetails)
    }

    func onHtmlLoadError(error:Error) {
//        displayAlert(title: "Error", message: "Unable to load web page \(error.localizedDescription)")
    }

    func onNavigationTo(url:String) {
        let name = getSiteNameFromUrl(url: webview.url)
        if name != nil {
            hostLabel.text = name?.capitalized
        }
        backButton.isEnabled = webview.canGoBack
        forwardButton.isEnabled = webview.canGoForward
    }
    
    func getSiteNameFromUrl(url:URL?) -> String! {
        let host = url?.host
        let sp = StringProcessor(line:host!)
        let index = sp.lastIndexOf(delimiters: ".")
        let site = sp.wordBefore(index: index, delimiters: ".")
        return site
    }
    
    func getSiteNameFromUrl(urlString:String) -> String! {
        let url = NSURL(string: urlString)
        let domain = url?.host
        if domain != nil {
            NSLog("Navigated to \(domain!)")
        }
        return domain
    }
    
    // Display an alert box with a message and a button, and an optional "when complete" closure
//    func displayAlert(title:String, message:String, button:String = "OK", onComplete: (()->Swift.Void)? = nil) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        alertController.addAction(UIAlertAction(title: button, style: .default, handler: { (action:UIAlertAction!) in
//            if (onComplete != nil) {
//                onComplete!()
//            }
//        }))
//        modalPresentationStyle = .overCurrentContext
//        modalTransitionStyle = .coverVertical
//        present(alertController, animated: true, completion: nil)
//    }
    
    func loadUrl(urlKey:String, searchfor:String! = nil) {
        loadUrl(url:urls[urlKey]!, searchfor:searchfor, queryParams:query_params[urlKey])
    }
    
    func loadUrl(url:String, searchfor:String! = nil, queryParams:String! = nil) {
        var urlString = url
        if searchfor != nil {
            if queryParams != nil {
                urlString = urlString + queryParams
            }
            urlString = urlString + searchfor.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        }
        let request = URLRequest(url: URL(string:urlString)!)
        webview.load(request)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @IBAction func onClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Prompt the user to select a search engine to use
    @IBAction func chooseSearchEngine() {
        _ = SelectionPrompt(title: "Search on", prompt: "Which search engine do you want to use for lookups?", button1: "Cancel", button2: Configuration.GOOGLE_SEARCH_ENGINE_KEY, button3: Configuration.AMAZON_SEARCH_ENGINE_KEY, parent: self) { (button) in
            switch(button) {
            case SelectionPromptViewController.BUTTON_2:
                self.hostKey = Configuration.GOOGLE_SEARCH_ENGINE_KEY
                self.reload()
                break
            case SelectionPromptViewController.BUTTON_3:
                self.hostKey = Configuration.AMAZON_SEARCH_ENGINE_KEY
                self.reload()
                break
            case SelectionPromptViewController.BUTTON_1:
                fallthrough
            default:
                break
            }
        }
    }
    
    @IBAction func navigateBack() {
        if webview.canGoBack {
            webview.goBack()
        }
    }
    
    @IBAction func navigateForward() {
        if webview.canGoForward {
            webview.goForward()
        }
    }

}
