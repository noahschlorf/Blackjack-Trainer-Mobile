import Foundation

enum PracticeMode: Hashable {
    case all
    case hardTotals
    case softTotals
    case pairs
    
    var description: String {
        switch self {
        case .all: return "Practice All"
        case .hardTotals: return "Hard Totals"
        case .softTotals: return "Soft Totals"
        case .pairs: return "Pairs"
        }
    }
}
