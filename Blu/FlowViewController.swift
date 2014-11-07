//
//  ViewController.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import UIKit

class FlowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var flows: [Trigger] = []
  
  var uuid : String? = nil
  var token : String? = nil
  
  var refreshControl:UIRefreshControl!
  
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

  @IBOutlet var tableView: UITableView!
  
  @IBAction func logoutButton(AnyObject){
    let settings = NSUserDefaults.standardUserDefaults()
    settings.removeObjectForKey("uuid")
    settings.removeObjectForKey("token")
    
    self.resetFlows()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    self.flows = []
    self.tableView.reloadData()
    self.refreshFlows()
    self.colorIndex = 0
    self.colorIndexHash = [Int:Int]()
  }
  
  func refreshFlows() {
    
    let settings = NSUserDefaults.standardUserDefaults()
    let uuid  = settings.stringForKey("uuid")
    let token = settings.stringForKey("token")
    
    if(uuid == nil || token == nil){
      performSegueWithIdentifier("showLoginViewController", sender: nil)
      return
    }
    self.uuid = uuid
    self.token = token
    self.getFlows(uuid!, token: token!)
  }

  override func didReceiveMemoryWarning(){
    super.didReceiveMemoryWarning()
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.flows.count;
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell

    cell.textLabel.text = self.flows[indexPath.item].triggerName
    cell.textLabel.textColor = UIColor.whiteColor()
    cell.textLabel.font = UIFont(name: "Helvetica", size: CGFloat(20.0))
    
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    
    return cell
  }

  func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    self.flows[indexPath.item].trigger(self.uuid!, token: self.token!)
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let index = indexPath.item
    // If color already set then don't set it to different one
    if colorIndexHash[index]? != nil {
      return
    }
    // Grab Color
    if colorIndex < 0 || colorIndex >= colors.count {
      colorIndex = 0
    }
    colorIndexHash[index] = colorIndex
    var color : UIColor? = colors[colorIndex]
    cell.backgroundColor = color
    colorIndex++
  }

  func getFlows(uuid : String, token : String){
    let onSuccess = { (triggers : [Trigger]) -> Void in
      self.flows = triggers
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
    }
    Octoblu(uuid: uuid, token: token).getFlows(onSuccess)
    
  }
}
