import Foundation
import Combine

@K10 @M9
public protocol ProfilePictureStoring {
    func load() -> Data?
    func save(_ data: Data) throws
    func delete() throws
}

@K10 @M9
public struct FileProfilePictureStore: ProfilePictureStoring {
    public let fileURL: URL

    public init(fileName: String = "profile-picture.jpg") {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent(fileName)
    }

    public func load() -> Data? {
        try? Data(contentsOf: fileURL)
    }

    public func save(_ data: Data) throws {
        try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }

    public func delete() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}

@K10 @M9
public class ProfilePictureViewModel: ObservableObject {
    @Published public private(set) var imageData: Data?
    @Published public private(set) var errorMessage: LocalizedStringResource?
    private let store: ProfilePictureStoring

    public init(store: ProfilePictureStoring) {
        self.store = store
        imageData = store.load()
    }

    public func choose(_ data: Data) {
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

    public func remove() {
        do {
            try store.delete()
            imageData = nil
            errorMessage = nil
        } catch {
            errorMessage = "The picture could not be removed"
        }
    }
}
