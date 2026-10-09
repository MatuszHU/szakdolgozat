import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
@M11
public struct GuideTipCard: View {
    let tip: GuideTip
    let onDismiss: () -> Void

    public init(tip: GuideTip, onDismiss: @escaping () -> Void) {
        self.tip = tip
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.15))
                    .frame(width: 140, height: 140)
                Image(systemName: tip.symbol)
                    .font(.system(size: 64))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tint)
                    .symbolEffect(.pulse, options: .nonRepeating)
            }
            .accessibilityHidden(true)
            Text(tip.title).font(.title2.bold()).multilineTextAlignment(.center)
            Text(tip.message).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Button(action: onDismiss) {
                Text("Értem").frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(28)
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension View {
    @M11
    public func guideTips(_ center: GuideTipCenter) -> some View {
        modifier(GuideTipPresenter(center: center))
    }
}

@available(iOS 17.0, macOS 14.0, *)
@M11
private struct GuideTipPresenter: ViewModifier {
    @ObservedObject var center: GuideTipCenter

    func body(content: Content) -> some View {
        content.sheet(item: Binding(get: { center.current }, set: { if $0 == nil { center.dismiss() } })) { tip in
            GuideTipCard(tip: tip) { center.dismiss() }
                .presentationDetents([.medium])
        }
    }
}
