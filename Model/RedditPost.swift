import Foundation

struct RedditListing: Codable {
    let data: ListingData
}

struct ListingData: Codable {
    let children: [RedditChild]
    let after: String?
}

struct RedditChild: Codable {
    let data: RedditPost
}

struct RedditPost: Codable {
    let authorFullname: String
    let domain: String
    let title: String
    let ups: Int
    let downs: Int
    let numComments: Int
    let createdUtc: Double
    let urlOverriddenByDest: String?
    
    var saved: Bool = false

    enum CodingKeys: String, CodingKey {
        case authorFullname = "author_fullname"
        case domain
        case title
        case ups
        case downs
        case numComments = "num_comments"
        case createdUtc = "created_utc"
        case urlOverriddenByDest = "url_overridden_by_dest"
    }
}
