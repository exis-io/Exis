//
//  App.swift
//  Pods
//
//  Created by damouse on 3/7/16.
//
//

import Foundation
import Mantle

class AppDomain: Domain {
    public init(name: String) {
        super.init(name: name, app: CoreApp())
    }
}

// Internal App object
class CoreApp: CoreClass {
    override init() {
        super.init()
        initCore("App")
    }
}