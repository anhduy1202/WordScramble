//
//  ContentView.swift
//  WordScramble
//
//  Created by William McCarthy on 2/28/24.
//

import SwiftUI

struct ContentView: View {
  @State private var usedWords = [String]()
  @State private var rootWord = ""
  @State private var newWord = ""
  @State private var errorTitle = ""
  @State private var errorMessage = ""
  @State private var showingError = false
  
   // Check if word has been used
  func isOriginal(word: String) -> Bool {
    !usedWords.contains(word)
  }
    
  // Check if its the same word as root word
  func isTheSame(word: String) -> Bool {
      return rootWord != word
  }
    
 // Check if words too short
    func isTooShort(word: String) -> Bool {
        return word.count > 3
    }
    
  // 
  func isPossible(word: String) -> Bool {
    var tempWord = rootWord

    for letter in word {
      if let pos = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: pos)
      } else {
        return false
      }
    }
      return true
  }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
  func startGame() {
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
      if let startWords = try? String(contentsOf: startWordsURL) {
        let allWords = startWords.components(separatedBy: "\n")
        
        rootWord = allWords.randomElement() ?? "silkworm"
        
        return
      }
    }
    fatalError("Could not load start.txt from bundle.")
  }
  
  func addNewWord() {
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard answer.count > 0 else { return }
    
    // extra validation to come
      guard isOriginal(word: answer) else {
          wordError(title: "Word used already", message: "Be more original")
          return
      }
      
      guard isTheSame(word: answer) else {
          wordError(title: "Nice try...", message: "The answer cannot be the question or shorter than 3 letters")
          return
      }
      
      guard isTooShort(word: answer) else {
          wordError(title: "Word too short", message: "Has to be more than 3 letters")
          return
      }

      guard isPossible(word: answer) else {
          wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
          return
      }

      guard isReal(word: answer) else {
          wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
          return
      }
    withAnimation {
      usedWords.insert(answer, at: 0)
    }
    newWord = ""
  }
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          TextField("Enter your word", text: $newWord)
            .textInputAutocapitalization(.never)
        }
        
        Section {
          ForEach(usedWords, id: \.self) { word in
            HStack {
              Image(systemName: "\(word.count).circle")
              Text(word)
            }
          }
        }
      }
      .navigationTitle(rootWord)
      .onSubmit(addNewWord)
      .onAppear(perform: startGame)
      .alert(errorTitle, isPresented: $showingError) {
          Button("OK") { }
      } message: {
          Text(errorMessage)
      }
      .toolbar { // Add the toolbar
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("New Game") {
            usedWords = []
            startGame()
          }
        }
      }
      .safeAreaInset(edge: .bottom) {
          ZStack {
              Color.blue
                  .edgesIgnoringSafeArea(.vertical)
                  .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
              Spacer()
              HStack {
                  Spacer()
                  Text("Score: \(usedWords.count)") // Replace with your score calculation
                      .font(.title)
                      .foregroundColor(.white)
                      .padding()
                      .background(Color.blue)
                      .cornerRadius(10)
                  Spacer()
              }
          }
      }
    }
  }
}

#Preview {
    ContentView()
}
