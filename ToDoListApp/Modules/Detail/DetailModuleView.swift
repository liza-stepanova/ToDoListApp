import SwiftUI

struct DetailModuleView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var adapter: DetailViewAdapter
    let presenter: DetailPresenterInput
    let router: DetailRouter

    var body: some View {
        DetailView(adapter: adapter, presenter: presenter)
            .onAppear { router.closeHandler = { dismiss() } }
    }
    
}
