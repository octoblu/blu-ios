//
//  ExtensionDelegate.swift
//  BluWatch Extension
//
//  Created by Roberto Andrade on 2/7/16.
//  Copyright © 2016 Octoblu, Inc. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    var session:WCSession!

    var flows: [Trigger] = []

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        self.ensureSession()
    }

    func ensureSession() {
        if (self.session == nil && WCSession.isSupported()) {
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func send(action: String, index: Int?, onSuccess: (([String: AnyObject]) -> Void)?) {
        self.ensureSession()

        if !self.session.reachable {
            NSLog("Session not reachable!")
            if (onSuccess != nil) {
                onSuccess!(["error": true]);
            }
            return
        }

        let message = [ "action": action, "index": index ?? -1 ];

        NSLog("Sending: \(message)")

        self.session.sendMessage(message as! [String : AnyObject],
            replyHandler: {
                (reply) -> Void in
                NSLog("Reply: \(reply)")

                if (onSuccess != nil) {
                    onSuccess!(reply)
                }
            },
            errorHandler: {
                (error) -> Void in
                NSLog("Error: \(error)");

                if (onSuccess != nil) {
                    onSuccess!(["error": true]);
                }
            }
        )
    }

    func resetFlows(){
        self.session.activateSession()
        self.flows = []
        self.send("resetFlows", index: nil, onSuccess: nil)
    }

    func refreshFlows(onSuccess : ((triggers : [Trigger]) -> Void)?) {
        self.send("refreshFlows", index: nil) {
            (reply) -> Void in
                let dictionaries = reply["triggers"] as! [Int: [String: AnyObject]]
                var triggers = [Trigger](
                    count: dictionaries.count,
                    repeatedValue: Trigger(id: "", flowId: "", flowName: "", triggerName: "", uri: "")
                )

                for (index, trigger) in dictionaries.values.enumerate() {
                    triggers[index] = Trigger(dict: trigger)
                }
                self.flows = triggers

                if onSuccess != nil {
                    onSuccess!(triggers: triggers)
                }
        }
    }

    func triggerFlow(index : Int, onSuccess: (isError : Bool)->()) {
        self.send("triggerFlow", index: index) {
            (reply) -> Void in
                let settings = NSUserDefaults(suiteName: "group.octoblu.blu")!
                settings.setInteger(index, forKey: "lastTriggeredIndex")

            onSuccess(isError: reply["error"] as! Bool);
        }
    }

    func color(index : Int, onSuccess: (UIColor?) -> ()) {
        self.send("color", index: index) {
            (reply) -> Void in
                let rgb = reply["color"] as! [CGFloat]
                let color = UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1.0)

                onSuccess(color)
        }
    }

}
