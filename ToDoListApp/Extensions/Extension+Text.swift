import SwiftUI

extension Text {
    
    func titleFont() -> some View {
        self
            .foregroundStyle(.primary)
            .font(.system(size: 34, weight: .bold, design: .default))
    }
    
    func rowTitleFont() -> some View {
        self
            .foregroundStyle(.primary)
            .font(.system(size: 16, weight: .medium, design: .default))
    }
    
    func subtitleFont() -> some View {
        self
            .foregroundStyle(.primary)
            .font(.system(size: 12, weight: .regular, design: .default))
    }
    
}
