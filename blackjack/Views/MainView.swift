import SwiftUI

struct MainView: View {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        TabView {
            PracticeView(viewModel: gameViewModel)
                .tabItem {
                    Label("Practice", systemImage: "hammer.fill") // Consistent and appropriate icon
                }
            
            StrategyTableView()
                .tabItem {
                    Label("Strategy", systemImage: "tablecells.fill")
                }
        }
    }
}
