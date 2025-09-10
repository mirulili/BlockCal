import SwiftUI

struct ContentView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            MainView()
        } else {
            VStack {
                Image(systemName: "photo.on.rectangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding()
                Text("Photo Calendar")
                    .font(.title)
                    .bold()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
