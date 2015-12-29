
import Cocoa

/*
Scratchpad for object storage. 

Notable absent is validation, since it isnt well expressed by native languages styles and thus
doesn't fit into the whole "looks like native code!" bit. Much like native objects, validation is an 
excercise left to the reader for the time being. 

The theme here is "ActiveRecord," but theres a heavy list of methods from ActiveRecord that I'm not sure
I want to include. Things like "first", "last", "all" can all be covered by the other methods here.
*/

// Base model implementation. This is here as an example and should not be considered final
class Model {
    var _id = "randomidofthings"
    
    // Note that we don't need "new" or "create". Implicityly, init() is "new"
    init() {}
    
    required init(json: [String: AnyObject]?) { }
    
    func toJson() -> [String: AnyObject] {
        return [:]
    }
    
    class func schema() -> [String: AnyObject] {
        return [:]
    }
    
    
    // Active record makes a distinction between save and update. Do we care?
    // What about mixed collections, with new and existing models in it? Might still want to retain 
    // that seperation. 
    // Not maintaining that seperation means using "upsert == true" for all save calls
    func save() {}
    
    func delete() {}
    
    
    // MARK: Class methods an accessors
    class func find<T: Model>(query: AnyObject...) -> [T] {
        // Do some database lookup with the query parameters 
        
        // Build THIS class with self access. Have to assert type immediately, 
        // since generics are invariant (damnit apple)
        
        let constructed = self.init(json: nil) as! T
        return [constructed]
        
        //return []
    }
    
    //class func all() -> [Self] {
    //    return []
    //}
    
    // What would be a nice way around the generic covariance constraints, except you have to 
    // explicitly pass the type. Great.
    //class func all<T: Model>(t: T.Type) -> [T] {
    //    let new = t.init(json: nil)
    //    return [new]
    //}
    
    class func first() -> Self? {
        return self.init(json: nil)
    }
    
    class func last() -> Self? {
        return self.init(json: nil)
    }
}


// Case 1: create a new model object and declare fields on it
class User: Model {
    var name: String = ""
}

class Classroom: Model {
    var students: [User] = []
}


// Case 2: Instantiate the model and save it
let m = User()
m.name = "joebob"
//m.save()


/*
All operations emit promises/deferreds.

    m.save.then {
        print("save completed")
    }
    .error { reason
        print("Unable to save! reason: \(reason)")
    }
*/


// Case 3: Load all models
// You *must* constrain the receiver with "[User]" or "as! [User]" or you'll get an array of Models back.
// This is a direct effect of not having generic covariance
let users: [User] = User.find()  // #=> User1, User2, User3...
print(users[0].name)

// Query parameters here
let queryUsers: [User] = User.find("name == joebob")  // #=> User1 (name == "joebob")

// Case 4: Delete a model 
m.delete()


// Case 5: Simple relation, implicit in the definition of the class
let c = Classroom()
let s = User()

s.name = "steve"
c.students.append(s)

s.save()
c.save()

/*
User is saved first here in the active-record way of doing things. Might not have to do that, 
depends how relations are implemented.

Possibility 1: User has a silent foreign key set when appended to collection. Makes upwards references
easeier (like user.classroom). This requires custom code within the array or an observer of the array.
    c._classroom_id = s._id

Possibility 2: Only the parent is aware of the relation and loads them all when needed. Backwards references
are going to be tough in the static languages
    c._student_ids = [c._id]

Might be better to stick with whatever AR was doing, since they've likely solved a host of other problems
like this.
*/


// Case 6: Load a simple to-many relation
let loaded = Classroom.first()

let kids = loaded!.students // #=> User1, User2...

/*

Classroom.first().then { results in
    let kids = results.students
}

*/

// This won't scale, have to be able to load the relations lazily. Can't really load them lazily and then 
// access them normally, since b = loaded.students is a synchronous operation



// Hypothetical cases: Examples that don't have a clear solution yet
// User.find(where collection == c)


// TESTING


//func testVariance(foo:(Int)->Any){foo(1)}
//
//func innerAnyInt(p1:Any) -> Int{ return 1 }
//func innerAnyAny(p1:Any) -> Any{ return 1 }
//func innerIntInt(p1:Int) -> Int{ return 1 }
//func innerIntAny(p1:Int) -> Any{ return 1 }
//
//testVariance(innerIntAny)
//testVariance(innerAnyInt)
//testVariance(innerAnyAny)
//testVariance(innerIntInt)
//




















