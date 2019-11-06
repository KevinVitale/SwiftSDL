// Grid<T>
//------------------------------------------------------------------------------
struct Grid<Element>: Collection {
    // Private
    //--------------------------------------------------------------------------
    private var values: Array<Element>
    
    // Public
    //--------------------------------------------------------------------------
    let rows:  Int
    let columns: Int
    
    // Init
    //--------------------------------------------------------------------------
    init<S: Sequence>(rows height: Int, columns width: Int, values: S) where S.Element == Element {
        self.columns  = width
        self.rows     = height
        self.values   = Array(values)
    }
    
    // Collection
    //--------------------------------------------------------------------------
    var startIndex: Int { return values.startIndex  }
    var endIndex:   Int { return values.endIndex    }
    
    func index(after i: Int) -> Int {
        values.index(after: i)
    }
    
    // Subscripts
    //--------------------------------------------------------------------------
    subscript(index: Int) -> Element {
        get { values[index] }
        set { values[index] = newValue }
    }
    
    subscript(row: Int, col: Int) -> Element {
        get { values[(row * columns) + col] }
        set { values[(row * columns) + col] = newValue }
    }
}

extension Grid {
    func row(_ row: Grid.Index) -> Slice<Self> {
        let startIndex = row * rows
        let endIndex   = startIndex + columns
        return self[startIndex..<endIndex]
    }
    
    func column(_ column: Grid.Index) -> [Self.Element] {
        (0..<rows).map({ self[($0 * rows) + column] })
    }
}

extension Grid: CustomDebugStringConvertible {
    var debugDescription: String {
        var debugDescription = "rows: \(rows); columns: \(columns)\n---\n"
        for row in 0..<rows {
            for column in 0..<columns {
                debugDescription.append("\(self[row, column])\t")
            }
            debugDescription.append("\n")
        }
        return debugDescription
    }
}

extension Grid {
    enum Rotation {
        case clockwise
        case counterClockwise
    }
}
    
extension Grid where Element: Numeric {
    init(rows height: Int, columns width: Int) {
        self = Grid(rows: height, columns: width, values: Array(repeating: .zero, count: height * width))
    }
    
    mutating func clear() {
        self.values = Array(repeating: .zero, count: rows * columns)
    }

    mutating func rotating(_ rotation: Rotation = .clockwise) {
        self = rotated(rotation)
    }
    
    // https://stackoverflow.com/a/8664879
    func rotated(_ rotation: Rotation) -> Self {
        var transposed = Self(rows: rows, columns: columns, values: Array(repeating: .zero, count: rows * columns))
        
        for row in 0..<rows {
            let startIndex = row * rows
            let endIndex   = startIndex + columns
            let rowValues  = self.values[startIndex..<endIndex]
            
            for (index, value) in rowValues.enumerated() {
                transposed[(index * rows) + row] = value
            }
        }
        
        switch rotation {
        case .clockwise:
            for row in 0..<rows {
                let startIndex = row * rows
                let endIndex   = startIndex + columns
                let reversed   = transposed[startIndex..<endIndex].reversed()
                transposed.values.replaceSubrange(startIndex..<endIndex, with: reversed)
            }
        case .counterClockwise:
            var reversedColumns = transposed
            for column in 0..<columns {
                for (row, value) in (startIndex..<endIndex)
                    .filter({ $0 % columns == 0 })
                    .reversed()
                    .enumerated() {
                        reversedColumns[(row * rows) + column] = transposed[value + column]
                }
            }
            transposed = reversedColumns
        }
        return Grid(rows: columns, columns: rows, values: transposed)
    }
}
