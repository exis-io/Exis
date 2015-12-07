// Straight Boilerplate-- make the compiler happy
import Foundation

public extension RiffleDomain {
	public func register(pdid: String, _ fn: () -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN>(pdid: String, _ fn: (A) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN>(pdid: String, _ fn: (A, B) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, D: CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, D: CN, E: CN>(pdid: String, _ fn: (A, B, C, D, E) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, D: CN, E: CN, F: CN>(pdid: String, _ fn: (A, B, C, D, E, F) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<R>(pdid: String, _ fn: () -> (R)) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R>(pdid: String, _ fn: (A) -> (R)) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R>(pdid: String, _ fn: (A, B) -> (R)) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R>(pdid: String, _ fn: (A, B, C) -> (R)) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, D: CN, R>(pdid: String, _ fn: (A, B, C, D) -> (R)) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, D: CN, E: CN, R>(pdid: String, _ fn: (A, B, C, D, E) -> (R)) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, D: CN, E: CN, F: CN, R>(pdid: String, _ fn: (A, B, C, D, E, F) -> (R)) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL where A.Generator.Element : CN>(pdid: String, _ fn: (A) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL where B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, D: CL where D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, D: CN where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, D: CL where C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, D: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, D: CL where B.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, D: CN where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, D: CL where B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, D: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, D: CL where A.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, D: CN where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, D: CL where A.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, D: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, D: CL where A.Generator.Element : CN, B.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, D: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, D: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _register(pdid, fn: cumin(fn))
	}

	public func subscribe(pdid: String, _ fn: () -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN>(pdid: String, _ fn: (A) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN>(pdid: String, _ fn: (A, B) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CN, D: CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CN, D: CN, E: CN>(pdid: String, _ fn: (A, B, C, D, E) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CN, D: CN, E: CN, F: CN>(pdid: String, _ fn: (A, B, C, D, E, F) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL where A.Generator.Element : CN>(pdid: String, _ fn: (A) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL where B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CL where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL, C: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL, C: CL where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN, C: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN, C: CL where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CN, D: CL where D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CL, D: CN where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CL, D: CL where C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL, C: CN, D: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL, C: CN, D: CL where B.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL, C: CL, D: CN where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL, C: CL, D: CL where B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN, C: CN, D: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN, C: CN, D: CL where A.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN, C: CL, D: CN where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN, C: CL, D: CL where A.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CN, D: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CN, D: CL where A.Generator.Element : CN, B.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CL, D: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CL, D: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CL, D: CL, E: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN, E.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D, E) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CL, D: CL, E: CL, F: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN, E.Generator.Element : CN, F.Generator.Element : CN>(pdid: String, _ fn: (A, B, C, D, E, F) -> ()) -> Deferred {
		return _subscribe(pdid, fn: cumin(fn))
	}

	public func call(pdid: String, _ args: AnyObject..., handler fn: (() -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN>(pdid: String, _ args: AnyObject..., handler fn: ((A) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN, C: CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN, C: CN, D: CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL where A.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL where B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN where A.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN, C: CL where C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL, C: CN where B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL, C: CL where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN, C: CN where A.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN, C: CL where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL, C: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL, C: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN, C: CN, D: CL where D.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN, C: CL, D: CN where C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN, C: CL, D: CL where C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL, C: CN, D: CN where B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL, C: CN, D: CL where B.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL, C: CL, D: CN where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL, C: CL, D: CL where B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN, C: CN, D: CN where A.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN, C: CN, D: CL where A.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN, C: CL, D: CN where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN, C: CL, D: CL where A.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL, C: CN, D: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL, C: CN, D: CL where A.Generator.Element : CN, B.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL, C: CL, D: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL, C: CL, D: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?) -> Deferred {
		return _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

}

public func cumin(fn: () -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<A: CN>(fn: (A) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0]) }
}

public func cumin<A: CN, B: CN>(fn: (A, B) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, C: CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, D: CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CN, B: CN, C: CN, D: CN, E: CN>(fn: (A, B, C, D, E) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3], try E.self <- a[4]) }
}

public func cumin<A: CN, B: CN, C: CN, D: CN, E: CN, F: CN>(fn: (A, B, C, D, E, F) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3], try E.self <- a[4], try F.self <- a[5]) }
}

public func cumin<R>(fn: () -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<A: CN, R>(fn: (A) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0]) }
}

public func cumin<A: CN, B: CN, R>(fn: (A, B) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, C: CN, R>(fn: (A, B, C) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, D: CN, R>(fn: (A, B, C, D) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CN, B: CN, C: CN, D: CN, E: CN, R>(fn: (A, B, C, D, E) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3], try E.self <- a[4]) }
}

public func cumin<A: CN, B: CN, C: CN, D: CN, E: CN, F: CN, R>(fn: (A, B, C, D, E, F) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3], try E.self <- a[4], try F.self <- a[5]) }
}

public func cumin<A: CL where A.Generator.Element : CN>(fn: (A) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0]) }
}

public func cumin<A: CN, B: CL where B.Generator.Element : CN>(fn: (A, B) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1]) }
}

public func cumin<A: CL, B: CN where A.Generator.Element : CN>(fn: (A, B) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1]) }
}

public func cumin<A: CL, B: CL where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, C: CL where C.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN where B.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL where B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN where A.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL where A.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, D: CL where D.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CN, B: CN, C: CL, D: CN where C.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CN, B: CN, C: CL, D: CL where C.Generator.Element : CN, D.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CN, B: CL, C: CN, D: CN where B.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CN, B: CL, C: CN, D: CL where B.Generator.Element : CN, D.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CN, B: CL, C: CL, D: CN where B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CN, B: CL, C: CL, D: CL where B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CN, C: CN, D: CN where A.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CN, C: CN, D: CL where A.Generator.Element : CN, D.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CN, C: CL, D: CN where A.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CN, C: CL, D: CL where A.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CL, C: CN, D: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CL, C: CN, D: CL where A.Generator.Element : CN, B.Generator.Element : CN, D.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CL, C: CL, D: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CL, C: CL, D: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CL, C: CL, D: CL, E: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN, E.Generator.Element : CN>(fn: (A, B, C, D, E) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3], try E.self <- a[4]) }
}

public func cumin<A: CL, B: CL, C: CL, D: CL, E: CL, F: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN, E.Generator.Element : CN, F.Generator.Element : CN>(fn: (A, B, C, D, E, F) -> ()) -> ([AnyObject]) throws -> () {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3], try E.self <- a[4], try F.self <- a[5]) }
}

public func cumin<A: CL, R where A.Generator.Element : CN>(fn: (A) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0]) }
}

public func cumin<A: CL, B: CL, R where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, C: CL, R where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, D: CL, R where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN>(fn: (A, B, C, D) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3]) }
}

public func cumin<A: CL, B: CL, C: CL, D: CL, E: CL, R where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN, E.Generator.Element : CN>(fn: (A, B, C, D, E) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3], try E.self <- a[4]) }
}

public func cumin<A: CL, B: CL, C: CL, D: CL, E: CL, F: CL, R where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, D.Generator.Element : CN, E.Generator.Element : CN, F.Generator.Element : CN>(fn: (A, B, C, D, E, F) -> (R)) -> ([AnyObject]) throws -> (R) {
	return { (a: [AnyObject]) in fn(try A.self <- a[0], try B.self <- a[1], try C.self <- a[2], try D.self <- a[3], try E.self <- a[4], try F.self <- a[5]) }
}

