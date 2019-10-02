import Foundation.NSThread
import CSDL2

public struct SDLPointer<T: SDLType> {
    init(pointer: T.PointerType) {
        self._pointer = pointer
    }
    
    func destroy(pointer: T.PointerType) {
        T.destroy(pointer: pointer)
    }
    
    let _pointer: T.PointerType
}

public protocol SDLType {
    associatedtype PointerType
    static func destroy(pointer: PointerType)
}
