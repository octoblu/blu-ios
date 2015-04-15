//
//  triggerModel.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

class Trigger {
    var id : String
    var flowId : String
    var flowName : String
    var triggerName : String
    var uri : String
    
  init(id : String, flowId : String, flowName : String, triggerName : String, uri: String){
        self.id = id
        self.flowId = flowId
        self.flowName = flowName
        self.triggerName = triggerName
        self.uri = uri
    }
    
   func trigger(uuid : String, token : String, onResponse : (json : JSON)->()){
        SVProgressHUD.showWithStatus("Triggering...")
        let octoblu = Octoblu(uuid: uuid, token: token)
        let parameters = Dictionary<String, String>()
        NSLog("Calling \(uri)")
        octoblu.makeRequest(self.uri, method: "POST", parameters: parameters, onSuccess: onResponse)
    }
}