//
//  ViewController.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import UIKit

class FlowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  var appDelegate:AppDelegate!

  var displayEmptyNotice : Bool = false;
  
  var refreshControl:UIRefreshControl!

  @IBOutlet var tableView: UITableView!
  
  @IBAction func logoutButton(_: AnyObject){
    let settings = NSUserDefaults.standardUserDefaults()
    settings.removeObjectForKey("uuid")
    settings.removeObjectForKey("token")
    
    self.resetFlows()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    self.tableView.separatorColor = UIColor.clearColor()
    self.tableView.rowHeight = CGFloat(69.0) // Hehe
    self.tableView.backgroundColor = UIColor.darkGrayColor()
    
    self.refreshControl = UIRefreshControl()
    self.refreshControl.backgroundColor = UIColor.lightGrayColor()
    self.refreshControl.addTarget(self, action: "refreshFlows", forControlEvents: UIControlEvents.ValueChanged)
    self.tableView.addSubview(refreshControl)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.resetFlows()
  }
  
  func resetFlows(){
    self.appDelegate.resetFlows();
    self.tableView.reloadData()

    self.refreshFlows()
  }

  func refreshFlows() {
    self.appDelegate.refreshFlows { (triggers) -> Void in
        self.displayEmptyNotice = triggers == nil || triggers!.count == 0
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
  }

  override func didReceiveMemoryWarning(){
    super.didReceiveMemoryWarning()
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = self.appDelegate.flows.count
    if self.displayEmptyNotice {
      count = 1
    }
    return count;
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
    
    cell.textLabel!.textAlignment = NSTextAlignment.Center
    
    if self.displayEmptyNotice {
      cell.textLabel!.text = "No Triggers Available"
    }else{
      cell.textLabel!.text = self.appDelegate.flows[indexPath.item].triggerName
    }
    
    cell.textLabel!.textColor = UIColor.whiteColor()
    cell.textLabel!.font = UIFont(name: "Helvetica-Bold", size: CGFloat(22.0))
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if self.displayEmptyNotice {
      let alert = UIAlertController(title: "No Triggers", message: "You have no triggers, please create them in the Octoblu designer.", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "Go To Octoblu", style: UIAlertActionStyle.Default, handler: { action in
        switch action.style{
        case .Default:
          let url = NSURL(string:"https://app.octoblu.com")!
          UIApplication.sharedApplication().openURL(url)
        case .Cancel:
          NSLog("Alert Canceled")
        case .Destructive:
          NSLog("Alert Desctructed")
        }
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }else{
      
//      UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//      spinner.frame = CGRectMake(0, 0, 24, 24);
//      UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//      cell.accessoryView = spinner;
//      [spinner startAnimating];
//      [spinner release];
      let cell : UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
      cell.textLabel!.text = "Firing...";
      
      let onSuccess = {(json : JSON) -> Void in
        cell.textLabel!.text = json.isError ? "Failed!" : "Triggered!"
        Timer.start(1, repeats: false, handler: {
          (t: NSTimer) in
          self.tableView.reloadData()
          t.invalidate()
        })
      };
      
      self.appDelegate.triggerFlow(indexPath.item, onSuccess: onSuccess)
    }
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if self.displayEmptyNotice {
      cell.backgroundColor = UIColor.darkGrayColor()
      return
    }
    
    cell.backgroundColor = self.appDelegate.color(indexPath.item)
  }

}
