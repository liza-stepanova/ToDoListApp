import SwiftUI

struct FooterView: View {
    var countItems: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.contour)
            HStack(alignment: .center) {
                Spacer()
                
                Text("\(countItems) задач")
                    .foregroundStyle(.primary)
                    .padding(.leading, 24)
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(Color.accent)
                        .font(.system(size: 24, weight: .regular))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.base)
        }
    }
    
}
