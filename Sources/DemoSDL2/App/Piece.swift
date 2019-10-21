struct Piece: Collection, CustomDebugStringConvertible {
    typealias Rotation = Grid<Piece.Element>.Rotation
    
    enum Layout: Piece.Element {
        case square = 1
        case leftHook
        case rightHook
        case long
        case rightZag
        case leftZag
        case cross
        
        static func random() -> Layout {
            allLayouts.randomElement()!
        }
        
        static let allLayouts: [Layout] = [
            .square
            , .leftHook
            , .rightHook
            , .long
            , .rightZag
            , .leftZag
            , .cross
        ]
    }
    
    init(_ layout: Layout = .random()) {
        self.layout = layout
        let val = self.layout.rawValue
        
        switch layout {
        case .square:
            grid[0, 0] = val; grid[0, 1] = val
            grid[1, 0] = val; grid[1, 1] = val
        case .leftHook:
            grid[0, 0] = val
            grid[0, 1] = val
            grid[1, 1] = val
            grid[2, 1] = val
        case .rightHook:
            grid[0, 0] = val
            grid[0, 1] = val
            grid[1, 0] = val
            grid[2, 0] = val
        case .long:
            grid[0, 0] = val
            grid[1, 0] = val
            grid[2, 0] = val
            grid[3, 0] = val
        case .rightZag:
            grid[0, 1] = val; grid[0, 2] = val
            grid[1, 0] = val; grid[1, 1] = val
        case .leftZag:
            grid[0, 0] = val; grid[0, 1] = val;
            grid[1, 1] = val; grid[1, 2] = val
        case .cross:
            grid[0, 1] = val;
            grid[1, 0] = val; grid[1, 1] = val; grid[1, 2] = val;
        }
    }
    
    init(copying piece: Piece) {
        self.grid   = piece.grid
        self.layout = piece.layout
    }
    
    private var grid = Grid<UInt8>(rows: 4, columns: 4)
    private(set) var layout: Layout
    
    var startIndex: Int {
        self.grid.startIndex
    }
    
    var endIndex: Int {
        self.grid.endIndex
    }
    
    var rows: Int {
        self.grid.rows
    }
    
    var columns: Int {
        self.grid.columns
    }
    
    subscript(position: Int) -> UInt8 {
        self.grid[position]
    }
    
    subscript(row: Int, column: Int) -> UInt8 {
        self.grid[row, column]
    }
    
    func index(after i: Int) -> Int {
        self.grid.index(after: i)
    }
    
    var debugDescription: String {
        let nonEmptyRows = (0..<self.grid.rows)
            .map({ self.grid.row($0) })
            .filter({
                $0.reduce(into: 0, { $0 += $1 }) > 0
            })
        
        return nonEmptyRows
            .map({ $0.map(String.init).joined() })
            .map({ $0.replacingOccurrences(of: "0", with: " ") })
            .joined(separator: "\n")
    }
    
    mutating func rotating(_ rotation: Rotation) {
        self.grid.rotating(rotation)
    }
    
    func rotated(_ rotation: Rotation) -> Piece {
        var piece = self
        piece.rotating(rotation)
        return piece
    }
}
