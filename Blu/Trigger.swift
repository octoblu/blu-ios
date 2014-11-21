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
    
    init(id : String, flowId : String, flowName : String, triggerName : String){
        self.id = id
        self.flowId = flowId
        self.flowName = flowName
        self.triggerName = triggerName
    }
    
   func trigger(uuid : String, token : String, onResponse : ()->()){
        let meshblu = Meshblu(uuid: uuid, token: token)
        meshblu.makeRequest("/messages", parameters: ["devices": self.flowId, "topic": "button", "payload" : ["from": self.id]], onResponse)
    }
}