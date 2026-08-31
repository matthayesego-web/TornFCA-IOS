import Foundation

struct TornProfile: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let level: Int
    let gender: String
}

struct UserBasicResponse: Decodable {
    let profile: TornProfile
}

struct TornAPIErrorEnvelope: Decodable {
    struct APIError: Decodable {
        let code: Int?
        let error: String?
        let message: String?
    }

    let error: APIError
}
