import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
@K11 @M10
public struct LanguageView: View {
    @ObservedObject var settings: LanguageSettings

    public init(settings: LanguageSettings) {
        self.settings = settings
    }

    public var body: some View {
        List(settings.supported) { language in
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
