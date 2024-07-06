import Foundation

public protocol Thenable {
    associatedtype Value
    var value: Value { get }
}

extension Thenable {
    
    public func map<NewValue>(_ then: (_ value: Value) throws -> NewValue) rethrows -> Workflow<NewValue> {
        let v = try then(value)
        return Workflow { v }
    }
    
    public func `do`(_ block: (_ value: Value) throws -> Void) rethrows -> Workflow<Value> {
        try block(value)
        return Workflow(value)
    }
    
    @discardableResult
    public func end() -> Value {
        value
    }
    
    @discardableResult
    public func end<End>(_ end: (_ value: Value) throws -> End) rethrows -> End {
        try end(value)
    }
}

extension Thenable where Value: Collection {
    
    public func compactMap<NewValue>(_ transform: (_ value: Value.Element) throws -> NewValue?) rethrows -> Workflow<[NewValue]> {
        try Workflow { try value.compactMap(transform) }
    }
    
    public func flatMap<Sequence>(_ transform: (_ value: Value.Element) throws -> Sequence) rethrows -> Workflow<[Sequence.Element]> where Sequence: Swift.Sequence {
        try Workflow { try value.flatMap(transform) }
    }
    
    public func filter(_ isIncluded: (_ value: Value.Element) throws -> Bool) rethrows -> Workflow<[Value.Element]> {
        try Workflow { try value.filter(isIncluded) }
    }
}

#if compiler(>=5.5) && canImport(_Concurrency)
@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Thenable where Value: Collection {
    
    public func compactMap<NewValue>(_ transform: (_ value: Value.Element) async throws -> NewValue?) async throws -> Workflow<[NewValue]> {
        try await Workflow {
            var newValues: [NewValue] = []
            for v in value {
                guard let newV = try await transform(v) else {
                    continue
                }
                newValues.append(newV)
            }
            return newValues
        }
    }
    
    public func flatMap<Sequence>(_ transform: (_ value: Value.Element) async throws -> Sequence) async throws -> Workflow<[Sequence.Element]> where Sequence: Swift.Sequence {
        try await Workflow {
            var newValues: [Sequence.Element] = []
            for v in value {
                let newV = try await transform(v)
                newValues.append(contentsOf: newV)
            }
            return newValues
        }
    }
    
    public func filter(_ isIncluded: (_ value: Value.Element) async throws -> Bool) async throws -> Workflow<[Value.Element]> {
        //try Workflow { try value.filter(isIncluded) }
        try await Workflow {
            var newValues: [Value.Element] = []
            for v in value {
                guard try await isIncluded(v) else {
                    continue
                }
                newValues.append(v)
            }
            return newValues
        }
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Thenable {
    
    public func map<NewValue>(_ then: (_ value: Value) async throws -> NewValue) async throws -> Workflow<NewValue> {
        let v = try await then(value)
        return Workflow { v }
    }
    
    public func `do`(_ block: (_ value: Value) async throws -> Void) async throws -> Workflow<Value> {
        try await block(value)
        return Workflow(value)
    }
    
    @discardableResult
    public func end<End>(_ end: (_ value: Value) async throws -> End) async throws -> End {
        try await end(value)
    }
    
}
#endif

public protocol ThenableOptional {
    associatedtype Wrapped
    var wrapped: Wrapped? { get }
}

extension Optional: ThenableOptional {
    public var wrapped: Wrapped? {
        switch self {
        case .none:
            return nil
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension Thenable where Value: ThenableOptional {
    
    public func unwrap(or error: Error) throws -> Workflow<Value.Wrapped> {
        guard let unwrappedValue = value.wrapped else {
            throw error
        }
        return Workflow { unwrappedValue }
    }
}


public struct Workflow<Element>: Thenable {
    public typealias Value = Element
    public private(set) var value: Element
    
    public init(_ value: Element) {
        self.value = value
    }
    
    public init(_ block: () throws -> Element) rethrows {
        self.value = try block()
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    public init(_ block: () async throws -> Element) async throws {
        self.value = try await block()
    }
    #endif
}
