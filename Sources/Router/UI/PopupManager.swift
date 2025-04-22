import Foundation
import SwiftUI
import SwiftEntryKit

@MainActor
struct PopupManager {
    static func present<Route, Content: View>(route: Route?, onClose: @escaping () -> (), content: @escaping (Route) -> Content) {
        if let route = route {
            var attributes = EKAttributes.centerFloat
            attributes.displayDuration = .infinity
            attributes.entryBackground = .color(color: .white)
            attributes.entranceAnimation = .init(fade: .some(.init(from: 0, to: 1, duration: 0.3)))
            attributes.exitAnimation = .none
            attributes.scroll = .disabled
            
            let hostingController = UIHostingController(rootView: PopupView(content: content(route), onClose: {SwiftEntryKit.dismiss(); onClose()}))
            hostingController.view.backgroundColor = .clear
            
            SwiftEntryKit.display(entry: hostingController.view, using: attributes)
        } else {
            SwiftEntryKit.dismiss()
            onClose()
        }
    }
}
