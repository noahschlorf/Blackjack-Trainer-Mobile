import Foundation

struct Card: Identifiable, Equatable, Codable {
    var id: UUID
    let rank: Rank
    let suit: Suit
    
    init(rank: Rank, suit: Suit) {
        self.id = UUID()
        self.rank = rank
        self.suit = suit
    }
    
    enum Rank: Int, CaseIterable, Codable {
        case ace = 1
        case two = 2, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king
        
        var value: Int {
            switch self {
            case .ace: return 11
            case .jack, .queen, .king: return 10
            default: return rawValue
            }
        }
    }
    
    enum Suit: String, CaseIterable, Codable {
        case hearts, diamonds, clubs, spades
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, rank, suit
    }
}
