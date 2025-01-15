import SwiftUI

struct PracticeView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingModeSelector = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section (Fixed)
            VStack(spacing: 16) {
                // Mode Selector Button
                Button(action: { showingModeSelector = true }) {
                    Text(viewModel.practiceMode.description)
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 8)  // Small top padding
                
                // Stats Area
                HStack {
                    VStack(alignment: .leading) {
                        Text("Correct Plays: \(String(format: "%.1f%%", viewModel.stats.decisionAccuracy))")
                            .font(.title3.bold())
                        Text("(\(viewModel.stats.correctDecisions)/\(viewModel.stats.totalDecisions))")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Current Streak: \(viewModel.stats.currentStreak)")
                            .font(.subheadline)
                        Text("Best: \(viewModel.stats.longestStreak)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 16)
            .background(Color.white)
            
            Spacer()
            
            // Game Area (Fixed Height)
            VStack(spacing: 0) {
                // Dealer Area
                Text("Dealer")
                    .font(.title2)
                    .padding(.bottom, 10)
                if let upcard = viewModel.dealerUpcard {
                    CardView(card: upcard)
                    .padding(.bottom, 60)
                }
                
                // Player Area
                Text("Your Hand: \(viewModel.playerScore)")
                    .font(.title2)
                    .padding(.bottom, 10)
                HStack(spacing: 10) {
                    ForEach(viewModel.playerHand) { card in
                        CardView(card: card)
                    }
                }
            }
            .padding(.vertical, 20)
            .offset(y: -40)
            
            Spacer()
            
            // Bottom Section (Fixed)
            VStack(spacing: 16) {
                // Feedback Area
                // Feedback Area
                Group {
                    if let feedback = viewModel.feedback {
                        Text(feedback)
                            .padding()
                            .background(
                                viewModel.stats.correctDecisions > 0 && feedback.contains("Correct")
                                    ? Color.green.opacity(0.2)
                                    : Color.red.opacity(0.2)
                            )
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 60)

                
                // Action Buttons
                ActionButtonsView(viewModel: viewModel)
                    .padding(.bottom)
            }
        }
        .safeAreaInset(edge: .top) {  // Moved to root level
            Color.clear.frame(height: 0)  // Zero height, just to enable safe area
        }
        .sheet(isPresented: $showingModeSelector) {
            PracticeModeView(viewModel: viewModel)
        }
    }
}
