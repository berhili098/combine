import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
   

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Count: \(viewModel.count)")

            TextField("Type something here", text: $viewModel.textFieldText)
                .frame(width: 300, height: 50)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    ZStack{
                       
                        Image(systemName: viewModel.textIsValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(
                                viewModel.textIsValid ? .green : .red
                            )
                            
                    }.padding(),
                    alignment: .trailing
                )
            Spacer()
            Button(action: {}, label:{ Text("Button")})
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(.blue)
                .cornerRadius(12)
                .padding(.horizontal)
                .opacity(!viewModel.showButton ? 0.5 : 1)
                .disabled(!viewModel.showButton)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}



final class SubscriptionViewModel: ObservableObject {
    @Published var count = 0
    @Published var textFieldText = ""
    @Published private(set) var textIsValid = false
    @Published var showButton : Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        observeTextField()
        startTimer()
        buttonObservable()
    }

    private func observeTextField() {
        $textFieldText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0 == "Hello" }
            .receive(on: RunLoop.main)
        //            .assign(to: &$textIsValid)
            .sink{[weak self] valid in
                self?.textIsValid = valid
            }
            .store(in: &cancellables)
        
     
    }

    
    private func buttonObservable(){
        $textIsValid
            .combineLatest($count)
            .sink{[weak self] textvalid,count in
                
                self?.showButton = textvalid && count >= 10
            }
            .store(in: &cancellables)
    }
    private func startTimer() {
        Timer
            .publish(every: 0.3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.count += 1

                // Optional: stop after 10 ticks
                // if self.count >= 10 {
                //     self.cancellables.removeAll()
                // }
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }
}
struct ColorAndImage {
    let color: Color
    let image : String
}
