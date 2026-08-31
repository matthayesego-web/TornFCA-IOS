import Foundation

actor TornAPIClient {
    enum ClientError: LocalizedError {
        case invalidURL
        case invalidResponse
        case api(String)
        case decoding

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The Torn API URL could not be created."
            case .invalidResponse:
                return "Torn returned an unexpected response."
            case .api(let message):
                return message
            case .decoding:
                return "Torn returned data this version of TornFCA could not read."
            }
        }
    }

    private let baseURL = URL(string: "https://api.torn.com/v2")!
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func verifyAPIKey(_ apiKey: String) async throws -> TornProfile {
        let endpoint = baseURL.appendingPathComponent("user/basic")
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw ClientError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "comment", value: "TornFCA iOS")]
        guard let url = components.url else { throw ClientError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("ApiKey \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }

        if let payload = try? decoder.decode(UserBasicResponse.self, from: data),
           (200..<300).contains(http.statusCode) {
            return payload.profile
        }

        if let envelope = try? decoder.decode(TornAPIErrorEnvelope.self, from: data) {
            let message = envelope.error.error ?? envelope.error.message ?? "Torn rejected this API request."
            throw ClientError.api(message)
        }

        if !(200..<300).contains(http.statusCode) {
            throw ClientError.api("Torn returned HTTP \(http.statusCode).")
        }

        throw ClientError.decoding
    }
}
