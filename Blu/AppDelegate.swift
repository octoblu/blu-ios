//
//  AppDelegate.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window : UIWindow?

    var flows: [Trigger] = []

    var uuid : String? = nil
    var token : String? = nil
    var octoblu : Octoblu? = nil

    // http://www.tinygorilla.com/Easter_eggs/pallatehex.html
    let colors : [UIColor] = [
        // Light Red
        UIColor(red : CGFloat(242 / 255.0), green: CGFloat(108 / 255.0), blue : CGFloat(079 / 255.0), alpha : 1.0),
        // Light Red Orange
        UIColor(red : CGFloat(246 / 255.0), green: CGFloat(142 / 255.0), blue : CGFloat(086 / 255.0), alpha : 1.0),
        // Light Yellow Orange
        UIColor(red : CGFloat(251 / 255.0), green: CGFloat(175 / 255.0), blue : CGFloat(093 / 255.0), alpha : 1.0),
        // Light Pea Green
        UIColor(red : CGFloat(172 / 255.0), green: CGFloat(211 / 255.0), blue : CGFloat(115 / 255.0), alpha : 1.0),
        // Light Yellow Green
        UIColor(red : CGFloat(124 / 255.0), green: CGFloat(197 / 255.0), blue : CGFloat(118 / 255.0), alpha : 1.0),
        // Light Green
        UIColor(red : CGFloat(060 / 255.0), green: CGFloat(184 / 255.0), blue : CGFloat(120 / 255.0), alpha : 1.0),
        // Light Green Cyan
        UIColor(red : CGFloat(28 / 255.0), green: CGFloat(187 / 255.0), blue : CGFloat(180 / 255.0), alpha : 1.0),
        // Light Cyan
        UIColor(red : CGFloat(0 / 255.0), green: CGFloat(191 / 255.0), blue : CGFloat(243 / 255.0), alpha : 1.0),
        // Light Cyan Blue
        UIColor(red : CGFloat(68 / 255.0), green: CGFloat(140 / 255.0), blue : CGFloat(203 / 255.0), alpha : 1.0),
        // Light Blue
        UIColor(red : CGFloat(186 / 255.0), green: CGFloat(116 / 255.0), blue : CGFloat(185 / 255.0), alpha : 1.0),
        // Light Blue Violet
        UIColor(red : CGFloat(96 / 255.0), green: CGFloat(92 / 255.0), blue : CGFloat(168 / 255.0), alpha : 1.0),
        // Light Violet
        UIColor(red : CGFloat(133 / 255.0), green: CGFloat(96 / 255.0), blue : CGFloat(168 / 255.0), alpha : 1.0),
        // Light Violet Magenta
        UIColor(red : CGFloat(168 / 255.0), green: CGFloat(100 / 255.0), blue : CGFloat(168 / 255.0), alpha : 1.0),
        // Light Magenta
        UIColor(red : CGFloat(240 / 255.0), green: CGFloat(110 / 255.0), blue : CGFloat(170 / 255.0), alpha : 1.0)
    ]
    
    var colorIndex : Int = 0
    
    var colorIndexHash : Dictionary<Int, Int> = [Int:Int]()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        if #available(iOS 9.0, *) {
            if (WCSession.isSupported()) {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
            }
        } else {
            // Fallback on earlier versions
        }

        return true
    }

    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        NSLog("- Session Received Message: \(message)");

        let action = message["action"]!

        switch (action as! String) {
            case "resetFlows":
                self.resetFlows()
                replyHandler([:])

            case "refreshFlows":
                self.refreshFlows({ (triggers) -> Void in
                    NSLog("Flows: \(triggers)")

                    var flows = [Int: [String: AnyObject]]()

                    if triggers != nil {
                        for (index, element) in triggers!.enumerate() {
                            flows[index] = element.asDictionary()
                        }
                    }

                    NSLog("- \(flows)")

                    replyHandler(["triggers": flows])
                })
            case "triggerFlow":
                self.triggerFlow(message["index"] as! Int, onSuccess: { (json) -> () in
                    NSLog("JSON: \(json)")
                    
                    replyHandler([:])
                })
            case "color":
                let color = self.color(message["index"] as! Int)
                var rgb = [CGFloat](count: 3, repeatedValue: 0.0)
                color!.getRed(&rgb[0], green: &rgb[1], blue: &rgb[2], alpha: nil)

                replyHandler(["color": rgb])
            default:
                NSLog("Error processing action: \(action)")
                replyHandler(["error": "Unrecognized action"])
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func resetFlows(){
        self.flows = []
        //self.refreshFlows(nil)
        self.colorIndex = 0
        self.colorIndexHash = [Int:Int]()
    }

    func refreshFlows(onSuccess : ((triggers : [Trigger]?) -> Void)?) {
        let settings = NSUserDefaults.standardUserDefaults()
        let uuid  = settings.stringForKey("uuid")
        let token = settings.stringForKey("token")

        if (uuid == nil || token == nil) {
            if self.window != nil {
                let controller = self.window!.rootViewController!
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    controller.performSegueWithIdentifier("showLoginViewController", sender: nil)
                }
            }

            if onSuccess != nil {
                onSuccess!(triggers: nil)
            }
            
            return
        }

        self.uuid = uuid
        self.token = token
        self.octoblu = Octoblu(uuid: self.uuid!, token: self.token!)

        self.getFlows(onSuccess)
    }

    func getFlows(onSuccess : ((triggers : [Trigger]) -> Void)?){
        let _onSuccess = { (triggers : [Trigger]) -> Void in
            self.flows = triggers

            if (onSuccess != nil) {
                onSuccess!(triggers: triggers)
            }
        }

        self.octoblu!.getFlows(_onSuccess)
    }

    func triggerFlow(index : Int, onSuccess: (json : JSON)->()) {
        self.octoblu!.trigger(self.flows[index].uri) {
            (json) -> () in
                let settings = NSUserDefaults(suiteName: "group.blu")!
                settings.setInteger(index, forKey: "lastTriggeredIndex")

                onSuccess(json: json)
        }
    }

    func color(index : Int) -> UIColor? {
        // If color already set then don't set it to different one
        if self.colorIndexHash[index] != nil {
            return self.colors[self.colorIndexHash[index]!]
        }
        // Grab Color
        if self.colorIndex < 0 || self.colorIndex >= self.colors.count {
            self.colorIndex = 0
        }
        self.colorIndexHash[index] = self.colorIndex
        let color : UIColor? = self.colors[self.colorIndex]
        self.colorIndex++

        return color
    }
}

