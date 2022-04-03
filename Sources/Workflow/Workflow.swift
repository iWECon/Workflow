import Foundation

public protocol Thenable {
    associatedtype T
    var value: T { get set }
}

public extension Thenable {
    
    func then<U>(_ then: (T) throws -> U) throws -> Workflow<U> {
        let v = try then(value)
        return try Workflow { v }
    }
    
    func end(_ end: (T) throws -> Void) throws -> Void {
        try end(value)
    }
    
    func done() throws -> Void { }
}

#if compiler(>=5.5) && canImport(_Concurrency)
@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public extension Thenable {
    
    func then<U>(_ then: (T) async throws -> U) async throws -> Workflow<U> {
        let v = try await then(value)
        return try Workflow { v }
    }
    
    func end(_ end: (T) async throws -> Void) async throws -> Void {
        try await end(value)
    }
    
    func done() async throws -> Void { }
    
}
#endif

public struct Workflow<Element>: Thenable {
    public typealias T = Element
    public var value: Element
    
    public init(_ block: () throws -> Element) throws {
        self.value = try block()
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    public init(_ block: () async throws -> Element) async throws {
        self.value = try await block()
    }
    #endif
}
