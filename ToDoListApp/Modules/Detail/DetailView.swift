import SwiftUI

struct DetailView: View {
    
    @State var title: String
    @State var content: String
    var dateText: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            TextField("Title", text: $title)
                .font(.system(size: 34, weight: .bold))
                .textFieldStyle(.plain)
                .lineLimit(2)
            
            Text(dateText)
                .subtitleFont()
                .opacity(0.5)
            
            TextEditor(text: $content)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary)
                .padding(.leading, -3)
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

#Preview {
    NavigationStack {
        DetailView(title: "LSSL", content: "ffdfddsfefw", dateText: "12/33/44")
    }
}
