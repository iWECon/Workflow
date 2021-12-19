#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public protocol Thenable {
    associatedtype T
    var value: T { get set }
}

public extension Thenable {
    
    func then<U>(_ then: (T) throws -> U) rethrows -> Workflow<U> {
        let v = try then(value)
        return Workflow { v }
    }
    
    func end(_ end: (T) throws -> Void) throws -> Void {
        try end(value)
    }
    
    func done() throws -> Void { }
}

public struct Workflow<Element>: Thenable {
    public typealias T = Element
    public var value: Element
    
    public init(_ block: () throws -> Element) rethrows {
        self.value = try block()
    }
}
