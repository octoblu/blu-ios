//
//  Octoblu.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/4/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Octoblu {
  
  let octobluUrl : String = "https://triggers.octoblu.com"
  
  var uuid : String?
  var token : String?
  var bearer: String?
  var manager: Alamofire.Manager
  
  // Constructor
  init(uuid : String, token : String){
    self.uuid = uuid
    self.token = token
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    self.manager = Alamofire.Manager(configuration: configuration)
  }
  
  init(bearer: String){
    self.bearer = bearer
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    self.manager = Alamofire.Manager(configuration: configuration)
  }
 
  
  func afterResult(){
    NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "dismissHUD:", userInfo: nil, repeats: false)
  }
  
  @objc func dismissHUD(timer: NSTimer){
//    SVProgressHUD.dismiss()
  }
  
  func makeRequest(url : String, method : String, parameters : Dictionary<String, String>, onResponse : (json : JSON) -> ()){
    var headers : [String: String] = [:]
    if self.uuid != nil && self.token != nil {
      let credentialData = "\(self.uuid!):\(self.token!)".dataUsingEncoding(NSUTF8StringEncoding)!
      let base64Credentials = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      headers.updateValue("Basic \(base64Credentials)", forKey: "Authorization")
    }
    if self.bearer != nil {
      headers.updateValue("Bearer \(self.bearer!)", forKey: "Authorization")
    }

    var request: Request
    switch method {
    case "GET":
      request = self.manager.request(.GET, url, encoding: .JSON, headers: headers)
    case "POST":
      request = self.manager.request(.POST, url, encoding: .JSON, headers: headers)
    default:
      request = self.manager.request(.GET, url, encoding: .JSON, headers: headers)
    }
    
    request.responseJSON { response in
      switch response.result {
      case .Failure(let error):
//        SVProgressHUD.showErrorWithStatus("Error!");
        let json = JSON(error)
        self.afterResult()
        onResponse(json: json)
        NSLog("requestFailure: \(error)")
      case .Success(let value):
        let json = JSON(value)
        self.afterResult()
        onResponse(json: json)
      }
    }
  }
  
  func getFlows(onSuccess : (triggers : [Trigger]) -> Void) -> Void {
    let processFlows = { (json : JSON) -> Void in
      var triggers : [Trigger] = []
      for (_, trigger) in json {
        let flowId = trigger["flowId"].asString
        let flowName = trigger["flowName"].asString
        let triggerName = trigger["name"].asString
        let triggerId = trigger["id"].asString
        let uri = trigger["uri"].asString
        
        triggers += [Trigger(
          id: triggerId!,
          flowId: flowId!,
          flowName: flowName!,
          triggerName: triggerName!,
          uri: uri!
          )]
      }
//      SVProgressHUD.showSuccessWithStatus("Triggers loaded!")
      
      onSuccess(triggers : triggers)
    }
    
//    SVProgressHUD.showWithStatus("Loading triggers...")
    let parameters = Dictionary<String, String>()
    makeRequest("\(octobluUrl)/mytriggers", method: "GET", parameters: parameters, onResponse : processFlows)
  }
  
  func trigger(uri: String, onResponse : (json : JSON)->()){
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
//      SVProgressHUD.showWithStatus("Triggering...")
    }
    let parameters = Dictionary<String, String>()
    NSLog("Calling \(uri)")
    makeRequest(uri, method: "POST", parameters: parameters, onResponse: onResponse)
  }
}