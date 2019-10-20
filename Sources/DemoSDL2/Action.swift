import Foundation

class Action: Identifiable, Equatable, Updatable {
    typealias UpdateBlock = (_ deltaTime: TimeInterval) -> ()
    
    init(repeats: Bool, atInterval updateInterval: TimeInterval? = nil, _ block: @escaping UpdateBlock) {
        self.block = block
        self.repeats = repeats
        self.updateInterval = updateInterval ?? .zero
    }
    
    private var block: UpdateBlock?
    private let repeats: Bool
    private let updateInterval: TimeInterval
    private var remainingUpdateTime: TimeInterval = .zero
    private var previousUpdateTime: TimeInterval = .infinity
    private var isCancelled: Bool = false
    
    func update(atTime timeInterval: TimeInterval) {
        guard self.isCancelled == false else {
            return
        }
        
        defer {
            self.previousUpdateTime = timeInterval
        }
        
        if self.previousUpdateTime.isInfinite {
            self.previousUpdateTime = timeInterval
        }
        
        let lastUpdateInterval = timeInterval - self.previousUpdateTime
        self.remainingUpdateTime -= lastUpdateInterval
        
        if let block = self.block, self.remainingUpdateTime.isLessThanOrEqualTo(.zero) {
            block(lastUpdateInterval)
            self.remainingUpdateTime = self.updateInterval
        }
        
        if self.repeats == false {
            self.block = nil
        }
    }
    
    func cancel() {
        self.isCancelled.toggle()
    }

    static func == (lhs: Action, rhs: Action) -> Bool {
        lhs.id == rhs.id
    }
}
