import SwiftUI

struct ActionButtonsView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.gameState == .waiting {
                actionButton("Deal New Hand", color: .blue) {
                    viewModel.startNewHand()
                }
                .padding(.top, 40)
            } else if viewModel.gameState == .playing {
                HStack(spacing: 16) {
                    actionButton("Hit", color: .red) {
                        viewModel.hit()
                    }
                    
                    actionButton("Stand", color: .green) {
                        viewModel.stand()
                    }
                }
                
                HStack(spacing: 16) {
                    if viewModel.canDoubleDown {
                        actionButton("Double", color: .yellow) {
                            viewModel.doubleDown()
                        }
                    }
                    
                    if viewModel.canSplit {
                        actionButton("Split", color: .blue) {
                            viewModel.split()
                        }
                    }
                }
            } else if viewModel.gameState == .finished {
                actionButton("Next Hand", color: .blue) {
                    viewModel.startNewHand()
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func actionButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 2)
                )
                .cornerRadius(12)
        }
    }
}
