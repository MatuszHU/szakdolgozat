#if os(iOS)
import SwiftUI
import PhotosUI

@K10 @M9
public struct ProfilePictureView: View {
    @ObservedObject var viewModel: ProfilePictureViewModel
    @State private var selection: PhotosPickerItem?
    @EnvironmentObject private var loading: LoadingViewModel

    public init(viewModel: ProfilePictureViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    ProfileImage(data: viewModel.imageData, size: 160)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            Section {
                PhotosPicker(selection: $selection, matching: .images) {
                    Label(viewModel.imageData == nil ? "Kép kiválasztása" : "Kép cseréje", systemImage: "photo")
                }
                if viewModel.imageData != nil {
                    Button("Kép eltávolítása", systemImage: "trash", role: .destructive) { viewModel.remove() }
                }
                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            } footer: {
                Text("A kép közepéből egy legfeljebb 512 × 512 pixeles négyzet készül.")
            }
        }
        .navigationTitle("Profilkép")
        .onChange(of: selection) { _, item in
            guard let item else { return }
            Task {
                await loading.run {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        viewModel.choose(data)
                    }
                }
                selection = nil
            }
        }
    }
}

@K10 @M9
public struct ProfileImage: View {
    let data: Data?
    let size: CGFloat

    public init(data: Data?, size: CGFloat) {
        self.data = data
        self.size = size
    }

    public var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill").resizable().foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityLabel(Text("Profilkép"))
    }
}
#endif
