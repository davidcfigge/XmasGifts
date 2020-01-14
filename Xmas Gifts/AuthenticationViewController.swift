//
//  AuthenticationViewController
//  Xmas List
//
//  Created by David Figge on 12/1/16.
//  Copyright © 2016 David Figge. All rights reserved.
//
//  This class is responsible for authenticating the user via TouchID
//  It also keeps track of how long it's been since the user has interacted with the app, and can be queried as to determine if it's appropriate to force the user to log in again
//  Note that the activity timer requires periodic calls to active() in order to reset the timestamp

import UIKit
import LocalAuthentication
import Firebase

class AuthenticationViewController: UIViewController {
    private static let LOGOUT_INTERVAL = TimeInterval(10*60)        // 10 minute timeout
    private static let AUTO_LOGIN = !Configuration.getSettingsData(createIfNeeded:true).RequirePassword
    private static var authenticated = false
    private static var lastActive : Date = Date()
    
    // Indicates if the user is current seen as authenticated
    // A false would imply either
    //   a) TouchID isn't supported or active
    //   b) User has timed out
    //   c) User has yet to log in to the app
    
    // Return true if the user is authorized to interact with the app
    public static var isAuthenticated : Bool {
        get {
            if authenticated || AUTO_LOGIN || !canAuthenticateUser() {
                return true
            }
            return false
        }
    }
    
    // Call this method to indicate that the user is using the app
    // This resets the timestamp used to determine how long the app has remained unused
    static func active() {
        lastActive = Date()
        authenticated = true
    }
    
    @IBOutlet weak var loggedInLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        AuthenticationViewController.active()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ignore() {
    }
    
    // Determine if the user can be authenticated via TouchID
    public static func canAuthenticateUser() -> Bool {
        let context = LAContext()
        var error : NSError?
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            switch error?.code {
            default:
                return false
            }
        }
        return true
    }
    
    // Use this method to determine if the user session has timed out
    static func checkForLogin() -> Bool {
        if lastActive.addingTimeInterval(LOGOUT_INTERVAL) < Date() {
            authenticated = false
            return true
        }
        return false
    }
    
    // Log the user in
    @IBAction func onLogin() {
        if AuthenticationViewController.AUTO_LOGIN {
            proceed()
            return
        }
        var error:NSError?
        
        let authenticationContext = LAContext()
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            loggedInLabel.text = "You need a Touch ID sensor to use this app"
            loggedInLabel.isHidden = false
            return
        }
        
        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login Required", reply: { [unowned self](success, error) -> Void in
            if success {
                DispatchQueue.main.async {
                    self.loggedInLabel.text = "You have successfully logged in"
                    self.loggedInLabel.isHidden = false
                }
                self.proceed()
            } else {
                DispatchQueue.main.async {
                    self.showAlertWithTitle(title: "Login", message: "Unable to log you in")
                    self.loggedInLabel.text = "Login failed"
                    self.loggedInLabel.isHidden = false
                }
            }
        })
    }
    
    // This is used to show the alert to indicate issues with logging in
    func showAlertWithTitle( title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    // Dismiss the view controller and proceed with running the app
    func proceed() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        //performSegue(withIdentifier: "Auth2People", sender: self)
    }
}

