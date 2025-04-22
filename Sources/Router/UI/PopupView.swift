
import SwiftUI

struct PopupView<Content: View>: View {
    var content: Content
    var onClose: () -> Void
    
    var body: some View {
        VStack {
            // Close Button
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
                .padding([.top, .trailing], 8)
            }
            
            content
                .padding()
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(radius: 4)
        .padding()
    }
}

