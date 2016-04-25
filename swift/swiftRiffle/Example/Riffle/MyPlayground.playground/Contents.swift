import Foundation

protocol FoodType {}
protocol Human: FoodType {}
protocol Vegetable: FoodType {}

protocol MythicalType {
    associatedtype FoodType
    
    func prepareFood() -> [FoodType]
    func devour(edible: FoodType)
}

class Kraken: MythicalType {
    func prepareFood() -> [Human] {
        //attack the village. Gather all the humans for DINNER TIME!
        return []
    }
    
    func devour(edible: Human) {
        //It's DINNER TIME YO. Nom nom nom.
    }
}

class Elf: MythicalType {
    func prepareFood() -> [Vegetable] {
        //Elves are vegetarian. Obvi.
        return []
    }
    
    func devour(edible: Vegetable) {
        //Yum. Greens. How tasty.
    }
}

protocol AnyAnyMythicalType {
    func hello()
}

//By making this class a generic class, we can define a type T that we forward to our dependency injected MythicalType.
//Since this class conforms to our MythicalType protocol, we can call MythicalType's functions regularly.

class AnyMythicalType<T>: MythicalType, AnyAnyMythicalType {
    //These variables are private, preventing others from assigning to them or calling them directly.
    //Since each type is the exact same type as the functions in our MythicalType, we can assign a MythicalType instance's function signatures to these variables.
    //By assigning a MythicalType instance's function signatures to these variables, we can effectively forward any calls made to AnyMythicalType's functions to the original Spaceship instance.
    private let _prepareFood: (Void -> [T])
    private let _devour: (T -> Void)
    
    //By creating only one required init, we ensure that we can only initialize this class one way.
    required init<U: MythicalType where U.FoodType == T>(_ mythicalCreature: U) {
        _prepareFood = mythicalCreature.prepareFood
        _devour = mythicalCreature.devour
    }
    
    //Because this forwarding class does conform to the MythicalType protocol, we can call the MythicalType functions directly on this class. This class, as you can see, will forward that message to the function signatures that we assigned at the time of initialization.
    func prepareFood() -> [T] {
        return _prepareFood()
    }
    
    //Here is the second function in the MythicalType protocol and the forwarded message.
    func devour(edible: T) {
        _devour(edible)
    }
    
    func hello() {
        
    }
}


let kraken = Kraken()

//Here is the magic at work! We can now define our generic `MythicalType`'s FoodType explicitly.
let mythicalCreature: AnyMythicalType<Human>

mythicalCreature = AnyMythicalType(kraken)

var z: [AnyAnyMythicalType] = []
z.append(AnyMythicalType(kraken))


// Might work, but don't have time for it now
//protocol Thing: Property, Convertible {}
//extension Array: Thing {}
//
//
//extension CollectionType where Self: Thing, Generator.Element : Convertible {
//    internal static func quietRepresentation() -> Any {
//        return Generator.Element.representation()
//    }
//}