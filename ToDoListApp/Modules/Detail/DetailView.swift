import SwiftUI

struct DetailView: View {
    
    @ObservedObject var adapter: DetailViewAdapter
    let presenter: DetailPresenterInput
    
    @FocusState private var focus: Field?
    private enum Field { case title, body }
    
    var body: some View {
     
        VStack(alignment: .leading, spacing: 8) {
                
            TextField(
                "Title",
                text: Binding(
                    get: { adapter.state.title
                    },
                    set: { presenter.titleChanged($0) })
            )
            .font(.system(size: 34, weight: .bold))
            .textFieldStyle(.plain)
            .lineLimit(2)
            .submitLabel(.done)
            .onSubmit {
                focus = nil
            }
            .focused($focus, equals: .title)
                
            Text(adapter.state.dateText)
                .subtitleFont()
                .opacity(0.5)
                
            TextEditor(
                text: Binding(
                    get: { adapter.state.content
                    },
                    set: { presenter.contentChanged($0) })
            )
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.primary)
            .padding(.leading, -3)
            .focused($focus, equals: .body)
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    //
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .padding(.leading, -12)
                        Text("Назад")
                    }
                }
                .tint(Color.accent)
            }
        }
    }
    
}
//
//#Preview {
//    NavigationStack {
//        DetailView(title: "LSSL", content: "ffdfddsfefw", dateText: "12/33/44")
//    }
//}
