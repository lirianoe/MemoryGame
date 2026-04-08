import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp = false
    var isMatched = false
}

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var firstSelectedIndex: Int?
    @State private var numberOfPairs = 4
    
    private let emojis = ["🍕", "🚀", "🎸", "🏝️", "🐶", "🏀", "🚗", "👻"]
    private let columns = [GridItem(.adaptive(minimum: 80))]

    var body: some View {
        VStack {
            Text("Memory Game")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Picker("Pairs", selection: $numberOfPairs) {
                Text("2 Pairs").tag(2)
                Text("4 Pairs").tag(4)
                Text("8 Pairs").tag(8)
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: numberOfPairs) { _ in resetGame() }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index])
                            .onTapGesture {
                                handleTap(at: index)
                            }
                    }
                }
                .padding()
            }
            
            Button(action: resetGame) {
                Text("Reset Game")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .onAppear(perform: resetGame)
    }

    private func handleTap(at index: Int) {
        if cards[index].isFaceUp || cards[index].isMatched { return }
        
        cards[index].isFaceUp = true
        
        if let matchIndex = firstSelectedIndex {
            if cards[matchIndex].content == cards[index].content {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    cards[matchIndex].isFaceUp = false
                    cards[index].isFaceUp = false
                }
            }
            firstSelectedIndex = nil
        } else {
            firstSelectedIndex = index
        }
    }

    private func resetGame() {
        var newCards: [Card] = []
        let selected = Array(emojis.shuffled().prefix(numberOfPairs))
        for item in selected {
            newCards.append(Card(content: item))
            newCards.append(Card(content: item))
        }
        cards = newCards.shuffled()
        firstSelectedIndex = nil
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 12)
            if card.isMatched {
                shape.fill(.clear)
            } else {
                if card.isFaceUp {
                    shape.fill(.white)
                    shape.strokeBorder(lineWidth: 3)
                    Text(card.content).font(.largeTitle)
                } else {
                    shape.fill(.blue)
                }
            }
        }
        .frame(height: 110)
    }
}
