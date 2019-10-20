import CSDL2

struct GameBoard {
    init(_ grid: Grid<Piece.Element> = Grid(rows: 20, columns: 10)) {
        self.grid = grid
    }
    
    private var grid: Grid<Piece.Element>
    
    var randomTileIndex: Int {
        .random(in: grid.startIndex..<grid.endIndex)
    }
    
    mutating func clear() {
        self.grid = Grid(rows: self.grid.rows, columns: self.grid.columns)
    }
    
    subscript(index: Int) -> Piece.Element {
        get {
            grid[index]
        }
        set {
            grid[index] = newValue
        }
    }
    
    @inlinable func forEach(_ body: ((row: Int, column: Int), _ value: UInt8) throws -> Void) rethrows {
        var row = -1
        for (index, value) in grid.enumerated() {
            let column = index % grid.columns
            if column == 0 {
                row += 1
            }
            try body((row, column), value)
        }
    }
    
    @inlinable func enumerated() -> EnumeratedSequence<Grid<Piece.Element>> {
        grid.enumerated()
    }

    func computedCenterPoints(sizedAt size: (x: Float, y: Float)) throws -> [(center: (x: Float, y: Float), index: Int, value: Piece.Element)] {
        let midX = size.x * 0.5
        let midY = size.y * 0.5
        var result = [(center: (Float,Float), index: Int, value: Piece.Element)]()
        self.forEach { index, value in
            let xPos = Float(index.row) * size.x + midX
            let yPos = Float(index.column) * size.y + midY
            result.append((center: (x: xPos, y: yPos), index: index.row + index.column, value: value))
        }
        return result
    }
}
