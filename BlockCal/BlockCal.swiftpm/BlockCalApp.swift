import SwiftUI

@main
struct BlockCalApp: App {
    @StateObject var photoStore = PhotoStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(photoStore)
        }
    }
}
