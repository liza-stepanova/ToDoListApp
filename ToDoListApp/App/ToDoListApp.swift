import SwiftUI

@main
struct TodosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate 
    var body: some Scene {
        WindowGroup {
            MainBuilder.build()
        }
    }
}

