import Foundation
import Combine
import SharedKit

@K10
protocol ProfilePictureStoring {
    func load() -> Data?
    func save(_ data: Data) throws
    func delete() throws
}

@K10
struct FileProfilePictureStore: ProfilePictureStoring {
    let fileURL: URL

    init(fileName: String = "profile-picture.jpg") {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent(fileName)
    }

    func load() -> Data? {
        try? Data(contentsOf: fileURL)
    }

    func save(_ data: Data) throws {
        try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }

    func delete() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}

@K10
class ProfilePictureViewModel: ObservableObject {
    @Published private(set) var imageData: Data?
    @Published private(set) var errorMessage: LocalizedStringResource?
    private let store: ProfilePictureStoring

    init(store: ProfilePictureStoring) {
        self.store = store
        imageData = store.load()
    }

    func choose(_ data: Data) {
        do {
            let prepared = try ProfilePicture.prepare(data)
            try store.save(prepared)
            imageData = prepared
            errorMessage = nil
        } catch ProfilePicture.PictureError.notAnImage {
            errorMessage = "The file is not an image"
        } catch ProfilePicture.PictureError.tooLarge {
            errorMessage = "The file is too large"
        } catch {
            errorMessage = "The picture could not be saved"
        }
    }

    func remove() {
        do {
            try store.delete()
            imageData = nil
            errorMessage = nil
        } catch {
            errorMessage = "The picture could not be removed"
        }
    }
}
