//
//  Persistence.swift
//  Pods
//
//  Created by damouse on 4/25/16.
//
//

import Foundation


public protocol Persistable {
    func modelName() -> String
    func getId() -> UInt64
    static func modelName() -> String
    static func getManager() -> ModelManager?
}

extension Model: Persistable {
    public func getId() -> UInt64 {
        return _xsid
    }
    
    public func modelName() -> String {
        let fullNameArr = "\(self.dynamicType)".characters.split{$0 == "."}.map(String.init)
        return fullNameArr[fullNameArr.count - 1]
    }
    
    public static func modelName() -> String {
        return "\(self)"
    }
    
    public static func getManager() -> ModelManager? {
        return Model.manager
    }
}

// Core-based persistence
extension Model {
    static var manager: ModelManager!
    
    static func setConnection(app: AppDomain) {
        manager = ModelManager(app: app.app)
    }
    
    static func ready() -> Bool {
        return manager != nil
    }
    
    public class func count() -> OneDeferred<Int> {
        let r = OneDeferred<Int>()
        manager.callCore("Count", deferred: r, args: ["\(self)"])
        return r
    }
    
    public func create() -> Deferred {
        return Model.manager.callCore("Create", args: [modelName(), self.serialize()])
    }
    
    public func destroy() -> Deferred {
        return Model.manager.callCore("Destroy", args: [modelName(), String(self._xsid)])
    }
    
    public class func find<T: CollectionType where T.Generator.Element: Model>(query: [String: Any]) -> OneDeferred<T>! {
        let r = OneDeferred<T>()
        
        // OSX Final
        // let q = jsonRepack(query)!
        
        var q: [String: Any] = [:]
        for (k, v) in query { q[k] = switchTypes(v) }
        
        manager.callCore("Find", deferred: r, args: [modelName(), q])
        return r
    }
    
    public class func all<T: CollectionType where T.Generator.Element: Model>() -> OneDeferred<T>! {
        return find([:])
    }
    
    public func save() -> Deferred {
        return Model.manager.callCore("Save", args: [modelName(), self.serialize()])
    }
}


// Allow some operations to be perfromed on collections of models
extension CollectionType where Generator.Element: Convertible, Generator.Element: Persistable {
    
    public func save() -> Deferred {
        let manager = Generator.Element.getManager()!
        let name = Generator.Element.modelName()
        let serialized = self.map { $0.serialize() }
        return manager.callCore("SaveMany", args: [name, serialized])
    }
    
    public func destroy() -> Deferred {
        let manager = Generator.Element.getManager()!
        let name = Generator.Element.modelName()
        let serialized = self.map { String($0.getId()) }
        return manager.callCore("DestroyMany", args: [name, serialized])
    }
    
    public func create() -> Deferred {
        let manager = Generator.Element.getManager()!
        let name = Generator.Element.modelName()
        let serialized = self.map { $0.serialize() }
        return manager.callCore("CreateMany", args: [name, serialized])
    }
}

// Allow models to be compared through their hidden id
extension Model: Equatable {}

public func ==(lhs: Model, rhs: Model) -> Bool {
    return lhs._xsid == rhs._xsid
}


// Crust represnentation of the model manager
public class ModelManager: CoreClass {
    init(app: CoreApp) {
        super.init()
        sendCore("InitModels", address: address, object: app.address, args: [], synchronous: false)
    }
}


// guard let m = manager else { Riffle.warn("Cannot access model object persistence without a connection! Instantiate an AppDomain first!"); return nil }







