import UIKit

class PostViewController: UIViewController {

    private let usernameDomainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let timePassedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(scale: .medium)
        let image = UIImage(systemName: "bookmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let commentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(scale: .medium)
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private var currentPost: RedditPost?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        view.addSubview(usernameDomainLabel)
        view.addSubview(timePassedLabel)
        view.addSubview(titleLabel)
        view.addSubview(postImageView)
        view.addSubview(ratingLabel)
        view.addSubview(bookmarkButton)
        view.addSubview(commentsLabel)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            usernameDomainLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            usernameDomainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            timePassedLabel.centerYAnchor.constraint(equalTo: usernameDomainLabel.centerYAnchor),
            timePassedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: usernameDomainLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 300),
            
            ratingLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 16),
            ratingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            bookmarkButton.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            bookmarkButton.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 16),
            
            commentsLabel.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            commentsLabel.leadingAnchor.constraint(equalTo: bookmarkButton.trailingAnchor, constant: 16),
            
            shareButton.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }
    
    private func fetchData() {
        NetworkManager.shared.fetchTopPosts(subreddit: "ios", limit: 1) { [weak self] result in
            switch result {
            case .success(let posts):
                if let post = posts.first {
                    self?.updateUI(with: post)
                }
            case .failure(let error):
                print("Ошибка при загрузке постов: \(error)")
            }
        }
    }
    
    private func updateUI(with post: RedditPost) {
        self.currentPost = post
        
        usernameDomainLabel.text = "u/\(post.authorFullname) • \(post.domain)"
        timePassedLabel.text = formatTimePassed(since: post.createdUtc)
        titleLabel.text = post.title
        
        let rating = post.ups - post.downs
        ratingLabel.text = "\(rating) pts"
        commentsLabel.text = "\(post.numComments) comments"
        
        let config = UIImage.SymbolConfiguration(scale: .medium)
        let imageName = post.saved ? "bookmark.fill" : "bookmark"
        let image = UIImage(systemName: imageName, withConfiguration: config)
        bookmarkButton.setImage(image, for: .normal)
        
        if let urlString = post.urlOverriddenByDest?.replacingOccurrences(of: "&amp;", with: "&"),
           let url = URL(string: urlString) {
            loadImage(from: url) { [weak self] image in
                self?.postImageView.image = image
            }
        } else {
            postImageView.image = UIImage(systemName: "photo")
        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    private func formatTimePassed(since createdUtc: Double) -> String {
        let postDate = Date(timeIntervalSince1970: createdUtc)
        let diff = Date().timeIntervalSince(postDate)
        let minutes = Int(diff / 60)
        let hours = Int(diff / 3600)
        let days = Int(diff / 86400)
        
        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "just now"
        }
    }
    
    @objc private func bookmarkTapped() {
        guard var post = currentPost else { return }
        post.saved.toggle()
        currentPost = post
        
        let config = UIImage.SymbolConfiguration(scale: .medium)
        let imageName = post.saved ? "bookmark.fill" : "bookmark"
        let image = UIImage(systemName: imageName, withConfiguration: config)
        bookmarkButton.setImage(image, for: .normal)
    }
    
    @objc private func shareTapped() {
        guard let post = currentPost else { return }
        let shareText = "Check out this post: \(post.title)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
