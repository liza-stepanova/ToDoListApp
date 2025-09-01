import SwiftUI

@main
struct TodosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate 
    var body: some Scene {
        WindowGroup {
            DetailBuilder.build(todoID: 34)
        }
    }
}

