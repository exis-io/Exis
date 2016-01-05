
import Foundation

public extension Domain {
    public func call<A: PR>(endpoint: String, _ callArguments: Any..., _ fn: (A) -> ()) -> Deferred {
        return _call(endpoint, callArguments) { args in
            fn(A.deserialize(args[0]) as! A)
        }
    }
}