import Foundation

public protocol Thenable {
    associatedtype T
    var value: T { get }
}

extension Thenable {
    
    public func map<U>(_ then: (T) throws -> U) rethrows -> Workflow<U> {
        let v = try then(value)
        return Workflow { v }
    }
    
    public func `do`(_ block: (T) throws -> Void) rethrows -> Workflow<T> {
        try block(value)
        return Workflow(value)
    }
    
    @discardableResult
    public func end() -> T {
        value
    }
    
    @discardableResult
    public func end<End>(_ end: (T) throws -> End) rethrows -> End {
        try end(value)
    }
}

#if compiler(>=5.5) && canImport(_Concurrency)
@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Thenable {
    
    public func map<U>(_ then: (T) async throws -> U) async throws -> Workflow<U> {
        let v = try await then(value)
        return Workflow { v }
    }
    
    public func `do`(_ block: (T) async throws -> Void) async throws -> Workflow<T> {
        try await block(value)
        return Workflow(value)
    }
    
    @discardableResult
    public func end<End>(_ end: (T) async throws -> End) async throws -> End {
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

extension Thenable where T: ThenableOptional {
    
    public func unwrap(or error: Error) throws -> Workflow<T.Wrapped> {
        guard let unwrappedValue = value.wrapped else {
            throw error
        }
        return Workflow { unwrappedValue }
    }
}


public struct Workflow<Element>: Thenable {
    public typealias T = Element
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
