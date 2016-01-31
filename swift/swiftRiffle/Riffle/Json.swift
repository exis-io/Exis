import Foundation
import CoreFoundation

#if os(Linux)
    import SwiftGlibc
    import Glibc
#else
    import Darwin.C
#endif

let unescapeMapping: [UnicodeScalar: UnicodeScalar] = [
    "t": "\t",
    "r": "\r",
    "n": "\n"
]

let escapeMapping: [Character: String] = [
    "\r": "\\r",
    "\n": "\\n",
    "\t": "\\t",
    "\\": "\\\\",
    "\"": "\\\"",

    "\u{2028}": "\\u2028",
    "\u{2029}": "\\u2029",

    "\r\n": "\\r\\n"
]

let hexMapping: [UnicodeScalar: UInt32] = [
    "0": 0x0,
    "1": 0x1,
    "2": 0x2,
    "3": 0x3,
    "4": 0x4,
    "5": 0x5,
    "6": 0x6,
    "7": 0x7,
    "8": 0x8,
    "9": 0x9,
    "a": 0xA, "A": 0xA,
    "b": 0xB, "B": 0xB,
    "c": 0xC, "C": 0xC,
    "d": 0xD, "D": 0xD,
    "e": 0xE, "E": 0xE,
    "f": 0xF, "F": 0xF
]

let digitMapping: [UnicodeScalar:Int] = [
    "0": 0,
    "1": 1,
    "2": 2,
    "3": 3,
    "4": 4,
    "5": 5,
    "6": 6,
    "7": 7,
    "8": 8,
    "9": 9
]

public func escapeAsJSONString(source : String) -> String {
    var s = "\""

    for c in source.characters {
        if let escapedSymbol = escapeMapping[c] {
            s.appendContentsOf(escapedSymbol)
        } else {
            s.append(c)
        }
    }

    s.appendContentsOf("\"")

    return s
}

func digitToInt(byte: UInt8) -> Int? {
    return digitMapping[UnicodeScalar(byte)]
}

func hexToDigit(byte: UInt8) -> UInt32? {
    return hexMapping[UnicodeScalar(byte)]
}

public protocol JSONSerializer {
    func serialize(JSONValue: JSON) -> String
}

public class DefaultJSONSerializer: JSONSerializer {
    public init() {}
    
    public func serialize(JSONValue: JSON) -> String {
        switch JSONValue {
        case .NullValue: return "null"
        case .BooleanValue(let b): return b ? "true" : "false"
        case .NumberValue(let n): return serializeNumber(n)
        case .StringValue(let s): return escapeAsJSONString(s)
        case .ArrayValue(let a): return serializeArray(a)
        case .ObjectValue(let o): return serializeObject(o)
        }
    }

    func serializeNumber(n: Double) -> String {
        if n == Double(Int64(n)) {
            return Int64(n).description
        } else {
            return n.description
        }
    }

    func serializeArray(a: [JSON]) -> String {
        var s = "["

        for (i, _) in a.enumerate() {
        // for var i = 0; i < a.count; i += 1 {
            s += a[i].serialize(self)

            if i != (a.count - 1) {
                s += ","
            }
        }

        return s + "]"
    }

    func serializeObject(o: [String: JSON]) -> String {
        var s = "{"
        var i = 0

        for entry in o {
            s += "\(escapeAsJSONString(entry.0)):\(entry.1.serialize(self))"
            i += 1

            if i != (o.count - 1) {
                s += ","
            }
        }

        return s + "}"
    }
}

public final class PrettyJSONSerializer: DefaultJSONSerializer {
    var indentLevel = 0

    override public func serializeArray(a: [JSON]) -> String {
        var s = "["
        indentLevel += 1

        for (i, _) in a.enumerate() {
        // for var i = 0; i < a.count; i += 1 {
            s += "\n"
            s += indent()
            s += a[i].serialize(self)

            if i != (a.count - 1) {
                s += ","
            }
        }

        indentLevel -= 1
        return s + "\n" + indent() + "]"
    }

    override public func serializeObject(o: [String: JSON]) -> String {
        var s = "{"
        indentLevel += 1
        var i = 0

        var keys = Array(o.keys)
        keys.sortInPlace()

        for key in keys {
            s += "\n"
            s += indent()
            s += "\(escapeAsJSONString(key)): \(o[key]!.serialize(self))"

            i += 1
            if i != (o.count - 1) {
                s += ","
            }
        }

        indentLevel -= 1
        return s + "\n" + indent() + "}"
    }

    func indent() -> String {
        var s = ""

        var i = 0
        while i < indentLevel {
        // for var i = 0; i < indentLevel; i += 1 {
            s += "    "
            i += 1
        }

        return s
    }
}

public enum JSON {
    case NullValue
    case BooleanValue(Bool)
    case NumberValue(Double)
    case StringValue(String)
    case ArrayValue([JSON])
    case ObjectValue([String: JSON])

    
    
    public static func from(value: Bool) -> JSON {
        return .BooleanValue(value)
    }

    public static func from(value: Double) -> JSON {
        return .NumberValue(value)
    }

    public static func from(value: String) -> JSON {
        return .StringValue(value)
    }

    public static func from(value: [JSON]) -> JSON {
        return .ArrayValue(value)
    }

    public static func from(value: [String: JSON]) -> JSON {
        return .ObjectValue(value)
    }

    public static func from(values: [Any]) -> JSON {
        var jsonArray: [JSON] = []
        for value in values {
            
            if let value = value as? Bool {
                jsonArray.append(JSON.from(value))
            }
            else if let value = value as? Double {
                jsonArray.append(JSON.from(value))
            }
            else if let value = value as? Int {
                jsonArray.append(JSON.from(Double(value)))
            }
            else if let value = value as? String {
                jsonArray.append(JSON.from(value))
            }
                
            // Covariance hacks for arrays
            else if let arr = value as? [String] {
                jsonArray.append(JSON.from(arr.map { $0 as Any }))
            }
            else if let arr = value as? [Double] {
                jsonArray.append(JSON.from(arr.map { $0 as Any }))
            }
            else if let arr = value as? [Int] {
                jsonArray.append(JSON.from(arr.map { $0 as Any }))
            }
            else if let arr = value as? [Bool] {
                jsonArray.append(JSON.from(arr.map { $0 as Any }))
            }
            else if let value = value as? [Any] {
                jsonArray.append(JSON.from(value))
            }
                
            // Covariance hacks for dictionaries
            else if let dict = value as? [String: NSObject] {
                var rebuild: [String: Any] = [:]
                _ = dict.map { rebuild[$0] = $1 as Any}
                
                jsonArray.append(JSON.from(rebuild))
            }
            else if let value = value as? [String: Any] {
                jsonArray.append(JSON.from(value))
            }
            else {
                print("WARN: Cant json value: \(value) of type: \(value.dynamicType)")
            }
        }
        
        return JSON.from(jsonArray)
    }

    public static func from(value: [String: Any]) -> JSON {
        var jsonDictionary: [String: JSON] = [:]
        for (key, value) in value {
            if let value = value as? Bool {
                jsonDictionary[key] = JSON.from(value)
            }
            if let value = value as? Double {
                jsonDictionary[key] = JSON.from(value)
            }
            if let value = value as? Float {
                jsonDictionary[key] = JSON.from(Double(value))
            }
            if let value = value as? Int {
                jsonDictionary[key] = JSON.from(Double(value))
            }
            if let value = value as? String {
                jsonDictionary[key] = JSON.from(value)
            }
            if let value = value as? [Any] {
                jsonDictionary[key] = JSON.from(value)
            }
            if let value = value as? [String: Any] {
                jsonDictionary[key] = JSON.from(value)
            }
        }

        return JSON.from(jsonDictionary)
    }

    public var isBoolean: Bool {
        switch self {
        case .BooleanValue: return true
        default: return false
        }
    }

    public var isNumber: Bool {
        switch self {
        case .NumberValue: return true
        default: return false
        }
    }

    public var isString: Bool {
        switch self {
        case .StringValue: return true
        default: return false
        }
    }

    public var isArray: Bool {
        switch self {
        case .ArrayValue: return true
        default: return false
        }
    }

    public var isObject: Bool {
        switch self {
        case .ObjectValue: return true
        default: return false
        }
    }

    public var boolValue: Bool? {
        switch self {
        case .BooleanValue(let b): return b
        default: return nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case .NumberValue(let n): return n
        default: return nil
        }
    }

    public var intValue: Int? {
        if let v = doubleValue {
            return Int(v)
        }
        return nil
    }
    
    public var value: Any {
        switch self {
        case .NumberValue: return Int(doubleValue!)
        case .StringValue(let s): return s
        default:
            print("JSON WARN: Unable to extract any value!")
            return 0
        }
    }

    public var uintValue: UInt? {
        if let v = doubleValue {
            return UInt(v)
        }
        return nil
    }

    public var stringValue: String? {
        switch self {
        case .StringValue(let s): return s
        default: return nil
        }
    }

    public var arrayValue: [JSON]? {
        switch self {
        case .ArrayValue(let array): return array
        default: return nil
        }
    }

    public var dictionaryValue: [String: JSON]? {
        switch self {
        case .ObjectValue(let dictionary): return dictionary
        default: return nil
        }
    }

    public subscript(index: UInt) -> JSON? {
        set {
            switch self {
            case .ArrayValue(let a):
                var a = a
                if Int(index) < a.count {
                    if let json = newValue {
                        a[Int(index)] = json
                    } else {
                        a[Int(index)] = .NullValue
                    }
                    self = .ArrayValue(a)
                }
            default: break
            }
        }
        get {
            switch self {
            case .ArrayValue(let a):
                return Int(index) < a.count ? a[Int(index)] : nil
            default: return nil
            }
        }
    }

    public subscript(key: String) -> JSON? {
        set {
            switch self {
            case .ObjectValue(let o):
                var o = o 
                o[key] = newValue
                self = .ObjectValue(o)
            default: break
            }
        }
        get {
            switch self {
            case .ObjectValue(let o):
                return o[key]
            default: return nil
            }
        }
    }

    public func serialize(serializer: JSONSerializer) -> String {
        return serializer.serialize(self)
    }
}

extension JSON: CustomStringConvertible {
    public var description: String {
        return serialize(DefaultJSONSerializer())
    }
}

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return serialize(PrettyJSONSerializer())
    }
}

extension JSON: Equatable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch lhs {
    case .NullValue:
        switch rhs {
        case .NullValue: return true
        default: return false
        }
    case .BooleanValue(let lhsValue):
        switch rhs {
        case .BooleanValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .StringValue(let lhsValue):
        switch rhs {
        case .StringValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .NumberValue(let lhsValue):
        switch rhs {
        case .NumberValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .ArrayValue(let lhsValue):
        switch rhs {
        case .ArrayValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .ObjectValue(let lhsValue):
        switch rhs {
        case .ObjectValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    }
}

extension JSON: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .NullValue
    }
}

extension JSON: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .BooleanValue(value)
    }
}

extension JSON: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .NumberValue(Double(value))
    }
}

extension JSON: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .NumberValue(Double(value))
    }
}

extension JSON: StringLiteralConvertible {
    public typealias UnicodeScalarLiteralType = String

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .StringValue(value)
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType) {
        self = .StringValue(value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self = .StringValue(value)
    }
}

extension JSON: ArrayLiteralConvertible {
    public init(arrayLiteral elements: JSON...) {
        self = .ArrayValue(elements)
    }
}

extension JSON: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dictionary = [String: JSON](minimumCapacity: elements.count)

        for pair in elements {
            dictionary[pair.0] = pair.1
        }
        
        self = .ObjectValue(dictionary)
    }
}

enum JSONParseError: ErrorType, CustomStringConvertible {
    case UnexpectedTokenError(reason: String, lineNumber: Int, columnNumber: Int)
    case InsufficientTokenError(reason: String, lineNumber: Int, columnNumber: Int)
    case ExtraTokenError(reason: String, lineNumber: Int, columnNumber: Int)
    case NonStringKeyError(reason: String, lineNumber: Int, columnNumber: Int)
    case InvalidStringError(reason: String, lineNumber: Int, columnNumber: Int)
    case InvalidNumberError(reason: String, lineNumber: Int, columnNumber: Int)

    var description: String {
        switch self {
        case UnexpectedTokenError(let r, let l, let c):
            return "UnexpectedTokenError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case InsufficientTokenError(let r, let l, let c):
            return "InsufficientTokenError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case ExtraTokenError(let r, let l, let c):
            return "ExtraTokenError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case NonStringKeyError(let r, let l, let c):
            return "NonStringKeyError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case InvalidStringError(let r, let l, let c):
            return "InvalidStringError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case InvalidNumberError(let r, let l, let c):
            return "InvalidNumberError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        }
    }
}



public struct JSONParser {
    public static func parse(source: String) throws -> Any {
        return try GenericJSONParser(source.utf8).parse()
    }

    public static func parse(source: [UInt8]) throws -> Any {
        return try GenericJSONParser(source).parse()
    }

    public static func parse(source: [Int8]) throws -> Any {
        return try parse(source.map({UInt8($0)}))
    }
}

public class GenericJSONParser<ByteSequence: CollectionType where ByteSequence.Generator.Element == UInt8> {
    public typealias Source = ByteSequence
    typealias Char = Source.Generator.Element

    let source: Source
    var cur: Source.Index
    let end: Source.Index

    public var lineNumber = 1
    public var columnNumber = 1

    public init(_ source: Source) {
        self.source = source
        self.cur = source.startIndex
        self.end = source.endIndex
    }

    public func parse() throws -> Any {
        let JSON = try parseValue()
        
        skipWhitespaces()
        
        if (cur == end) {
            return JSON
        } else {
            throw JSONParseError.ExtraTokenError(
                reason: "extra tokens foundd",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }
    }
}

extension GenericJSONParser {
    private func parseValue() throws -> Any {
        skipWhitespaces()
        
        if cur == end {
            throw JSONParseError.InsufficientTokenError(
                reason: "unexpected end of tokens",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }
        
        switch currentChar {
        case Char(ascii: "n"): return try parseSymbol("null", NSNull())
        case Char(ascii: "t"): return try parseSymbol("true", true)
        case Char(ascii: "f"): return try parseSymbol("false", false)
        case Char(ascii: "-"), Char(ascii: "0") ... Char(ascii: "9"): return try parseNumber()
        case Char(ascii: "\""): return try parseString()
        case Char(ascii: "{"): return try parseObject()
        case Char(ascii: "["): return try parseArray()
        case (let c): throw JSONParseError.UnexpectedTokenError(
            reason: "unexpected token: \(c)",
            lineNumber: lineNumber,
            columnNumber: columnNumber
        )
        }
    }

    private var currentChar: Char {
        return source[cur]
    }

    private var nextChar: Char {
        return source[cur.successor()]
    }

    private var currentSymbol: Character {
        return Character(UnicodeScalar(currentChar))
    }

    private func parseSymbol(target: StaticString, @autoclosure _ iftrue: Void -> Any) throws -> Any {
        if expect(target) {
            return iftrue()
        } else {
            throw JSONParseError.UnexpectedTokenError(
                reason: "expected \"\(target)\" but \(currentSymbol)",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }
    }

    private func parseString() throws -> Any {
        assert(currentChar == Char(ascii: "\""), "points a double quote")
        advance()
        var buffer: [CChar] = []

        while cur != end {
        // LOOP: for ; cur != end; advance() {
            var breakLoop = false

            switch currentChar {
            case Char(ascii: "\\"):
                advance()
                if (cur == end) {
                    throw JSONParseError.InvalidStringError(
                        reason: "unexpected end of a string literal",
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    )
                }

                if let c = parseEscapedChar() {
                    for u in String(c).utf8 {
                        buffer.append(CChar(bitPattern: u))
                    }
                } else {
                    throw JSONParseError.InvalidStringError(
                        reason: "invalid escape sequence",
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    )
                }
            case Char(ascii: "\""): 
                breakLoop = true
                // break LOOP
            default: buffer.append(CChar(bitPattern: currentChar))
            }

            if breakLoop {
                break
            }

            advance()
        }

        if !expect("\"") {
            throw JSONParseError.InvalidStringError(
                reason: "missing double quote",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }

        buffer.append(0)
        let s = String.fromCString(buffer)!
        return s
    }

    private func parseEscapedChar() -> UnicodeScalar? {
        let c = UnicodeScalar(currentChar)

        if c == "u" {
            var length = 0
            var value: UInt32 = 0

            while let d = hexToDigit(nextChar) {
                advance()
                length += 1

                if length > 8 {
                    break
                }

                value = (value << 4) | d
            }

            if length < 2 {
                return nil
            }

            return UnicodeScalar(value)
        } else {
            let c = UnicodeScalar(currentChar)
            return unescapeMapping[c] ?? c
        }
    }

    private func parseNumber() throws -> Any {
        let sign = expect("-") ? -1.0 : 1.0
        var integer: Int64 = 0

        switch currentChar {
        case Char(ascii: "0"): advance()
        case Char(ascii: "1") ... Char(ascii: "9"):
            while cur != end {
                if let value = digitToInt(currentChar) {
                    integer = (integer * 10) + Int64(value)
                } else {
                    break
                }

                advance()
            }
        default:
            throw JSONParseError.InvalidStringError(
                reason: "missing double quote",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }

        if integer != Int64(Double(integer)) {
            throw JSONParseError.InvalidNumberError(
                reason: "too large number",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }

        var fraction: Double = 0.0

        if expect(".") {
            var factor = 0.1
            var fractionLength = 0

            while cur != end {
                if let value = digitToInt(currentChar) {
                    fraction += (Double(value) * factor)
                    factor /= 10
                    fractionLength += 1
                } else {
                    break
                }

                advance()
            }

            if fractionLength == 0 {
                throw JSONParseError.InvalidNumberError(
                    reason: "insufficient fraction part in number",
                    lineNumber: lineNumber,
                    columnNumber: columnNumber
                )
            }
        }

        var exponent: Int64 = 0

        if expect("e") || expect("E") {
            var expSign: Int64 = 1

            if expect("-") {
                expSign = -1
            } else if expect("+") {}

            exponent = 0
            var exponentLength = 0

            while cur != end {
                if let value = digitToInt(currentChar) {
                    exponent = (exponent * 10) + Int64(value)
                    exponentLength += 1
                } else {
                    break
                }

                advance()
            }

            if exponentLength == 0 {
                throw JSONParseError.InvalidNumberError(
                    reason: "insufficient exponent part in number",
                    lineNumber: lineNumber,
                    columnNumber: columnNumber
                )
            }

            exponent *= expSign
        }

        return sign * (Double(integer) + fraction) * pow(10, Double(exponent))
    }

    private func parseObject() throws -> Any {
        assert(currentChar == Char(ascii: "{"), "points \"{\"")
        advance()
        skipWhitespaces()
        var object: [String: Any] = [:]

        LOOP: while cur != end && !expect("}") {
            let keyValue = try parseValue()

            if let key = keyValue as? String {
                skipWhitespaces()

                if !expect(":") {
                    throw JSONParseError.UnexpectedTokenError(
                        reason: "missing colon (:)",
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    )
                }

                skipWhitespaces()
                let value = try parseValue()
                object[key] = value
                skipWhitespaces()

                if expect(",") {
                    continue
                } else if expect("}") {
                    break LOOP
                } else {
                    throw JSONParseError.UnexpectedTokenError(
                        reason: "missing comma (,)",
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    )
                }
            } else {
                throw JSONParseError.NonStringKeyError(
                    reason: "unexpected value for object key",
                    lineNumber: lineNumber,
                    columnNumber: columnNumber
                )
            }
        }

        return object
    }

    private func parseArray() throws -> Any {
        assert(currentChar == Char(ascii: "["), "points \"[\"")
        advance()
        skipWhitespaces()

        var array: [Any] = []

        // Another example of the loop break 
        LOOP: while cur != end && !expect("]") {
            let JSON = try parseValue()
            skipWhitespaces()
            array.append(JSON)
            
            if expect(",") {
                continue
            } else if expect("]") {
                break LOOP
            } else {
                throw JSONParseError.UnexpectedTokenError(
                    reason: "missing comma (,) (token: \(currentSymbol))",
                    lineNumber: lineNumber,
                    columnNumber: columnNumber
                )
            }
        }
        
        return array
    }
    
    
    private func expect(target: StaticString) -> Bool {
        if cur == end {
            return false
        }
        
        if !isIdentifier(target.utf8Start.memory) {
            if target.utf8Start.memory == currentChar {
                advance()
                return true
            } else {
                return false
            }
        }
        
        let start = cur
        let l = lineNumber
        let c = columnNumber
        
        var p = target.utf8Start
        let endp = p.advancedBy(Int(target.byteSize))
        
        while p != endp {
            if p.memory != currentChar {
                cur = start
                lineNumber = l
                columnNumber = c
                return false
            }

            p += 1
            advance()
        }
        
        return true
    }
    
    // only "true", "false", "null" are identifiers
    private func isIdentifier(char: Char) -> Bool {
        switch char {
        case Char(ascii: "a") ... Char(ascii: "z"):
            return true
        default:
            return false
        }
    }
    
    private func advance() {
        assert(cur != end, "out of range")
        cur++

        if cur != end {
            switch currentChar {
                
            case Char(ascii: "\n"):
                lineNumber += 1
                columnNumber = 1
                
            default:
                columnNumber += 1
            }
        }
    }
    
    private func skipWhitespaces() {
        while cur != end {
            switch currentChar {
            case Char(ascii: " "), Char(ascii: "\t"), Char(ascii: "\r"), Char(ascii: "\n"):
                break
            default:
                return
            }

            advance()
        }
    }
}

// Convert parsed JSON to Any, because why the hell do you think everyone wants to manually query their json?
func anynize(from: JSON) -> Any {
    switch from {
    case .NullValue:
        return NSNull()
    case .BooleanValue:
        return from.boolValue!
    case .StringValue:
        return from.stringValue!
    case .NumberValue:
        return from.doubleValue!
    case .ArrayValue:
        return from.arrayValue!.map { anynize($0) }
    case .ObjectValue:
        var ret: [String: Any] = [:]
        for (k, v) in from.dictionaryValue! {
            ret[k] = anynize(v)
        }
        
        return ret
    }
}
