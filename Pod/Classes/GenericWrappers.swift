// Straight Boilerplate-- make the compiler happy
import Foundation

public extension RiffleSession {
	public func register(pdid: String, _ fn: () -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN>(pdid: String, _ fn: (A) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL where A.Generator.Element : CN>(pdid: String, _ fn: (A) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN>(pdid: String, _ fn: (A, B) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL where B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CN>(pdid: String, _ fn: () -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CL where R.Generator.Element : CN>(pdid: String, _ fn: () -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CN>(pdid: String, _ fn: (A) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CL where R.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CL where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CN>(pdid: String, _ fn: (A, B) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CL where R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CL where B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CL where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CL where R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CN where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CL where C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CL where B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CN where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CL where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CL where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CN where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CL where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CN, S: CN>(pdid: String, _ fn: () -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CN, S: CL where S.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CL, S: CN where R.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CL, S: CL where R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CN, S: CN>(pdid: String, _ fn: (A) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CN, S: CL where S.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CL, S: CN where R.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CL, S: CL where R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CN, S: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CN, S: CL where A.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CL, S: CN where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CL, S: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CN, S: CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CN, S: CL where S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CL, S: CN where R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CL, S: CL where R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CN, S: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CN, S: CL where B.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CL, S: CN where B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CL, S: CL where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CN, S: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CN, S: CL where A.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CL, S: CN where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CL, S: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CN, S: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CN, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CL, S: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CL, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CN, S: CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CN, S: CL where S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CL, S: CN where R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CL, S: CL where R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CN, S: CN where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CN, S: CL where C.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CL, S: CN where C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CL, S: CL where C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CN, S: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CN, S: CL where B.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CL, S: CN where B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CL, S: CL where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CN, S: CN where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CN, S: CL where B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CL, S: CN where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CL, S: CL where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CN, S: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CN, S: CL where A.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CL, S: CN where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CL, S: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CN, S: CN where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CN, S: CL where A.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CL, S: CN where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CL, S: CL where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CN, S: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CN, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CL, S: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CL, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CN, S: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CN, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CL, S: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CL, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CN, S: CN, T: CN>(pdid: String, _ fn: () -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CN, S: CN, T: CL where T.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CN, S: CL, T: CN where S.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CN, S: CL, T: CL where S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CL, S: CN, T: CN where R.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CL, S: CN, T: CL where R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CL, S: CL, T: CN where R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<R: CL, S: CL, T: CL where R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: () -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CN, S: CN, T: CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CN, S: CN, T: CL where T.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CN, S: CL, T: CN where S.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CN, S: CL, T: CL where S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CL, S: CN, T: CN where R.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CL, S: CN, T: CL where R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CL, S: CL, T: CN where R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, R: CL, S: CL, T: CL where R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CN, S: CN, T: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CN, S: CN, T: CL where A.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CN, S: CL, T: CN where A.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CN, S: CL, T: CL where A.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CL, S: CN, T: CN where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CL, S: CN, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CL, S: CL, T: CN where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, R: CL, S: CL, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CN, S: CN, T: CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CN, S: CN, T: CL where T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CN, S: CL, T: CN where S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CN, S: CL, T: CL where S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CL, S: CN, T: CN where R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CL, S: CN, T: CL where R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CL, S: CL, T: CN where R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, R: CL, S: CL, T: CL where R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CN, S: CN, T: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CN, S: CN, T: CL where B.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CN, S: CL, T: CN where B.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CN, S: CL, T: CL where B.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CL, S: CN, T: CN where B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CL, S: CN, T: CL where B.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CL, S: CL, T: CN where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, R: CL, S: CL, T: CL where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CN, S: CN, T: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CN, S: CN, T: CL where A.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CN, S: CL, T: CN where A.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CN, S: CL, T: CL where A.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CL, S: CN, T: CN where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CL, S: CN, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CL, S: CL, T: CN where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, R: CL, S: CL, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CN, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CN, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CN, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CN, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CL, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CL, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CL, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, R: CL, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CN, S: CN, T: CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CN, S: CN, T: CL where T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CN, S: CL, T: CN where S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CN, S: CL, T: CL where S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CL, S: CN, T: CN where R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CL, S: CN, T: CL where R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CL, S: CL, T: CN where R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CN, R: CL, S: CL, T: CL where R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CN, S: CN, T: CN where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CN, S: CN, T: CL where C.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CN, S: CL, T: CN where C.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CN, S: CL, T: CL where C.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CL, S: CN, T: CN where C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CL, S: CN, T: CL where C.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CL, S: CL, T: CN where C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CN, C: CL, R: CL, S: CL, T: CL where C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CN, S: CN, T: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CN, S: CN, T: CL where B.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CN, S: CL, T: CN where B.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CN, S: CL, T: CL where B.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CL, S: CN, T: CN where B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CL, S: CN, T: CL where B.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CL, S: CL, T: CN where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CN, R: CL, S: CL, T: CL where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CN, S: CN, T: CN where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CN, S: CN, T: CL where B.Generator.Element : CN, C.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CN, S: CL, T: CN where B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CN, S: CL, T: CL where B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CL, S: CN, T: CN where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CL, S: CN, T: CL where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CL, S: CL, T: CN where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CN, B: CL, C: CL, R: CL, S: CL, T: CL where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CN, S: CN, T: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CN, S: CN, T: CL where A.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CN, S: CL, T: CN where A.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CN, S: CL, T: CL where A.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CL, S: CN, T: CN where A.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CL, S: CN, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CL, S: CL, T: CN where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CN, R: CL, S: CL, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CN, S: CN, T: CN where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CN, S: CN, T: CL where A.Generator.Element : CN, C.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CN, S: CL, T: CN where A.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CN, S: CL, T: CL where A.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CL, S: CN, T: CN where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CL, S: CN, T: CL where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CL, S: CL, T: CN where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CN, C: CL, R: CL, S: CL, T: CL where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CN, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CN, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CN, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CN, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CL, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CL, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CL, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CN, R: CL, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CN, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CN, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CN, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CN, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CL, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CL, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CL, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func register<A: CL, B: CL, C: CL, R: CL, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
		_register(pdid, fn: cumin(fn))
	}

	public func subscribe(pdid: String, _ fn: () -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN>(pdid: String, _ fn: (A) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL where A.Generator.Element : CN>(pdid: String, _ fn: (A) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN>(pdid: String, _ fn: (A, B) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL where B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CN, C: CL where C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL, C: CN where B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CN, B: CL, C: CL where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN, C: CN where A.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CN, C: CL where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func subscribe<A: CL, B: CL, C: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ fn: (A, B, C) -> ())  {
		_subscribe(pdid, fn: cumin(fn))
	}

	public func call(pdid: String, _ args: AnyObject..., handler fn: (() -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN>(pdid: String, _ args: AnyObject..., handler fn: ((A) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL where A.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL where B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN where A.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN, C: CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CN, C: CL where C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL, C: CN where B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CN, B: CL, C: CL where B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN, C: CN where A.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CN, C: CL where A.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL, C: CN where A.Generator.Element : CN, B.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

	public func call<A: CL, B: CL, C: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
		_call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
	}

}

public func cumin(fn: () -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<A: CN>(fn: (A) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL where A.Generator.Element : CN>(fn: (A) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, B: CN>(fn: (A, B) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL where B.Generator.Element : CN>(fn: (A, B) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN where A.Generator.Element : CN>(fn: (A, B) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, C: CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL where C.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN where B.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL where B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN where A.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL where A.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<R: CN>(fn: () -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CL where R.Generator.Element : CN>(fn: () -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<A: CN, R: CN>(fn: (A) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CL where R.Generator.Element : CN>(fn: (A) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CN where A.Generator.Element : CN>(fn: (A) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CL where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, B: CN, R: CN>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CL where R.Generator.Element : CN>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CN where B.Generator.Element : CN>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CL where B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CN where A.Generator.Element : CN>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CL where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CL where R.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CN where C.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CL where C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CN where B.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CL where B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CN where B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CL where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CN where A.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CL where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CN where A.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CL where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<R: CN, S: CN>(fn: () -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CN, S: CL where S.Generator.Element : CN>(fn: () -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CL, S: CN where R.Generator.Element : CN>(fn: () -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CL, S: CL where R.Generator.Element : CN, S.Generator.Element : CN>(fn: () -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<A: CN, R: CN, S: CN>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CN, S: CL where S.Generator.Element : CN>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CL, S: CN where R.Generator.Element : CN>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CL, S: CL where R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CN, S: CN where A.Generator.Element : CN>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CN, S: CL where A.Generator.Element : CN, S.Generator.Element : CN>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CL, S: CN where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CL, S: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, B: CN, R: CN, S: CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CN, S: CL where S.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CL, S: CN where R.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CL, S: CL where R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CN, S: CN where B.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CN, S: CL where B.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CL, S: CN where B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CL, S: CL where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CN, S: CN where A.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CN, S: CL where A.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CL, S: CN where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CL, S: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CN, S: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CN, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CL, S: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CL, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CN, S: CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CN, S: CL where S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CL, S: CN where R.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CL, S: CL where R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CN, S: CN where C.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CN, S: CL where C.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CL, S: CN where C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CL, S: CL where C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CN, S: CN where B.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CN, S: CL where B.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CL, S: CN where B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CL, S: CL where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CN, S: CN where B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CN, S: CL where B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CL, S: CN where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CL, S: CL where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CN, S: CN where A.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CN, S: CL where A.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CL, S: CN where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CL, S: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CN, S: CN where A.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CN, S: CL where A.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CL, S: CN where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CL, S: CL where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CN, S: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CN, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CL, S: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CL, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CN, S: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CN, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CL, S: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CL, S: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<R: CN, S: CN, T: CN>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CN, S: CN, T: CL where T.Generator.Element : CN>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CN, S: CL, T: CN where S.Generator.Element : CN>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CN, S: CL, T: CL where S.Generator.Element : CN, T.Generator.Element : CN>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CL, S: CN, T: CN where R.Generator.Element : CN>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CL, S: CN, T: CL where R.Generator.Element : CN, T.Generator.Element : CN>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CL, S: CL, T: CN where R.Generator.Element : CN, S.Generator.Element : CN>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<R: CL, S: CL, T: CL where R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn() }
}

public func cumin<A: CN, R: CN, S: CN, T: CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CN, S: CN, T: CL where T.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CN, S: CL, T: CN where S.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CN, S: CL, T: CL where S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CL, S: CN, T: CN where R.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CL, S: CN, T: CL where R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CL, S: CL, T: CN where R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, R: CL, S: CL, T: CL where R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CN, S: CN, T: CN where A.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CN, S: CN, T: CL where A.Generator.Element : CN, T.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CN, S: CL, T: CN where A.Generator.Element : CN, S.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CN, S: CL, T: CL where A.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CL, S: CN, T: CN where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CL, S: CN, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CL, S: CL, T: CN where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CL, R: CL, S: CL, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0]) }
}

public func cumin<A: CN, B: CN, R: CN, S: CN, T: CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CN, S: CN, T: CL where T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CN, S: CL, T: CN where S.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CN, S: CL, T: CL where S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CL, S: CN, T: CN where R.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CL, S: CN, T: CL where R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CL, S: CL, T: CN where R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, R: CL, S: CL, T: CL where R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CN, S: CN, T: CN where B.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CN, S: CN, T: CL where B.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CN, S: CL, T: CN where B.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CN, S: CL, T: CL where B.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CL, S: CN, T: CN where B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CL, S: CN, T: CL where B.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CL, S: CL, T: CN where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CL, R: CL, S: CL, T: CL where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CN, S: CN, T: CN where A.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CN, S: CN, T: CL where A.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CN, S: CL, T: CN where A.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CN, S: CL, T: CL where A.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CL, S: CN, T: CN where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CL, S: CN, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CL, S: CL, T: CN where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CN, R: CL, S: CL, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CN, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CN, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CN, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CN, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CL, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CL, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CL, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CL, B: CL, R: CL, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CN, S: CN, T: CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CN, S: CN, T: CL where T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CN, S: CL, T: CN where S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CN, S: CL, T: CL where S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CL, S: CN, T: CN where R.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CL, S: CN, T: CL where R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CL, S: CL, T: CN where R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CN, R: CL, S: CL, T: CL where R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CN, S: CN, T: CN where C.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CN, S: CN, T: CL where C.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CN, S: CL, T: CN where C.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CN, S: CL, T: CL where C.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CL, S: CN, T: CN where C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CL, S: CN, T: CL where C.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CL, S: CL, T: CN where C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CN, C: CL, R: CL, S: CL, T: CL where C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CN, S: CN, T: CN where B.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CN, S: CN, T: CL where B.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CN, S: CL, T: CN where B.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CN, S: CL, T: CL where B.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CL, S: CN, T: CN where B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CL, S: CN, T: CL where B.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CL, S: CL, T: CN where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CN, R: CL, S: CL, T: CL where B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CN, S: CN, T: CN where B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CN, S: CN, T: CL where B.Generator.Element : CN, C.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CN, S: CL, T: CN where B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CN, S: CL, T: CL where B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CL, S: CN, T: CN where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CL, S: CN, T: CL where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CL, S: CL, T: CN where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CN, B: CL, C: CL, R: CL, S: CL, T: CL where B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CN, S: CN, T: CN where A.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CN, S: CN, T: CL where A.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CN, S: CL, T: CN where A.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CN, S: CL, T: CL where A.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CL, S: CN, T: CN where A.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CL, S: CN, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CL, S: CL, T: CN where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CN, R: CL, S: CL, T: CL where A.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CN, S: CN, T: CN where A.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CN, S: CN, T: CL where A.Generator.Element : CN, C.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CN, S: CL, T: CN where A.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CN, S: CL, T: CL where A.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CL, S: CN, T: CN where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CL, S: CN, T: CL where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CL, S: CL, T: CN where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CN, C: CL, R: CL, S: CL, T: CL where A.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CN, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CN, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CN, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CN, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CL, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CL, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CL, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CN, R: CL, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CN, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CN, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CN, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CN, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CL, S: CN, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CL, S: CN, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CL, S: CL, T: CN where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

public func cumin<A: CL, B: CL, C: CL, R: CL, S: CL, T: CL where A.Generator.Element : CN, B.Generator.Element : CN, C.Generator.Element : CN, R.Generator.Element : CN, S.Generator.Element : CN, T.Generator.Element : CN>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
	return { (a: [AnyObject]) in fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
}

