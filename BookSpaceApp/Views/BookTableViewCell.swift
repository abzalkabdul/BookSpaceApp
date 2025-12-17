import UIKit
import Kingfisher

class BookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // private var currentImageURL: String?
    
    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.authors?.joined(separator: ", ") ?? "Unknown"
        descriptionTextView.text = book.description ?? "No description"
        
        if let url = URL(string: book.imageURL ?? "") {
                bookImageView.kf.setImage(with: url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        descriptionTextView.text = nil
    }
    
}
