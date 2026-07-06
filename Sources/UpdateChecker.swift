import AppKit

/// Checks GitHub for a newer release and reports the result. No third-party
/// dependencies and no silent replacement — it surfaces updates in the menu bar
/// and can open the download page.
///
/// It reads the version from the `releases/latest` **redirect** (which lands on
/// `/releases/tag/vX.Y.Z`) instead of the REST API, so it is not subject to the
/// unauthenticated API rate limit.
final class UpdateChecker {
    static let shared = UpdateChecker()

    /// owner/repo.
    private let repo = "7757/FastCut"

    /// Where to send the user to download (official site).
    let downloadPage = "https://7757.github.io/FastCut/#download"

    enum Outcome {
        case upToDate(current: String)
        case updateAvailable(version: String, url: String)
        case failed
    }

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    /// Fetch the latest version and report on the main queue.
    func check(userInitiated: Bool, completion: @escaping (Outcome) -> Void) {
        guard let url = URL(string: "https://github.com/\(repo)/releases/latest") else {
            DispatchQueue.main.async { completion(.failed) }
            return
        }
        var req = URLRequest(url: url, timeoutInterval: 15)
        req.setValue("FastCut-UpdateChecker", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: req) { [weak self] _, response, error in
            guard let self else { return }
            let finish = { (o: Outcome) in DispatchQueue.main.async { completion(o) } }

            // URLSession follows the redirect; response.url is …/releases/tag/vX.Y.Z
            guard error == nil,
                  let finalURL = response?.url?.absoluteString,
                  let range = finalURL.range(of: "/releases/tag/") else {
                finish(.failed)
                return
            }
            let tag = finalURL[range.upperBound...].split(separator: "/").first.map(String.init) ?? ""
            let latest = Self.normalize(tag)
            guard !latest.isEmpty else { finish(.failed); return }

            let current = Self.normalize(self.currentVersion)
            if Self.isVersion(latest, newerThan: current) {
                finish(.updateAvailable(version: latest,
                                        url: "https://github.com/\(self.repo)/releases/latest"))
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
