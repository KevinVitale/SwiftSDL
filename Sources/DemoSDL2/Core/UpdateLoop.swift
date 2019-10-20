import Foundation
import CSDL2
import CSDL2_Image
import SwiftSDL2

//------------------------------------------------------------------------------
// See Also: https://dewitters.com/dewitters-gameloop/
//------------------------------------------------------------------------------
@available(OSX 10.12, *)
struct UpdateLoop {
    init(frequency: TimeInterval) {
        self.frequency = frequency
    }
    
    private var timer: Timer!
    private var frequency: TimeInterval

    mutating func run(on runLoop: RunLoop = .main, _ block: @escaping (_ update: TimeInterval) -> ()) {
        self.timer = Timer(timeInterval: self.frequency, repeats: true) {
            block($0.fireDate.timeIntervalSince1970)
        }
        runLoop.add(timer, forMode: .default)
    }
    
    func terminate() {
        timer.invalidate()
    }
    
    var isValid: Bool {
        timer.isValid
    }
}
