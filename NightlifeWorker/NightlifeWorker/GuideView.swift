import SwiftUI
import SharedKit

@K15
struct GuideView: View {
    let viewModel: GuideViewModel

    var body: some View {
        List(viewModel.sections) { section in
            VStack(alignment: .leading, spacing: 6) {
                Label(section.title, systemImage: section.symbol).font(.headline)
                Text(section.text).font(.subheadline)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Útmutató")
    }
}
