import SwiftUI

struct CardView: View {
    let card: Card
    private var cardSize: CGFloat {
        // Dynamically calculate card size based on screen width
        UIScreen.main.bounds.width * (UIDevice.current.userInterfaceIdiom == .pad ? 0.15 : 0.2)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 2)
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(rankString)
                            .font(.system(size: cardSize * 0.2, weight: .bold))
                        Image(systemName: suitSymbol)
                            .font(.system(size: cardSize * 0.15))
                    }
                    .foregroundColor(suitColor)
                    Spacer()
                }
                
                Spacer()
                
                Image(systemName: suitSymbol)
                    .font(.system(size: cardSize * 0.4))
                    .foregroundColor(suitColor)
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(rankString)
                            .font(.system(size: cardSize * 0.2, weight: .bold))
                        Image(systemName: suitSymbol)
                            .font(.system(size: cardSize * 0.15))
                    }
                    .rotationEffect(.degrees(180))
                    .foregroundColor(suitColor)
                }
            }
            .padding(cardSize * 0.05)
        }
        .frame(width: cardSize, height: cardSize * 1.4)
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
