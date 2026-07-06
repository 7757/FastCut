import AppKit
import CryptoKit

enum ClipKind: String, Codable { case text, image }

struct ClipItem: Codable, Identifiable, Equatable {
    let id: UUID
    var kind: ClipKind
    var text: String?
    var imageFile: String?      // filename inside the images directory (image items only)
    var contentHash: String     // used for de-duplication
    var date: Date

    static func == (l: ClipItem, r: ClipItem) -> Bool { l.contentHash == r.contentHash }
}

private func sha256Hex(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

/// The clipboard history model: an ordered list (most-recent first),
/// persisted to Application Support as a JSON index plus image blobs on disk.
final class HistoryStore: ObservableObject {
    @Published private(set) var items: [ClipItem] = []

    private let dir: URL
    private let imagesDir: URL
    private let indexURL: URL
    private let fm = FileManager.default
    private var imageCache: [String: NSImage] = [:]

    init() {
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        dir = base.appendingPathComponent("FastCut", isDirectory: true)
        imagesDir = dir.appendingPathComponent("images", isDirectory: true)
        indexURL = dir.appendingPathComponent("history.json")
        try? fm.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        load()
    }

    // MARK: Adding

    func addText(_ raw: String) {
        let s = raw
        guard !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let hash = "t:" + sha256Hex(Data(s.utf8))
        upsert(ClipItem(id: UUID(), kind: .text, text: s, imageFile: nil,
                        contentHash: hash, date: Date()))
    }

    func addImage(pngData: Data) {
        let hash = "i:" + sha256Hex(pngData)
        if let idx = items.firstIndex(where: { $0.contentHash == hash }) {
            moveToFront(index: idx)
            return
        }
        let fname = sha256Hex(pngData) + ".png"
        let url = imagesDir.appendingPathComponent(fname)
        if !fm.fileExists(atPath: url.path) {
            do { try pngData.write(to: url, options: .atomic) }
            catch { NSLog("FastCut: image write failed \(error)"); return }
        }
        upsert(ClipItem(id: UUID(), kind: .image, text: nil, imageFile: fname,
                        contentHash: hash, date: Date()))
    }

    private func upsert(_ item: ClipItem) {
        if let idx = items.firstIndex(where: { $0.contentHash == item.contentHash }) {
            moveToFront(index: idx)
        } else {
            items.insert(item, at: 0)
            trim()
            save()
        }
    }

    // MARK: Mutating

    /// Move an existing item to the top (used on re-copy and on paste).
    func moveToFront(_ item: ClipItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        moveToFront(index: idx)
    }

    private func moveToFront(index: Int) {
        guard index >= 0, index < items.count else { return }
        var it = items.remove(at: index)
        it.date = Date()
        items.insert(it, at: 0)
        save()
    }

    func remove(_ item: ClipItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        let it = items.remove(at: idx)
        deleteImageFileIfUnreferenced(it)
        save()
    }

    func clear() {
        for it in items { deleteImageFileIfUnreferenced(it, ignoringSelf: true) }
        items.removeAll()
        imageCache.removeAll()
        // Belt and suspenders: wipe any stragglers on disk.
        if let files = try? fm.contentsOfDirectory(at: imagesDir, includingPropertiesForKeys: nil) {
            for f in files { try? fm.removeItem(at: f) }
        }
        save()
    }

    /// Enforce the max-history preference, deleting any orphaned image files.
    func trim() {
        let maxN = max(5, Settings.shared.maxHistory)
        guard items.count > maxN else { return }
        let overflow = Array(items[maxN...])
        items.removeLast(items.count - maxN)
        for it in overflow { deleteImageFileIfUnreferenced(it) }
        save()
    }

    // MARK: Images

    func image(for item: ClipItem) -> NSImage? {
        guard item.kind == .image, let f = item.imageFile else { return nil }
        if let cached = imageCache[f] { return cached }
        let url = imagesDir.appendingPathComponent(f)
        guard let img = NSImage(contentsOf: url) else { return nil }
        imageCache[f] = img
        return img
    }

    private func deleteImageFileIfUnreferenced(_ item: ClipItem, ignoringSelf: Bool = false) {
        guard item.kind == .image, let f = item.imageFile else { return }
        imageCache[f] = nil
        if !ignoringSelf, items.contains(where: { $0.imageFile == f }) { return }
        try? fm.removeItem(at: imagesDir.appendingPathComponent(f))
    }

    // MARK: Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: indexURL, options: .atomic)
        } catch { NSLog("FastCut: history save failed \(error)") }
    }

    private func load() {
        // Fresh install / nothing saved yet: safe to start empty.
        guard fm.fileExists(atPath: indexURL.path) else { return }
        guard let data = try? Data(contentsOf: indexURL) else {
            NSLog("FastCut: history read failed; leaving existing file untouched")
            return
        }
        do {
            let decoded = try JSONDecoder().decode([ClipItem].self, from: data)
            // Drop image items whose backing file has gone missing.
            items = decoded.filter { it in
                guard it.kind == .image else { return true }
                guard let f = it.imageFile else { return false }
                return fm.fileExists(atPath: imagesDir.appendingPathComponent(f).path)
            }
            collectOrphanImages()
        } catch {
            // The index exists but cannot be decoded (corruption, or a schema
            // change in a future version). Move it aside BEFORE any save() can
            // overwrite it, so the user's history stays recoverable.
            let stamp = Int(Date().timeIntervalSince1970)
            let backup = indexURL.appendingPathExtension("corrupt-\(stamp)")
            do {
                try fm.moveItem(at: indexURL, to: backup)
                NSLog("FastCut: history decode failed, backed up to \(backup.lastPathComponent): \(error)")
            } catch {
                NSLog("FastCut: history decode failed and backup failed: \(error)")
            }
        }
    }

    /// Delete image blobs that no surviving item references — e.g. a PNG written
    /// by addImage() just before a save() that never committed (crash/force-quit).
    private func collectOrphanImages() {
        let referenced = Set(items.compactMap { $0.imageFile })
        guard let files = try? fm.contentsOfDirectory(at: imagesDir,
                                                      includingPropertiesForKeys: nil) else { return }
        for f in files where !referenced.contains(f.lastPathComponent) {
            try? fm.removeItem(at: f)
        }
    }
}
