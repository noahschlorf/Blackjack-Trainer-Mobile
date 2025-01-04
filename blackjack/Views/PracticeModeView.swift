import SwiftUI

struct PracticeModeView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    let modes: [PracticeMode] = [
        .all,
        .hardTotals,
        .softTotals,
        .pairs
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(modes, id: \.self) { mode in
                    Button(action: {
                        viewModel.setPracticeMode(mode)
                        dismiss()
                    }) {
                        HStack {
                            Text(mode.description)
                            Spacer()
                            if viewModel.practiceMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Practice Mode")
        }
    }
}
