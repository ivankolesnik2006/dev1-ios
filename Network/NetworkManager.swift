import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func fetchTopPosts(
        subreddit: String,
        limit: Int,
        after: String? = nil,
        completion: @escaping (Result<[RedditPost], Error>) -> Void
    ) {
        let baseURL = "https://www.reddit.com/r/\(subreddit)/top.json"
        var urlComponents = URLComponents(string: baseURL)
        
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let after = after {
            queryItems.append(URLQueryItem(name: "after", value: after))
        }
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("MyRedditApp/1.0 (by /u/ivankolesnyk)", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -2)))
                    return
                }
                do {
                    let listing = try JSONDecoder().decode(RedditListing.self, from: data)
                    var posts = listing.data.children.map { $0.data }
                    
                    for i in 0..<posts.count {
                        posts[i].saved = Bool.random()
                    }
                    
                    completion(.success(posts))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
