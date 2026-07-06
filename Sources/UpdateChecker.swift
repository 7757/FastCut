import AppKit

/// Checks the GitHub Releases API for a newer version and reports the result.
/// No third-party dependencies, no silent replacement — it surfaces an update
/// in the menu bar and can open the download page.
final class UpdateChecker {
    static let shared = UpdateChecker()

    /// owner/repo used for the releases API.
    private let repo = "7757/FastCut"

    enum Outcome {
        case upToDate(current: String)
        case updateAvailable(version: String, url: String)
        case failed
    }

    private struct Release: Decodable {
        let tag_name: String
        let html_url: String
    }

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    /// Fetch the latest release and report on the main queue.
    func check(userInitiated: Bool, completion: @escaping (Outcome) -> Void) {
        guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest") else {
            DispatchQueue.main.async { completion(.failed) }
            return
        }
        var req = URLRequest(url: url, timeoutInterval: 15)
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        req.setValue("FastCut-UpdateChecker", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: req) { [weak self] data, response, _ in
            guard let self else { return }
            let finish = { (o: Outcome) in DispatchQueue.main.async { completion(o) } }

            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  let data, let release = try? JSONDecoder().decode(Release.self, from: data) else {
                finish(.failed)
                return
            }
            let latest = Self.normalize(release.tag_name)
            let current = Self.normalize(self.currentVersion)
            if Self.isVersion(latest, newerThan: current) {
                finish(.updateAvailable(version: latest, url: release.html_url))
            } else {
                finish(.upToDate(current: current))
            }
        }.resume()
    }

    // MARK: Version helpers

    /// Strip a leading "v" and surrounding whitespace: "v1.2.0" -> "1.2.0".
    static func normalize(_ tag: String) -> String {
        tag.trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
    }

    /// Compare dotted numeric versions (1.0.0 vs 1.2 etc.).
    static func isVersion(_ a: String, newerThan b: String) -> Bool {
        let pa = a.split(separator: ".").map { Int($0) ?? 0 }
        let pb = b.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(pa.count, pb.count) {
            let x = i < pa.count ? pa[i] : 0
            let y = i < pb.count ? pb[i] : 0
            if x != y { return x > y }
        }
        return false
    }
}
