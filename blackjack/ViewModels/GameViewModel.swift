import Foundation

class GameViewModel: ObservableObject {
    @Published private(set) var playerHand: [Card] = []
    @Published private(set) var dealerUpcard: Card?
    @Published private(set) var gameState: GameState = .waiting
    @Published private(set) var feedback: String?
    @Published private(set) var playerScore: Int = 0
    @Published private(set) var stats: GameStats = GameStats()
    @Published private(set) var practiceMode: PracticeMode = .all
    
    private let bestStreakKey = "BestStreak"
    
    init() {
        // Load the best streak from UserDefaults when initializing
        stats.longestStreak = UserDefaults.standard.integer(forKey: bestStreakKey)
    }
    
    struct GameStats {
        var correctDecisions: Int = 0
        var totalDecisions: Int = 0
        var currentStreak: Int = 0
        var longestStreak: Int = 0
        
        var decisionAccuracy: Double {
            guard totalDecisions > 0 else { return 0 }
            return Double(correctDecisions) / Double(totalDecisions) * 100
        }
        
        mutating func recordDecision(isCorrect: Bool) {
            totalDecisions += 1
            if isCorrect {
                correctDecisions += 1
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
    }
    
    enum GameState {
        case waiting, playing, finished
    }
    
    enum Move: String {
        case hit = "H"
        case stand = "S"
        case doubleDown = "D"
        case split = "P"
        case doubleOrStand = "DS"
    }
    
    private var deck: [Card] = []
    
    var canDoubleDown: Bool {
        guard gameState == .playing else { return false }
        return playerHand.count == 2
    }
    
    var canSplit: Bool {
        guard gameState == .playing else { return false }
        return playerHand.count == 2 && playerHand[0].rank == playerHand[1].rank
    }
    
    func startNewHand() {
        resetDeck()
        
        repeat {
            playerHand = [drawCard(), drawCard()]
            dealerUpcard = drawCard()
            updateScore()
        } while !isValidHandForMode() || playerScore == 21
        
        gameState = .playing
        feedback = nil
    }
    
    func hit() {
        guard gameState == .playing else { return }
        let correctMove = getCorrectMove()
        evaluateMove(.hit, correctMove: correctMove)
        gameState = .finished
    }
    
    func stand() {
        guard gameState == .playing else { return }
        let correctMove = getCorrectMove()
        evaluateMove(.stand, correctMove: correctMove)
        gameState = .finished
    }
    
    func doubleDown() {
        guard canDoubleDown && gameState == .playing else { return }
        let correctMove = getCorrectMove()
        evaluateMove(.doubleDown, correctMove: correctMove)
        gameState = .finished
    }
    
    func split() {
        guard canSplit && gameState == .playing else { return }
        let correctMove = getCorrectMove()
        evaluateMove(.split, correctMove: correctMove)
        gameState = .finished
    }
    
    private func evaluateMove(_ move: Move, correctMove: Move) {
        let isCorrect = move == correctMove
        stats.recordDecision(isCorrect: isCorrect)
        
        // Save best streak whenever it's updated
        if stats.longestStreak > UserDefaults.standard.integer(forKey: bestStreakKey) {
            UserDefaults.standard.set(stats.longestStreak, forKey: bestStreakKey)
        }
        
        if isCorrect {
            feedback = "Correct! Basic strategy says to \(moveDescription(correctMove))."
        } else {
            feedback = "Incorrect! Basic strategy says to \(moveDescription(correctMove))."
        }
    }
    
    private func getCorrectMove() -> Move {
        guard let dealerCardRank = dealerUpcard?.rank.value else {
            return .stand // Default to stand if dealer card is unavailable
        }
        
        // Check for pairs first
        if canSplit {
            return getPairMove(pair: playerHand[0].rank.value, dealerCard: dealerCardRank)
        }
        
        // Then check for soft totals
        let hasAce = playerHand.contains { $0.rank == .ace }
        if hasAce {
            let otherCard = playerHand.first { $0.rank != .ace }?.rank.value ?? 0
            return getSoftTotalMove(aceWith: otherCard, dealerCard: dealerCardRank)
        }
        
        // Finally check hard totals
        return getHardTotalMove(total: playerScore, dealerCard: dealerCardRank)
    }
    
    private func getHardTotalMove(total: Int, dealerCard: Int) -> Move {
        switch total {
        case ...8:
            return .hit
        case 9:
            return (dealerCard >= 3 && dealerCard <= 6) ? .doubleDown : .hit
        case 10:
            return (dealerCard <= 9) ? .doubleDown : .hit
        case 11:
            return .doubleDown
        case 12:
            return (dealerCard >= 4 && dealerCard <= 6) ? .stand : .hit
        case 13...16:
            return (dealerCard <= 6) ? .stand : .hit
        default:
            return .stand
        }
    }
    
    private func getSoftTotalMove(aceWith: Int, dealerCard: Int) -> Move {
        let total = aceWith + 11 // Ace is counted as 11 for soft totals
        
        switch total {
        case 13, 14: // A,2 or A,3
            return (dealerCard >= 5 && dealerCard <= 6) ? .doubleDown : .hit
        case 15, 16: // A,4 or A,5
            return (dealerCard >= 4 && dealerCard <= 6) ? .doubleDown : .hit
        case 17: // A,6
            return (dealerCard >= 3 && dealerCard <= 6) ? .doubleDown : .hit
        case 18: // A,7
            if dealerCard >= 2 && dealerCard <= 6 {
                return .doubleOrStand
            } else if dealerCard >= 9 {
                return .hit
            } else {
                return .stand
            }
        case 19, 20, 21: // A,8 or A,9 or A,T
            return .stand
        default:
            return .hit
        }
    }
    
    private func getPairMove(pair: Int, dealerCard: Int) -> Move {
        switch pair {
        case 11: // A,A
            return .split
        case 10: // T,T
            return .stand
        case 9:
            if dealerCard == 7 || dealerCard >= 10 {
                return .stand
            }
            return .split
        case 8:
            return .split
        case 7:
            return (dealerCard <= 7) ? .split : .hit
        case 6:
            return (dealerCard <= 6) ? .split : .hit
        case 5:
            return (dealerCard <= 9) ? .doubleDown : .hit
        case 4:
            return (dealerCard == 5 || dealerCard == 6) ? .split : .hit
        case 3, 2:
            return (dealerCard <= 7) ? .split : .hit
        default:
            return .hit
        }
    }
    
    private func moveDescription(_ move: Move) -> String {
        switch move {
        case .hit:
            return "Hit"
        case .stand:
            return "Stand"
        case .doubleDown:
            return "Double Down"
        case .split:
            return "Split"
        case .doubleOrStand:
            return "Double Down if allowed, otherwise Stand"
        }
    }
    
    private func calculateScore(_ hand: [Card]) -> Int {
        var score = 0
        var aces = 0
        
        for card in hand {
            if card.rank == .ace {
                aces += 1
            } else {
                score += card.rank.value
            }
        }
        
        for _ in 0..<aces {
            if score + 11 <= 21 {
                score += 11
            } else {
                score += 1
            }
        }
        
        return score
    }
    
    private func updateScore() {
        playerScore = calculateScore(playerHand)
    }
    
    private func resetDeck() {
        deck = Card.Suit.allCases.flatMap { suit in
            Card.Rank.allCases.map { rank in
                Card(rank: rank, suit: suit)
            }
        }.shuffled()
    }
    
    private func drawCard() -> Card {
        if deck.isEmpty {
            resetDeck()
        }
        return deck.removeLast()
    }
    
    private func isValidHandForMode() -> Bool {
        switch practiceMode {
        case .all:
            return true
        case .hardTotals:
            return !playerHand.contains { $0.rank == .ace }
        case .softTotals:
            return playerHand.contains { $0.rank == .ace }
        case .pairs:
            return playerHand.count == 2 && playerHand[0].rank == playerHand[1].rank
        }
    }
    
    func setPracticeMode(_ mode: PracticeMode) {
        practiceMode = mode
    }
}
