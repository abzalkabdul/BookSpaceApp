import UIKit
import Kingfisher

protocol DetailBookVCDelegate: AnyObject {
    func detailBookVCDidUpdateLibrary(_ controller: DetailBookVC)
}

class DetailBookVC: UIViewController {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var statusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var addToLibraryButton: UIButton!
    @IBOutlet weak var removeFromLibraryButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var book: Book!
    weak var delegate: DetailBookVCDelegate?
    private var isBookInLibrary: Bool = false
    private var currentStatus: ReadingStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithBook()
        checkIfBookInLibrary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfBookInLibrary()
    }
    
    // MARK: - Setup
    private func setupUI() {
        statusSegmentedControl.addTarget(self, action: #selector(statusChanged(_:)), for: .valueChanged)
        
        addToLibraryButton.addTarget(self, action: #selector(addToLibraryTapped), for: .touchUpInside)
        
        removeFromLibraryButton.addTarget(self, action: #selector(removeFromLibraryTapped), for: .touchUpInside)
    }
    
    private func configureWithBook() {
    
        titleLabel.text = book.title
        authorLabel.text = book.authors?.joined(separator: ", ") ?? "Unknown"
        descriptionTextView.text = book.description
        
        if let url = URL(string: book.imageURL ?? "") {
                bookImageView.kf.setImage(with: url)
        }
    }
    
    private func checkIfBookInLibrary() {

        let savedBooks = StorageManager.shared.getMyBooks()
        isBookInLibrary = savedBooks.contains { currentBook in
            currentBook.id == book.id
        }
        
        if isBookInLibrary {
            currentStatus = StorageManager.shared.getBookStatus(book.id)
            // Update UI
            addToLibraryButton.isHidden = true
            removeFromLibraryButton.isHidden = false
            
            // Set segmented control to current status
            if let status = currentStatus {
                switch status {
                case .wantToRead:
                    statusSegmentedControl.selectedSegmentIndex = 0
                case .reading:
                    statusSegmentedControl.selectedSegmentIndex = 1
                case .completed:
                    statusSegmentedControl.selectedSegmentIndex = 2
                }
            }
            statusSegmentedControl.isEnabled = true
        } else {
            // Not in library
            addToLibraryButton.isHidden = false
            removeFromLibraryButton.isHidden = true
            statusSegmentedControl.selectedSegmentIndex = 0
            statusSegmentedControl.isEnabled = true
        }
    }
    
    private func getSelectedStatus() -> ReadingStatus {
        switch statusSegmentedControl.selectedSegmentIndex {
        case 0:
            return .wantToRead
        case 1:
            return .reading
        case 2:
            return .completed
        default:
            return .wantToRead
        }
    }
    
    // MARK: - Actions
    @objc private func statusChanged(_ sender: UISegmentedControl) {
        guard isBookInLibrary else { return }
        
        // Update status in storage
        let newStatus = getSelectedStatus()
        StorageManager.shared.updateBookStatus(book.id, status: newStatus)
        currentStatus = newStatus
        
        // Notify delegate
        delegate?.detailBookVCDidUpdateLibrary(self)
        
        // Show feedback
        showStatusUpdateFeedback(status: newStatus)
    }
    
    @objc private func addToLibraryTapped() {
        
        let status = getSelectedStatus()
        StorageManager.shared.saveBook(book, status: status)
        
        isBookInLibrary = true
        currentStatus = status
        
        // Update UI
        addToLibraryButton.isHidden = true
        removeFromLibraryButton.isHidden = false
        // Notify delegate
        delegate?.detailBookVCDidUpdateLibrary(self)
        // Show success message
        showSuccessAlert(message: "Book added to your library! ✅")
    }
    
    @objc private func removeFromLibraryTapped() {
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Remove Book",
            message: "Are you sure you want to remove '\(book.title)' from your library?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            StorageManager.shared.removeBook(self.book.id)
            self.isBookInLibrary = false
            self.currentStatus = nil
            
            // Update UI
            self.addToLibraryButton.isHidden = false
            self.removeFromLibraryButton.isHidden = true
            self.statusSegmentedControl.selectedSegmentIndex = 0
            
            // Notify delegate
            self.delegate?.detailBookVCDidUpdateLibrary(self)
            
            // Show success message
            self.showSuccessAlert(message: "Book removed from your library 🗑️")
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showStatusUpdateFeedback(status: ReadingStatus) {
        // Create a simple toast-style feedback
        let feedbackLabel = UILabel()
        feedbackLabel.text = "Status: \(status.rawValue)"
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        feedbackLabel.textColor = .white
        feedbackLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        feedbackLabel.layer.cornerRadius = 8
        feedbackLabel.clipsToBounds = true
        feedbackLabel.alpha = 0
        
        // Add to view
        view.addSubview(feedbackLabel)
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            feedbackLabel.widthAnchor.constraint(equalToConstant: 200),
            feedbackLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Animate
        UIView.animate(withDuration: 0.3, animations: {
            feedbackLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, animations: {
                feedbackLabel.alpha = 0
            }) { _ in
                feedbackLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - Public Configuration
extension DetailBookVC {
    func configure(with book: Book) {
        self.book = book
    }
}
