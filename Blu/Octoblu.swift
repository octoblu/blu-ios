//
//  Octoblu.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/4/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import Foundation

class Octoblu {
    
    let octobluUrl : String = "https://app.octoblu.com"
    
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
  
    private func makeRequest(path : String, method : String, parameters : Dictionary<String, String>, onSuccess : (json : JSON) -> ()){
        SVProgressHUD.showWithStatus("Loading flows...")

        let manager :AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        let url :String = self.octobluUrl + path
        // Request Success
        let requestSuccess = {
            (operation :AFHTTPRequestOperation!, responseObject :AnyObject!) -> Void in
            let json = JSON(responseObject);
            SVProgressHUD.showSuccessWithStatus("Flows Loaded")
            self.afterResult()
            onSuccess(json: json)
        }
        // Request Failure
        let requestFailure = {
            (operation :AFHTTPRequestOperation!, error :NSError!) -> Void in
            SVProgressHUD.showErrorWithStatus("Unable to load flows");
            self.afterResult()
            NSLog("requestFailure: \(error)")
        }
        // Set Headers
        manager.requestSerializer.setValue(self.uuid, forHTTPHeaderField: "skynet_auth_uuid")
        manager.requestSerializer.setValue(self.token, forHTTPHeaderField: "skynet_auth_token")
        
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
            for (i, flow) in json {
                let flowId = flow["flowId"].asString
                let flowName = flow["name"].asString
                
                for (j, node) in flow["nodes"] {
                    if(node["type"].asString == "operation:trigger"){
                        let nodeId = node["id"].asString
                        let nodeName = node["name"].asString
                        triggers += [Trigger(id: nodeId!, flowId: flowId!, flowName: flowName!, triggerName: nodeName!)]
                    }
                }
            }
            onSuccess(triggers : triggers)
        }
        
        let parameters = Dictionary<String, String>()
        makeRequest("/api/flows", method: "GET", parameters: parameters, onSuccess : processFlows)
    }
}