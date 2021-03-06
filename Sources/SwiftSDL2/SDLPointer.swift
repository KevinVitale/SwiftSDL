import Foundation
import CSDL2

public class SDLPointer<T: SDLType>: Hashable, Identifiable {
    public init(pointer: T.PointerType) {
        self._pointer = pointer
    }
    
    deinit {
        T.destroy(pointer: _pointer)
    }
    
    private let _pointer: T.PointerType

    @discardableResult
    public func pass<R>(to block: (T.PointerType) throws -> R) rethrows -> R {
        try block(_pointer)
    }

    @discardableResult
    public func pass<R, A>(to block: (T.PointerType, A) throws -> R, _ a: A) rethrows -> R {
        try block(_pointer, a)
    }
    
    @discardableResult
    public func pass<R, A, B>(to block: (T.PointerType, A, B) throws -> R, _ a: A, _ b: B) rethrows -> R {
        try block(_pointer, a, b)
    }
    
    @discardableResult
    public func pass<R, A, B, C>(to block: (T.PointerType, A, B, C) throws -> R, _ a: A, _ b: B, _ c: C) rethrows -> R {
        try block(_pointer, a, b, c)
    }
    
    @discardableResult
    public func pass<R, A, B, C, D>(to block: (T.PointerType, A, B, C, D) throws -> R, _ a: A, _ b: B, _ c: C, _ d: D) rethrows -> R {
        try block(_pointer, a, b, c, d)
    }
    
    @discardableResult
    public func pass<R, A, B, C, D, E>(to block: (T.PointerType, A, B, C, D, E) throws -> R, _ a: A, _ b: B, _ c: C, _ d: D, _ e: E) rethrows -> R {
        try block(_pointer, a, b, c, d, e)
    }
    
    @discardableResult
    public func pass<R, A, B, C, D, E, F>(to block: (T.PointerType, A, B, C, D, E, F) throws -> R, _ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) rethrows -> R {
        try block(_pointer, a, b, c, d, e, f)
    }
    
    @discardableResult
    public func result(of block: (T.PointerType) -> Int32) -> Result<(),Error> {
        guard self.pass(to: block) == 0 else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(())
    }
    
    @discardableResult
    public func result<A>(of block: (T.PointerType, A) -> Int32, _ a: A) -> Result<(),Error> {
        guard self.pass(to: block, a) == 0 else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(())
    }
    
    @discardableResult
    public func result<A, B>(of block: (T.PointerType, A, B) -> Int32, _ a: A, _ b: B) -> Result<(),Error> {
        guard self.pass(to: block, a, b) == 0 else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(())
    }
    
    @discardableResult
    public func result<A, B, C>(of block: (T.PointerType, A, B, C) -> Int32, _ a: A, _ b: B, _ c: C) -> Result<(),Error> {
        guard self.pass(to: block, a, b, c) == 0 else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(())
    }
    
    @discardableResult
    public func result<A, B, C, D>(of block: (T.PointerType, A, B, C, D) -> Int32, _ a: A, _ b: B, _ c: C, _ d: D) -> Result<(),Error> {
        guard self.pass(to: block, a, b, c, d) == 0 else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(())
    }
    
    @discardableResult
    public func result<A, B, C, D, E>(of block: (T.PointerType, A, B, C, D, E) -> Int32, _ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> Result<(),Error> {
        guard self.pass(to: block, a, b, c, d, e) == 0 else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(())
    }
    
    @discardableResult
    public func result<A, B, C, D, E, F>(of block: (T.PointerType, A, B, C, D, E, F) -> Int32, _ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> Result<(),Error> {
        guard self.pass(to: block, a, b, c, d, e, f) == 0 else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(())
    }
    
    public static func == (lhs: SDLPointer<T>, rhs: SDLPointer<T>) -> Bool {
        lhs._pointer == rhs._pointer
    }
    
    public func hash(into hasher: inout Hasher) {
        self._pointer.hash(into: &hasher)
    }
}

public protocol SDLType {
    associatedtype PointerType: Hashable
    static func destroy(pointer: PointerType)
}
