//
//  LoginViewController.swift
//
//
//  Created by Peter DeMartini on 11/4/14.
//
//

import UIKit
import Foundation

class LoginViewController : UIViewController, UIWebViewDelegate {
    @IBOutlet var webView: UIWebView!
    let LOGIN_URL = "http://app.octoblu.com/static/auth-login.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearCookies()
        
        self.loadUrl()
    }
    
    func clearCookies(){
        let cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieStore.cookies! as Array<NSHTTPCookie> {
            cookieStore.deleteCookie(cookie)
        }
    }
    
    func loadUrl(){
        let url = NSURL(string: LOGIN_URL)
        
        let request = NSURLRequest(URL: url!)
        
        webView.loadRequest(request)
    }
    
    func setUuidAndToken(uuid : String, token : String) {
        let settings = NSUserDefaults.standardUserDefaults()
        settings.setObject(uuid, forKey: "uuid")
        settings.setObject(token, forKey: "token")
        NSLog("UUID : \(uuid) TOKEN : \(token)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let currentUrl : String? = webView.request?.URL!.absoluteString;
        if currentUrl == nil || currentUrl! == "" {
            return
        }
        if currentUrl!.rangeOfString("?") == nil {
            return
        }
        
        let queryItems  = (NSURLComponents(string: currentUrl!)?.queryItems)!
            as Array<NSURLQueryItem>
        
        let keys = queryItems.map({(queryItem) -> String in queryItem.name})
        if(!keys.contains("uuid") || !keys.contains("token")) {
            return
        }
        
        let uuid : String? = queryItems[0].value
        let token : String? = queryItems[1].value
        
        if uuid == "undefined" || token == "undefined" {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Unable to Login"
            alert.addButtonWithTitle("Retry")
            alert.show()
            self.loadUrl()
            return;
        }
        
        if uuid != nil && token != nil {
            webView.stopLoading()
            setUuidAndToken(uuid!, token: token!)
        }
        
    }
}
