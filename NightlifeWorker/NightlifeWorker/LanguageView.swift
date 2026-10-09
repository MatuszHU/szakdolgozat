import SwiftUI
import SharedKit

@K11
struct LanguageView: View {
    @ObservedObject var settings: LanguageSettings

    var body: some View {
        List(AppLanguage.allCases) { language in
            Button {
                settings.choose(language)
            } label: {
                HStack {
                    if let name = language.nativeName {
                        Text(verbatim: name)
                    } else {
                        Text("A rendszer nyelve")
                    }
                    Spacer()
                    if settings.language == language {
                        Image(systemName: "checkmark").foregroundStyle(.tint)
                    }
                }
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle("Nyelv")
    }
}
