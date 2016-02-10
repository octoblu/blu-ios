//
//  Octoblu.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/4/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import Foundation

class Octoblu {
    
    let octobluUrl : String = "https://triggers.octoblu.com"
    
    var uuid : String
    var token : String
    
    // Constructor
    init(uuid : String, token : String){
        self.uuid = uuid
        self.token = token
    }
  
    func afterResult(){
      NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "dismissHUD:", userInfo: nil, repeats: false)
    }
  
    @objc func dismissHUD(timer: NSTimer){
      SVProgressHUD.dismiss()
    }
  
    func makeRequest(url : String, method : String, parameters : Dictionary<String, String>, onSuccess : (json : JSON) -> ()){

        let manager :AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        // Request Success
        let requestSuccess = {
            (operation :AFHTTPRequestOperation!, responseObject :AnyObject!) -> Void in
            let json = JSON(responseObject ?? "{}");
            self.afterResult()
            onSuccess(json: json)
        }
        // Request Failure
        let requestFailure = {
            (operation :AFHTTPRequestOperation!, error :NSError!) -> Void in
            SVProgressHUD.showErrorWithStatus("Error!");
            self.afterResult()
            NSLog("requestFailure: \(error)")
        }
        // Set Headers
        manager.requestSerializer.setValue(self.uuid, forHTTPHeaderField: "meshblu_auth_uuid")
        manager.requestSerializer.setValue(self.token, forHTTPHeaderField: "meshblu_auth_token")
        
        switch method {
        case "GET":
            manager.GET(url, parameters: parameters, success: requestSuccess, failure: requestFailure)
        case "POST":
            manager.POST(url, parameters: parameters, success: requestSuccess, failure: requestFailure)
        default:
            manager.GET(url, parameters: parameters, success: requestSuccess, failure: requestFailure)
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
            SVProgressHUD.showSuccessWithStatus("Triggers loaded!")

            onSuccess(triggers : triggers)
        }

        SVProgressHUD.showWithStatus("Loading triggers...")
        let parameters = Dictionary<String, String>()
        makeRequest("\(octobluUrl)/mytriggers", method: "GET", parameters: parameters, onSuccess : processFlows)
    }

    func trigger(uri: String, onResponse : (json : JSON)->()){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showWithStatus("Triggering...")
        }
        let parameters = Dictionary<String, String>()
        NSLog("Calling \(uri)")
        makeRequest(uri, method: "POST", parameters: parameters, onSuccess: onResponse)
    }
}