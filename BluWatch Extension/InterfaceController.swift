//
//  InterfaceController.swift
//  BluWatch Extension
//
//  Created by Roberto Andrade on 2/7/16.
//  Copyright © 2016 Octoblu, Inc. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    var extDelegate:ExtensionDelegate!
    
    @IBOutlet weak var tableView:WKInterfaceTable!
    @IBOutlet weak var loadingImage:WKInterfaceImage!
    @IBOutlet weak var loadingLabel:WKInterfaceLabel!
    @IBOutlet weak var loadingGroup:WKInterfaceGroup!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.extDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate

        // Configure interface objects here.
        self.refreshFlows()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func refreshFlows() {
        self.refreshFlows(nil)
    }

    func refreshFlows(onSuccess: (() -> ())?) {
        NSLog("Fetching flows...")

        /*
        self.extDelegate.resetFlows()

        return
        */
        
        self.tableView.setHidden(true)
        self.loadingGroup.setHidden(false)
        self.loadingImage.setImageNamed("octoblu")
        self.loadingImage.startAnimatingWithImagesInRange(NSMakeRange(0, 20), duration: 2.0, repeatCount: 0)
        self.loadingLabel.setText("Loading...")

        self.extDelegate.refreshFlows { (triggers) -> Void in
            NSLog("Got flows: \(triggers) (\(triggers.count))")

            if triggers.count == 0 {
                self.loadingLabel.setText("No Triggers\nAvailable")
                self.loadingImage.stopAnimating()

                if (onSuccess != nil) {
                    onSuccess!()
                }

                return
            }

            self.tableView.setNumberOfRows(triggers.count, withRowType: "default")

            let lastRow = (self.tableView.numberOfRows - 1)

            for index in 0...lastRow {
                let row = self.tableView.rowControllerAtIndex(index)
                let group = row!.groupView!
                let label = row!.labelView!

                let trigger = triggers[index]
                label.setText(trigger.triggerName)

                self.extDelegate.color(index, onSuccess: { (color) -> () in
                    NSLog("Color: #\(index) = \(color)")
                    group.setBackgroundColor(color)

                    if index == lastRow {
                        self.tableView.setHidden(false)
                        self.loadingGroup.setHidden(true)

                        if (onSuccess != nil) {
                            onSuccess!()
                        }
                    }
                })
            }
        }
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if rowIndex >= self.extDelegate.flows.count {
            NSLog("Invalid selected index: \(rowIndex)")
            return
        }
        
        let flow = self.extDelegate.flows[rowIndex]
        NSLog("Firing: \(flow)")

        let row = table.rowControllerAtIndex(rowIndex)
        let label = row!.labelView!
        label.setText("Firing...")

        self.extDelegate.triggerFlow(rowIndex) { (isError) -> () in
            NSLog("Triggered!")

            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                label.setText(isError ? "Failed!" : "Triggered!")

                Timer.start(1, repeats: false, handler: {
                    (t: NSTimer) in
                        label.setText(flow.triggerName)
                        t.invalidate()
                })
            }
        }
    }

    override func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
        NSLog("handleUserActivity: \(userInfo)")

        if userInfo!.keys.contains("trigger") {
            let index = userInfo!["trigger"] as! Int

            if self.extDelegate.flows.count == 0 {
                self.refreshFlows({
                    () -> () in
                        self.table(self.tableView, didSelectRowAtIndex: index)
                })
            } else {
                self.table(self.tableView, didSelectRowAtIndex: index)
            }
        }
    }

}

class RowController : NSObject {
    @IBOutlet weak var groupView:WKInterfaceGroup!
    @IBOutlet weak var labelView:WKInterfaceLabel!
}
