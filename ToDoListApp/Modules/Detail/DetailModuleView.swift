import SwiftUI

struct DetailModuleView: View {
    
    @StateObject var adapter: DetailViewAdapter
    let presenter: DetailPresenterInput
    let router: DetailRouter
    
    @Environment(\.dismiss) private var dismiss
    @State private var didAppear = false

    var body: some View {
        DetailView(adapter: adapter, presenter: presenter)
            .onAppear {
                router.closeHandler = { dismiss() }
                if !didAppear {
                    didAppear = true
                    presenter.onAppear()
                }
            }
    }
    
}
