//
//  GlanceController.swift
//  BluWatch Extension
//
//  Created by Roberto Andrade on 2/7/16.
//  Copyright © 2016 Octoblu, Inc. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    var extDelegate:ExtensionDelegate!

    @IBOutlet var triggerGroup : WKInterfaceGroup!
    @IBOutlet var triggerLabel : WKInterfaceLabel!

    var lastTriggeredIndex : Int?
    var lastTriggeredFlow : Trigger!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.extDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate

        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        let settings = NSUserDefaults(suiteName: "group.octoblu.blu")!
        self.lastTriggeredIndex = settings.objectForKey("lastTriggeredIndex") as? Int

        if self.lastTriggeredIndex == nil {
            self.triggerLabel!.setText("Trigger a flow\nfirst")
        } else {
            self.updateUserActivity("launchFromGlance", userInfo: ["trigger": self.lastTriggeredIndex!], webpageURL: nil)

            if self.extDelegate.flows.count > 0 {
                self.lastTriggeredFlow = self.extDelegate.flows[self.lastTriggeredIndex!]
                self.showTrigger()
            } else {
                self.extDelegate.refreshFlows({
                    (triggers) -> Void in
                        if self.lastTriggeredIndex! < self.extDelegate.flows.count {
                            self.lastTriggeredFlow = self.extDelegate.flows[self.lastTriggeredIndex!]
                            self.showTrigger()
                        } else {
                            NSLog("Out of range")
                            self.triggerLabel!.setText("Trigger a flow\nfirst")
                        }
                })
            }

        }
    }

    func showTrigger() {
        NSLog("Showing Trigger: \(self.lastTriggeredIndex!) = \(self.lastTriggeredFlow.triggerName)")

        self.extDelegate.color(self.lastTriggeredIndex!) {
            (color) -> () in
                self.triggerLabel!.setText(self.lastTriggeredFlow.triggerName)
                self.triggerGroup!.setBackgroundColor(color)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
