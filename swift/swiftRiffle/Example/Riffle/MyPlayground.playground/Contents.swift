import Foundation

class Base {
    class func create() {
        print("\(self)")
    }
}

class Subclass: Base {
    
}

Subclass.create()

