//
//  triggerModel.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import Foundation

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

    init(dict : [String: AnyObject]) {
        self.id = dict["id"] as! String
        self.flowId = dict["flowId"] as! String
        self.flowName = dict["flowName"] as! String
        self.triggerName = dict["triggerName"] as! String
        self.uri = dict["uri"] as! String
    }

    func asDictionary() -> [String: AnyObject] {
        return [
            "id": id,
            "flowId": flowId,
            "flowName": flowName,
            "triggerName": triggerName,
            "uri": uri
        ]
    }
}