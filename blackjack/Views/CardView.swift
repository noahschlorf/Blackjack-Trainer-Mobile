import SwiftUI

struct CardView: View {
    let card: Card
    private let cardWidth: CGFloat = 90
    private let cardHeight: CGFloat = 126
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(radius: 2)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(rankString)
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: suitSymbol)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(suitColor)
                    Spacer()
                }
                
                Spacer()
                
                Image(systemName: suitSymbol)
                    .font(.system(size: 30))
                    .foregroundColor(suitColor)
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(rankString)
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: suitSymbol)
                            .font(.system(size: 10))
                    }
                    .rotationEffect(.degrees(180))
                    .foregroundColor(suitColor)
                }
            }
            .padding(6)
        }
        .frame(width: cardWidth, height: cardHeight)
        .accessibilityElement()
        .accessibilityLabel("\(rankString) of \(card.suit.rawValue.capitalized)")
        .accessibilityHint("A \(rankString) in \(card.suit.rawValue.capitalized) suit.")
    }
    
    private var rankString: String {
        switch card.rank {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        default: return "\(card.rank.value)"
        }
    }
    
    private var suitSymbol: String {
        switch card.suit {
        case .hearts: return "heart.fill"
        case .diamonds: return "diamond.fill"
        case .clubs: return "suit.club.fill"
        case .spades: return "suit.spade.fill"
        }
    }
    
    private var suitColor: Color {
        switch card.suit {
        case .hearts, .diamonds: return .red
        case .clubs, .spades: return .black
        }
    }
}
