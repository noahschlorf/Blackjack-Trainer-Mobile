import SwiftUI

struct StrategyTableView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // Calculate cell width based on screen width
    private var cellWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalCells = 12 // 2 for hand column + 10 for dealer cards
        let padding: CGFloat = 32 // Total horizontal padding
        return (screenWidth - padding) / CGFloat(totalCells)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Legend at the top
                legendSection
                    .padding(.horizontal)
                
                // Chart
                VStack(spacing: 0) {
                    // Strategy sections
                    Group {
                        strategySection(title: "Hard Totals", rows: hardTotalRows)
                        strategySection(title: "Soft Totals", rows: softTotalRows)
                        strategySection(title: "Pairs", rows: pairRows)
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.gray.opacity(0.1))
    }
    
    private var legendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Strategy Chart")
                .font(.title3.bold())
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                legendItem(text: "Hit (H)", color: .red)
                legendItem(text: "Stand (S)", color: .green)
                legendItem(text: "Double (D)", color: .yellow)
                legendItem(text: "Split (P)", color: .blue)
                legendItem(text: "Double/Stand (DS)", color: .orange)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func dealerTotal(for card: String) -> String {
        switch card {
        case "A": return "A"
        case "10", "T": return "10"
        default: return card
        }
    }
    
    private func strategySection(title: String, rows: [StrategyRow]) -> some View {
        VStack(spacing: 0) {
            // Section title
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: cellWidth)
                .background(Color.gray.opacity(0.15))
                .border(Color.gray.opacity(0.3), width: 0.5)
                .bold()
            
            // Dealer upcard row with totals
            HStack(spacing: 0) {
                Text("Dealer")
                    .frame(width: cellWidth * 2, height: cellWidth)
                    .background(Color.gray.opacity(0.1))
                    .border(Color.gray.opacity(0.3), width: 0.5)
                    .font(.system(size: 14, weight: .bold))
                
                ForEach(["2", "3", "4", "5", "6", "7", "8", "9", "10", "A"], id: \.self) { value in
                    VStack(spacing: 2) {
                        Text(dealerTotal(for: value))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(width: cellWidth, height: cellWidth)
                    .background(Color.gray.opacity(0.1))
                    .border(Color.gray.opacity(0.3), width: 0.5)
                }
            }
            
            // Strategy rows
            ForEach(rows, id: \.hand) { row in
                strategyRow(row)
            }
        }
    }
    
    private func strategyRow(_ row: StrategyRow) -> some View {
        HStack(spacing: 0) {
            Text(row.hand)
                .frame(width: cellWidth * 2, height: cellWidth)
                .background(Color.gray.opacity(0.05))
                .border(Color.gray.opacity(0.3), width: 0.5)
            
            ForEach(Array(row.actions.enumerated()), id: \.offset) { index, action in
                Text(action)
                    .frame(width: cellWidth, height: cellWidth)
                    .background(actionColor(action).opacity(0.3))
                    .border(Color.gray.opacity(0.3), width: 0.5)
                    .bold()
            }
        }
    }
    
    private func legendItem(text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.3))
                .frame(width: 24, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(color, lineWidth: 1)
                )
            Text(text)
                .font(.callout)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func actionColor(_ action: String) -> Color {
        switch action {
        case "H": return .red
        case "S": return .green
        case "D": return .yellow
        case "P": return .blue
        case "DS": return .orange
        default: return .clear
        }
    }
}

// MARK: - Strategy Data
private struct StrategyRow {
    let hand: String
    let actions: [String]
}

private let hardTotalRows = [
    StrategyRow(hand: "17+", actions: Array(repeating: "S", count: 10)),
    StrategyRow(hand: "16", actions: ["S", "S", "S", "S", "S", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "15", actions: ["S", "S", "S", "S", "S", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "14", actions: ["S", "S", "S", "S", "S", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "13", actions: ["S", "S", "S", "S", "S", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "12", actions: ["H", "H", "S", "S", "S", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "11", actions: ["D", "D", "D", "D", "D", "D", "D", "D", "D", "H"]),
    StrategyRow(hand: "10", actions: ["D", "D", "D", "D", "D", "D", "D", "H", "H", "H"]),
    StrategyRow(hand: "9", actions: ["H", "D", "D", "D", "D", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "8", actions: Array(repeating: "H", count: 10))
]

private let softTotalRows = [
    StrategyRow(hand: "A,9", actions: Array(repeating: "S", count: 10)),
    StrategyRow(hand: "A,8", actions: Array(repeating: "S", count: 10)),
    StrategyRow(hand: "A,7", actions: ["DS", "DS", "DS", "DS", "DS", "S", "S", "H", "H", "H"]),
    StrategyRow(hand: "A,6", actions: ["H", "D", "D", "D", "D", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "A,5", actions: ["H", "H", "D", "D", "D", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "A,4", actions: ["H", "H", "D", "D", "D", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "A,3", actions: ["H", "H", "H", "D", "D", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "A,2", actions: ["H", "H", "H", "D", "D", "H", "H", "H", "H", "H"])
]

private let pairRows = [
    StrategyRow(hand: "A,A", actions: Array(repeating: "P", count: 10)),
    StrategyRow(hand: "10,10", actions: Array(repeating: "S", count: 10)),
    StrategyRow(hand: "9,9", actions: ["P", "P", "P", "P", "P", "S", "P", "P", "S", "S"]),
    StrategyRow(hand: "8,8", actions: Array(repeating: "P", count: 10)),
    StrategyRow(hand: "7,7", actions: ["P", "P", "P", "P", "P", "P", "H", "H", "H", "H"]),
    StrategyRow(hand: "6,6", actions: ["P", "P", "P", "P", "P", "P", "H", "H", "H", "H"]),
    StrategyRow(hand: "5,5", actions: ["D", "D", "D", "D", "D", "D", "D", "D", "H", "H"]),
    StrategyRow(hand: "4,4", actions: ["H", "H", "H", "P", "P", "H", "H", "H", "H", "H"]),
    StrategyRow(hand: "3,3", actions: ["P", "P", "P", "P", "P", "P", "H", "H", "H", "H"]),
    StrategyRow(hand: "2,2", actions: ["P", "P", "P", "P", "P", "P", "H", "H", "H", "H"])
]
